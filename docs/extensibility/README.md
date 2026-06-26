# Extending Selene

Selene is built around replaceable pieces. A user-facing interface, such as a
Python interactive session or a QIS binding, describes work in terms of gates.
A runtime decides how to schedule that work. An error model can mutate the work
stochastically. A simulator finally executes the operations it receives.

Plugins exist so those pieces can evolve independently. You can write a new
hardware-aware runtime without changing a simulator. You can test a new noise
model against several simulators. You can add a simulator backend without
teaching every interface about its internal gate names.

The key idea is that all quantum gates cross extension boundaries through
gatewire. Gatewire gives each gate a stable semantic identity and a typed list
of operands. During setup, each layer negotiates a gateset:

1. The interface registers the gates it intends to send.
2. The runtime accepts that gateset and returns the gates it may emit.
3. The error model accepts the runtime gateset and returns the gates it may
   emit.
4. The simulator accepts the final gateset or rejects the configuration.

That handshake is what lets Selene support cases such as a runtime accepting
`RZ` from users while lowering it into something else before the simulator sees
it.

## Learning Path

Read these in order if you are new to Selene plugins:

1. [Fundamentals](fundamentals.md) explains the lifecycle, descriptors,
   gatesets, metrics, and memory rules shared by all plugin types.
2. [Gates and gatesets](gates/README.md) explains builtin gates, custom gate
   definitions, and gatewire transport.
3. [Worked examples](examples/README.md) shows a complete custom-gateset stack
   from interface registration to simulator validation.
4. [Runtime plugins](runtime/README.md) explains how a runtime receives user
   operations and emits batches.
5. [Error model plugins](error-model/README.md) explains how stochastic errors
   are injected.
6. [Simulator plugins](simulator/README.md) explains how a backend executes the
   final operation stream.

Each plugin section has a Rust tutorial and a C tutorial. Rust plugins normally
use Selene's traits and export macros. C plugins implement the descriptor ABI
directly.

## Choosing an Extension Point

Write a runtime when you want to control scheduling, qubit allocation, barriers,
operation batching, or the way user-facing operations are lowered before noise
and simulation.

Write an error model when you want to represent noise by injecting gates,
measurements, resets, or other operation-level effects between the runtime and
simulator.

Write a simulator when you want a new execution backend. Simulators should do
exactly what they are told. They should reject unsupported gates during gateset
negotiation rather than silently approximating them.

Define gates when the builtin gates are not enough. Gates are not plugins by
themselves; they are the shared vocabulary that interfaces and plugins negotiate.
