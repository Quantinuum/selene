//! Rust bindings for the versioned Selene trace protocol.

use std::collections::BTreeMap;

use base64::{Engine as _, engine::general_purpose::URL_SAFE};
use serde::{Deserialize, Deserializer, Serialize, Serializer};
use serde_json::Value;

/// The only protocol version represented by this crate release.
pub const SCHEMA_VERSION: &str = "0.1.0";

/// The largest integer represented exactly by a JavaScript number.
pub const MAX_SAFE_INTEGER: u64 = (1 << 53) - 1;

/// The version of a Selene trace document.
#[derive(Clone, Copy, Debug, Default, Deserialize, PartialEq, Eq, Serialize)]
pub enum SchemaVersion {
    /// Version 0.1.0 preserves the original event model and adds versioning.
    #[default]
    #[serde(rename = "0.1.0")]
    V0_1_0,
}

/// A complete trace document.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Trace {
    pub schema_version: SchemaVersion,
    #[serde(default)]
    pub events: Vec<EventRecord>,
}

/// The unversioned contents of one emulation trace.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(deny_unknown_fields)]
pub struct TraceData {
    #[serde(default)]
    pub events: Vec<EventRecord>,
}

/// A versioned collection of trace data.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Traces {
    pub schema_version: SchemaVersion,
    pub traces: Vec<TraceData>,
}

/// Either top-level document shape accepted by the trace protocol schema.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(untagged)]
pub enum TraceDocument {
    Trace(Trace),
    Traces(Traces),
}

/// One observed event and the stage that produced it.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub struct EventRecord {
    pub source: Source,
    pub event: Event,
}

/// A stage that produced an event.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(tag = "kind")]
pub enum Source {
    UserProgram {
        #[serde(with = "json_safe_u64")]
        index: u64,
    },
    Runtime {
        #[serde(with = "json_safe_u64")]
        start_time: u64,
        #[serde(with = "json_safe_u64")]
        end_time: u64,
    },
    ErrorModel {
        #[serde(with = "json_safe_u64")]
        index: u64,
    },
    Simulator {
        #[serde(with = "json_safe_u64")]
        index: u64,
        #[serde(with = "json_safe_u64")]
        duration_ns: u64,
    },
}

/// An event in the Selene trace protocol.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(tag = "kind")]
pub enum Event {
    Gate {
        #[serde(default)]
        #[serde(with = "json_safe_u64s")]
        qubits: Vec<u64>,
        gate_name: String,
        #[serde(default)]
        params: Vec<GateParameter>,
        #[serde(default)]
        predicates: Vec<PredicateResult>,
    },
    Measurement {
        #[serde(with = "json_safe_u64")]
        qubit: u64,
    },
    Reset {
        #[serde(with = "json_safe_u64")]
        qubit: u64,
    },
    Custom {
        payload: CustomPayload,
    },
}

/// A predicate associated with a gate event.
#[derive(Clone, Debug, Deserialize, PartialEq, Eq, Serialize)]
pub struct PredicateResult {
    pub predicate: String,
    pub result: bool,
}

