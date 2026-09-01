//! Rust bindings for the versioned Selene trace protocol.

use std::collections::BTreeMap;

use base64::{Engine as _, engine::general_purpose::URL_SAFE};
use serde::{Deserialize, Deserializer, Serialize, Serializer};

/// The only protocol version represented by this crate release.
pub const SCHEMA_VERSION: &str = "0.1.0";

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
pub struct Trace {
    pub schema_version: SchemaVersion,
    #[serde(default)]
    pub events: Vec<EventRecord>,
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
        #[serde(with = "u64_decimal_string")]
        index: u64,
    },
    Runtime {
        #[serde(with = "u64_decimal_string")]
        start_time: u64,
        #[serde(with = "u64_decimal_string")]
        end_time: u64,
    },
    ErrorModel {
        #[serde(with = "u64_decimal_string")]
        index: u64,
    },
    Simulator {
        #[serde(with = "u64_decimal_string")]
        index: u64,
        #[serde(with = "u64_decimal_string")]
        duration_ns: u64,
    },
}

/// An event in the Selene trace protocol.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(tag = "kind")]
pub enum Event {
    Gate {
        #[serde(default)]
        #[serde(with = "u64_decimal_strings")]
        qubits: Vec<u64>,
        gate_name: String,
        #[serde(default)]
        params: Vec<GateParameter>,
        #[serde(default)]
        predicates: Vec<PredicateResult>,
    },
    Measurement {
        #[serde(with = "u64_decimal_string")]
        qubit: u64,
    },
    Reset {
        #[serde(with = "u64_decimal_string")]
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
    Integer(i64),
    Float(f64),
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
    Integer(i64),
    Float(f64),
    Boolean(bool),
    Integers(Vec<i64>),
    Floats(Vec<f64>),
    Strings(Vec<String>),
    Booleans(Vec<bool>),
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

mod u64_decimal_strings {
    use super::*;

    pub fn serialize<S>(values: &[u64], serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.collect_seq(values.iter().map(u64::to_string))
    }

    pub fn deserialize<'de, D>(deserializer: D) -> Result<Vec<u64>, D::Error>
    where
        D: Deserializer<'de>,
    {
        Vec::<String>::deserialize(deserializer)?
            .into_iter()
            .map(|value| u64_decimal_string::parse(&value).map_err(serde::de::Error::custom))
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

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
    fn unsupported_schema_version_is_rejected() {
        let result = serde_json::from_str::<Trace>(r#"{"schema_version":"1.0.0"}"#);

        assert!(result.is_err());
    }

    #[test]
    fn unsigned_trace_values_reject_negative_integers() {
        for source in [
            r#"{"kind":"UserProgram","index":"-1"}"#,
            r#"{"kind":"Runtime","start_time":"-1","end_time":"0"}"#,
            r#"{"kind":"Runtime","start_time":"0","end_time":"-1"}"#,
            r#"{"kind":"ErrorModel","index":"-1"}"#,
            r#"{"kind":"Simulator","index":"-1","duration_ns":"0"}"#,
            r#"{"kind":"Simulator","index":"0","duration_ns":"-1"}"#,
        ] {
            assert!(serde_json::from_str::<Source>(source).is_err());
        }

        for event in [
            r#"{"kind":"Gate","gate_name":"H","qubits":["-1"]}"#,
            r#"{"kind":"Measurement","qubit":"-1"}"#,
            r#"{"kind":"Reset","qubit":"-1"}"#,
            r#"{"kind":"Custom","payload":{"kind":"OpaquePayload","tag":"-1","data":"dHJhY2U="}}"#,
        ] {
            assert!(serde_json::from_str::<Event>(event).is_err());
        }
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
}
