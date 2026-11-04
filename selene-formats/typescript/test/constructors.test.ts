import { trace } from "../src/index.js";

declare const wireEvents: trace.EventRecordInput[];
declare const document: trace.Trace;
declare const wireData: trace.TraceDataInput;

const data: trace.TraceData = trace.createTraceData(wireEvents);
const fromParsed: trace.TraceData = trace.createTraceData(document.events);
const singular: trace.Trace = trace.createTrace(data.events);
const collection: trace.Traces = trace.createTraces([data, fromParsed, wireData]);
const mixed: trace.TraceData = trace.createTraceData([...wireEvents, ...singular.events]);
trace.createTraces([mixed, ...collection.traces]);

const result: trace.ParseResult<trace.Trace> = trace.safeParseTrace({});
if (result.success) {
  const parsed: trace.Trace = result.data;
  trace.serializeTrace(parsed);
} else {
  const error: Error = result.error;
  error.message;
  // @ts-expect-error Validation errors expose the standard Error interface.
  result.error.issues;
}
// @ts-expect-error Schemas are internal to the package.
trace.TraceSchema;


const numericOutcome: trace.FutureResultValue = 1;
const structuredOutcome: trace.FutureResultValue = { result: [true, null, 0.5] };
const stringOutcome: trace.FutureResultValue = "text";
const nestedStringOutcome: trace.FutureResultValue = { result: ["text"] };
