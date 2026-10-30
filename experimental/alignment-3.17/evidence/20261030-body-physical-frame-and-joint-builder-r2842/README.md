# Body physical-field frame and separated joint builder

Adopted source SHA-256:
`f30888c404d20069be91d1c3b037c3c7b28b11dc2cb6e70d224c0b5c116bd10d`.

The manifold constructor now calls a joint-array builder that cannot mutate
Simulation or its body configuration through its interface. It then passes
only the two body DOF source arrays and the owned body array to the span-copy
helper. Runtime check/copy order remains joints, body spans, final position
layout. Mechanical comparison preserves the original statements after argument
renaming; helper success statuses propagate the original early returns. No
new validation pass or public input restriction is introduced.

The Ghost record model changes exactly First_Joint/Joint_Count and preserves
all nine remaining physical/mocap fields. The record-field audit enumerates all
11 components, including paired declarations. The model and update lemma close
3/2 reported checks per reference. The complete array helper closes33 checks
on both references, proving unchanged physical fields on every normal return
and exact source span values on success. The35-check coordinator closes its
strengthened postcondition on both references. Exact helper/supporting-source
identity permits reuse of those unchanged model/array-helper proofs after
extracting the joint builder; that audit is not presented as a fresh run.

The joint builder's full600-second attempts time out. Its fresh complete VC
inventories contain62 unique source-location/kind tuples per reference. Five
successful same-source regions partition all62 exactly: setup/contract7,
position validation10, joint reads11, quaternion reads8, component writes26.
The audit checks source/options, freshness, representation, complete scoped
reports and absence of missing/foreign/duplicate/skipped/assumed VCs. It credits
none of the deliberately low-resource inventory successes. Existing reviewed
warnings make wrapper passed flags false while obligations_closed is true.

Earlier direct-loop frame invariants, snapshot/cut assertions and an extracted
single-record setter do not close the array/caller obligations. Their actual
failure reports and all frozen variants remain. Separating both mutable arrays
through interfaces closes the functional frame without assumptions or a new
trusted body. This covers current contracts under explicit callee contracts;
full constructors, Reset/state/dynamics and complete physical simulation remain
open. No production ABI/version pin is changed.

Fresh native validation/release builds pass528 cases per pinned3.17/3.14
reference/profile. All132 outputs equal adopted2741 at unchanged16 samples,
100 steps and2e-10 tolerances. Ghost models are absent from native symbols.
Whole MJ.Data flow closes, retaining the same five modeled deallocators.
The body helper is inlined in release; the larger joint builder remains one
separate call in the cold constructor. That call boundary is reported rather
than called zero overhead. There are no new memory-copy/allocation calls in the
inspected wrapper; no timing or integrated C performance parity is claimed.

The runtime audit preserves the earlier release disassembly for the body-only
variant: its metadata loop advances192 bytes per body and writes the adjacent
32-bit fields together, without a new whole-record-copy call. Counts/assembly
are diagnostics, not measurements of speed. The final separated-builder
variant has its own symbol/call audit and numerical matrix. Full feature/ABI
alignment and integrated performance parity remain part of the active goal.

The included cleanup receipt removes only verified raw ZIP duplicates and
obsolete untracked generated indices. Current recipes/payloads/index, tracked
history, source, unique evidence and active caches are preserved; no VHDX
compaction or physical-image shrink is claimed.

Adopted locally. No commit or push is implied.
