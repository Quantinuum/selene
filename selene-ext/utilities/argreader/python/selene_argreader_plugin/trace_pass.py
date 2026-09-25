from selene_core import trace
import yaml

ARGREADER_LOGGING_TAG = 0xA13613EADE130746


def argreader_trace_pass(selene_trace: trace.Trace) -> trace.Trace:
    new_records = []
    for record in selene_trace.events:
        if (
            record.source.kind == "UserProgram"
            and record.event.kind == "Custom"
            and record.event.payload.kind == "OpaquePayload"
            and record.event.payload.tag == ARGREADER_LOGGING_TAG
        ):
            yaml_text = record.event.payload.data.decode("utf-8")
            yaml_data = yaml.safe_load(yaml_text)
            replacement = trace.EventRecord(
                source=record.source,
                event=trace.CustomEvent(
                    payload=trace.KeyValuePairPayload(
                        data={"type": "ArgumentRead", **yaml_data}
                    )
                ),
            )
            new_records.append(replacement)
        else:
            new_records.append(record)
    return trace.Trace(schema_version=trace.SCHEMA_VERSION, events=new_records)
