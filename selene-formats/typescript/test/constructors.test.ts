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