/// A gate parameter.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(untagged)]
pub enum GateParameter {
    Boolean(bool),
    Integer(#[serde(with = "safe_numbers")] i64),
    Float(#[serde(with = "safe_numbers")] f64),
}

/// A custom event payload.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(tag = "kind")]
pub enum CustomPayload {
    OpaquePayload {
        #[serde(with = "u64_decimal_string")]
        tag: u64,
        #[serde(with = "base64_bytes")]
        data: Vec<u8>,
    },
    KeyValuePairPayload {
        data: BTreeMap<String, KeyValue>,
    },
}

/// A value accepted by `KeyValuePairPayload.data`.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(untagged)]
pub enum KeyValue {
    String(String),
    Integer(#[serde(with = "safe_numbers")] i64),
    Float(#[serde(with = "safe_numbers")] f64),
    Boolean(bool),
    Integers(#[serde(with = "safe_numbers")] Vec<i64>),
    Floats(#[serde(with = "safe_numbers")] Vec<f64>),
    Strings(Vec<String>),
    Booleans(Vec<bool>),
}

mod safe_numbers {
    use super::*;

    pub trait Valid {
        fn is_valid(&self) -> bool;
    }

    impl Valid for i64 {
        fn is_valid(&self) -> bool {
            self.unsigned_abs() <= MAX_SAFE_INTEGER
        }
    }

    impl Valid for f64 {
        fn is_valid(&self) -> bool {
            self.is_finite() && (self.fract() != 0.0 || self.abs() <= MAX_SAFE_INTEGER as f64)
        }
    }

    impl<T: Valid> Valid for Vec<T> {
        fn is_valid(&self) -> bool {
            self.iter().all(Valid::is_valid)
        }
    }

    pub fn serialize<T: Valid + Serialize, S: Serializer>(
        value: &T,
        serializer: S,
    ) -> Result<S::Ok, S::Error> {
        if !value.is_valid() {
            return Err(serde::ser::Error::custom(
                "invalid or unsafe integer-valued number",
            ));
        }
        value.serialize(serializer)
    }

    pub fn deserialize<'de, T: Valid + Deserialize<'de>, D: Deserializer<'de>>(
        deserializer: D,
    ) -> Result<T, D::Error> {
        let value = T::deserialize(deserializer)?;
        if !value.is_valid() {
            return Err(serde::de::Error::custom(
                "invalid or unsafe integer-valued number",
            ));
        }
        Ok(value)
    }
}

mod base64_bytes {
    use super::*;

    pub fn serialize<S>(value: &[u8], serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(&URL_SAFE.encode(value))
    }

    pub fn deserialize<'de, D>(deserializer: D) -> Result<Vec<u8>, D::Error>
    where
        D: Deserializer<'de>,
    {
        let encoded = String::deserialize(deserializer)?;
        URL_SAFE.decode(encoded).map_err(serde::de::Error::custom)
    }
}

mod u64_decimal_string {
    use super::*;

    pub fn serialize<S>(value: &u64, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(&value.to_string())
    }

    pub fn deserialize<'de, D>(deserializer: D) -> Result<u64, D::Error>
    where
        D: Deserializer<'de>,
    {
        let value = String::deserialize(deserializer)?;
        parse(&value).map_err(serde::de::Error::custom)
    }

    pub(super) fn parse(value: &str) -> Result<u64, &'static str> {
        (!value.is_empty()
            && (value == "0" || !value.starts_with('0'))
            && value.bytes().all(|byte| byte.is_ascii_digit()))
        .then_some(())
        .ok_or("expected a canonical unsigned decimal string")?;

        value
            .parse()
            .map_err(|_| "expected an unsigned 64-bit integer")
    }
}

mod json_safe_u64 {
    use super::*;

    pub fn serialize<S>(value: &u64, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        if *value > MAX_SAFE_INTEGER {
            return Err(serde::ser::Error::custom(
                "integer exceeds JavaScript's safe integer range",
            ));
        }
        serializer.serialize_u64(*value)
    }

    pub fn deserialize<'de, D>(deserializer: D) -> Result<u64, D::Error>
    where
        D: Deserializer<'de>,
    {
        let value = u64::deserialize(deserializer)?;
        (value <= MAX_SAFE_INTEGER)
            .then_some(value)
            .ok_or_else(|| serde::de::Error::custom("integer exceeds JavaScript's safe range"))
    }
}

mod json_safe_u64s {
    use super::*;

    pub fn serialize<S>(values: &[u64], serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        if values.iter().any(|value| *value > MAX_SAFE_INTEGER) {
            return Err(serde::ser::Error::custom(
                "integer exceeds JavaScript's safe integer range",
            ));
        }
        values.serialize(serializer)
    }

    pub fn deserialize<'de, D>(deserializer: D) -> Result<Vec<u64>, D::Error>
    where
        D: Deserializer<'de>,
    {
        let values = Vec::<u64>::deserialize(deserializer)?;
        values
            .iter()
            .all(|value| *value <= MAX_SAFE_INTEGER)
            .then_some(values)
            .ok_or_else(|| serde::de::Error::custom("integer exceeds JavaScript's safe range"))
    }
}

/// Parse a current or versionless legacy trace JSON document.
pub fn parse_trace_json(input: &str) -> Result<Trace, serde_json::Error> {
    parse_trace_value(serde_json::from_str(input)?)
}

/// Parse a current or versionless legacy trace JSON value.
pub fn parse_trace_value(mut value: Value) -> Result<Trace, serde_json::Error> {
    let is_legacy = value
        .as_object()
        .is_some_and(|document| !document.contains_key("schema_version"));
    if is_legacy {
        upgrade_legacy_value(&mut value)?;
    }
    serde_json::from_value(value)
}

/// Parse a current trace or trace collection, or a versionless legacy trace.
pub fn parse_trace_document_json(input: &str) -> Result<TraceDocument, serde_json::Error> {
    parse_trace_document_value(serde_json::from_str(input)?)
}

/// Parse a current trace-document value or a versionless legacy trace value.
pub fn parse_trace_document_value(value: Value) -> Result<TraceDocument, serde_json::Error> {
    let is_legacy = value
        .as_object()
        .is_some_and(|document| !document.contains_key("schema_version"));
    if is_legacy {
        return parse_trace_value(value).map(TraceDocument::Trace);
    }
    serde_json::from_value(value)
}

fn upgrade_legacy_value(value: &mut Value) -> Result<(), serde_json::Error> {
    let document = value.as_object_mut().ok_or_else(|| {
        <serde_json::Error as serde::de::Error>::custom("trace document must be a JSON object")
    })?;
    if document.contains_key("traces") {
        return Err(<serde_json::Error as serde::de::Error>::custom(
            "versionless trace collections are not supported",
        ));
    }
    document.insert(
        "schema_version".to_owned(),
        Value::String(SCHEMA_VERSION.to_owned()),
    );

    if let Some(events) = document.get_mut("events").and_then(Value::as_array_mut) {
        for record in events {
            let Some(payload) = record
                .get_mut("event")
                .and_then(Value::as_object_mut)
                .filter(|event| event.get("kind").and_then(Value::as_str) == Some("Custom"))
                .and_then(|event| event.get_mut("payload"))
                .and_then(Value::as_object_mut)
                .filter(|payload| {
                    payload.get("kind").and_then(Value::as_str) == Some("OpaquePayload")
                })
            else {
                continue;
            };

            let tag = payload.get("tag").and_then(Value::as_u64).ok_or_else(|| {
                <serde_json::Error as serde::de::Error>::custom(
                    "legacy OpaquePayload.tag must be an unsigned JSON integer",
                )
            })?;
            payload.insert("tag".to_owned(), Value::String(tag.to_string()));
            // Accept either legacy alphabet; the normal decoder still validates
            // padding and contents, and serialization always uses base64url.
            if let Some(Value::String(data)) = payload.get_mut("data") {
                *data = data.replace('+', "-").replace('/', "_");
            }
        }
    }

    document.retain(|key, _| matches!(key.as_str(), "schema_version" | "events"));

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn numeric_values_enforce_signed_safe_integer_bounds() {
        for (json, valid) in [
            ("9007199254740991", true),
            ("-9007199254740991", true),
            ("9007199254740992", false),
            ("-9007199254740992", false),
            ("100000000000000000000", false),
            ("1e20", false),
            ("-1e20", false),
            ("0", true),
            ("0.5", true),
            ("-1.5", true),
            ("true", true),
        ] {
            assert_eq!(
                serde_json::from_str::<GateParameter>(json).is_ok(),
                valid,
                "{json}"
            );
            assert_eq!(
                serde_json::from_str::<KeyValue>(json).is_ok(),
                valid,
                "{json}"
            );
            assert_eq!(
                serde_json::from_str::<KeyValue>(&format!("[{json}]")).is_ok(),
                valid,
                "{json}"
            );
        }
        for value in [
            GateParameter::Integer(i64::MAX),
            GateParameter::Float(1e20),
            GateParameter::Float(f64::NAN),
        ] {
            assert!(serde_json::to_string(&value).is_err());
        }
        for value in [
            KeyValue::Integer(i64::MIN),
            KeyValue::Float(-1e20),
            KeyValue::Integers(vec![i64::MAX]),
            KeyValue::Floats(vec![1e20]),
        ] {
            assert!(serde_json::to_string(&value).is_err());
        }
    }

    #[test]
    fn minimal_example_deserializes() {
        let trace: Trace = serde_json::from_str(include_str!("../../examples/trace/minimal.json"))
            .expect("minimal example must conform to the trace model");

        assert_eq!(trace.schema_version, SchemaVersion::V0_1_0);
        assert_eq!(trace.events.len(), 1);
    }

    #[test]
    fn all_event_types_example_deserializes() {
        let trace: Trace =
            serde_json::from_str(include_str!("../../examples/trace/all-event-types.json"))
                .expect("all event types example must conform to the trace model");

        assert_eq!(trace.events.len(), 5);
    }

    #[test]
    fn traces_example_deserializes_as_a_collection_document() {
        let document: TraceDocument =
            serde_json::from_str(include_str!("../../examples/trace/traces.json"))
                .expect("traces example must conform to the trace model");

        let TraceDocument::Traces(traces) = document else {
            panic!("traces example must deserialize as Traces");
        };
        assert_eq!(traces.schema_version, SchemaVersion::V0_1_0);
        assert_eq!(traces.traces.len(), 2);
    }

    #[test]
    fn trace_document_parser_accepts_singular_and_collection_documents() {
        assert!(matches!(
            parse_trace_document_json(include_str!("../../examples/trace/minimal.json")),
            Ok(TraceDocument::Trace(_))
        ));
        assert!(matches!(
            parse_trace_document_json(include_str!("../../examples/trace/traces.json")),
            Ok(TraceDocument::Traces(_))
        ));
    }

    #[test]
    fn trace_document_parser_rejects_a_versionless_collection() {
        assert!(parse_trace_document_json(r#"{"traces":[]}"#).is_err());
    }

    #[test]
    fn unsupported_schema_version_is_rejected() {
        let result = serde_json::from_str::<Trace>(r#"{"schema_version":"1.0.0"}"#);

        assert!(result.is_err());
    }

    #[test]
    fn unsigned_trace_values_reject_negative_integers() {
        for source in [
            r#"{"kind":"UserProgram","index":-1}"#,
            r#"{"kind":"Runtime","start_time":-1,"end_time":0}"#,
            r#"{"kind":"Runtime","start_time":0,"end_time":-1}"#,
            r#"{"kind":"ErrorModel","index":-1}"#,
            r#"{"kind":"Simulator","index":-1,"duration_ns":0}"#,
            r#"{"kind":"Simulator","index":0,"duration_ns":-1}"#,
        ] {
            assert!(serde_json::from_str::<Source>(source).is_err());
        }

        for event in [
            r#"{"kind":"Gate","gate_name":"H","qubits":[-1]}"#,
            r#"{"kind":"Measurement","qubit":-1}"#,
            r#"{"kind":"Reset","qubit":-1}"#,
            r#"{"kind":"Custom","payload":{"kind":"OpaquePayload","tag":"-1","data":"dHJhY2U="}}"#,
        ] {
            assert!(serde_json::from_str::<Event>(event).is_err());
        }
    }

    #[test]
    fn safe_integer_fields_enforce_the_javascript_range() {
        let valid = format!(r#"{{"kind":"UserProgram","index":{MAX_SAFE_INTEGER}}}"#);
        assert!(serde_json::from_str::<Source>(&valid).is_ok());

        let invalid = format!(
            r#"{{"kind":"UserProgram","index":{}}}"#,
            MAX_SAFE_INTEGER + 1
        );
        assert!(serde_json::from_str::<Source>(&invalid).is_err());
        assert!(
            serde_json::to_string(&Source::UserProgram {
                index: MAX_SAFE_INTEGER + 1,
            })
            .is_err()
        );
    }

    #[test]
    fn opaque_payload_uses_base64url_in_json() {
        let payload = CustomPayload::OpaquePayload {
            tag: 1,
            data: b"trace".to_vec(),
        };

        assert_eq!(
            serde_json::to_string(&payload).expect("payload must serialize"),
            r#"{"kind":"OpaquePayload","tag":"1","data":"dHJhY2U="}"#,
        );
    }

    #[test]
    fn opaque_payload_tag_requires_a_canonical_uint64_decimal_string() {
        for tag in [
            "1",
            "0",
            "18446744073709551615",
            "18446744073709551616",
            "-1",
            "01",
        ] {
            let document = format!(r#"{{"kind":"OpaquePayload","tag":{tag:?},"data":"dHJhY2U="}}"#);
            let result = serde_json::from_str::<CustomPayload>(&document);

            assert_eq!(
                result.is_ok(),
                matches!(tag, "0" | "1" | "18446744073709551615")
            );
        }

        let numeric_tag = serde_json::from_str::<CustomPayload>(
            r#"{"kind":"OpaquePayload","tag":1,"data":"dHJhY2U="}"#,
        );
        assert!(numeric_tag.is_err());
    }

    #[test]
    fn legacy_opaque_payload_alphabets_round_trip_as_base64url() {
        for encoded in ["+/8=", "-_8="] {
            let input = serde_json::json!({
                "events": [{
                    "source": {"kind": "UserProgram", "index": 0},
                    "event": {
                        "kind": "Custom",
                        "payload": {"kind": "OpaquePayload", "tag": 1, "data": encoded}
                    }
                }]
            });
            let trace = parse_trace_json(&input.to_string()).expect("legacy alphabet is accepted");
            let Event::Custom {
                payload: CustomPayload::OpaquePayload { tag, data },
            } = &trace.events[0].event
            else {
                panic!("expected opaque payload");
            };
            assert_eq!(*tag, 1);
            assert_eq!(data, &[0xfb, 0xff]);

            let mut output = serde_json::to_value(&trace).expect("trace serializes");
            assert_eq!(output["events"][0]["event"]["payload"]["data"], "-_8=");
            assert_eq!(output["events"][0]["event"]["payload"]["tag"], "1");
            assert_eq!(parse_trace_value(output.clone()).unwrap(), trace);

            output["events"][0]["event"]["payload"]["data"] = Value::String("+/8=".into());
            assert!(
                parse_trace_value(output).is_err(),
                "versioned input requires base64url"
            );
        }
    }

    #[test]
    fn versionless_legacy_trace_is_upgraded() {
        let trace = parse_trace_json(include_str!("../../examples/trace/legacy.json"))
            .expect("legacy example must be supported");

        assert_eq!(trace.schema_version, SchemaVersion::V0_1_0);
        assert_eq!(trace.events.len(), 2);
        assert!(matches!(
            &trace.events[1].event,
            Event::Custom {
                payload: CustomPayload::OpaquePayload {
                    tag: 11616494188317837126,
                    ..
                }
            }
        ));
    }
}
