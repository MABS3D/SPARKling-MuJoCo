# Manifold-copy frames and caller preconditions

The adopted source adds only Static contracts, loop invariants and Ghost
projections. Copy_Manifold_Joints preserves body allocation/bounds, dimensions,
selected option scalars and topology/ancestor-cache emptiness. Its activation
caller preserves body allocation across the actuator loop. Damping/armature
ranges are projected from the DOF validator already run by both public factories;
no new public input restriction or executable scan is added.

| Final scope | Reported checks per reference | Property |
| --- | ---: | --- |
| Prove_Dof_Values | 20 | All validated damping/armature values in range |
| Model_Status | 15 | Original postcondition plus existing DOF validation fact |
| Copy_Manifold_Joints combined postcondition | 11 | Original successful layout and new frame |
| Three copy-loop invariants | 12 each | Frame initialization and preservation |
| Activation-loop body allocation invariant | 9 | Initialization and preservation |
| Per-DOF assignment region | 21 | Damping/armature reads and owned write |
| Initialize topology call | 8 | Required manifold builder precondition |

Each selected postcondition, invariant or call scope is narrower than a complete
procedure proof. Counts include flow/unrolling information; actual proof_checks
and all reviewed warnings are retained. Whole constructors, Reset, full state
and dynamics Gold, private invariant adoption, full feature/ABI alignment and
integrated C performance parity remain unfinished. The body-metadata diagnostic
retains its actual outcome rather than claiming complete copy safety.

The strengthened internal preconditions have selected caller proofs at Create
to Initialize and at both Initialize/Create_Dynamics to Copy_Manifold_Joints.
No runtime validator is removed or added in this checkpoint. Exact removal of
the new Static/Ghost code recovers the previous source byte-for-byte. A native
GNAT validation-profile policy probe confirms that new contracts, Ghost calls,
Ghost snapshots and Static invariants are not executed; normal checks execute.

Fresh native validation/release builds each pass528 numerical cases against
both pinned3.17 and3.14 references, with16 samples,100 steps and unchanged2e-10
tolerances. All132 output files equal previous production2622 byte-for-byte.
The new Ghost projection is absent from native symbols. This is neither timing
nor a universal equivalence proof; no performance improvement is claimed.

Both whole MJ.Data flow reports contain333 informational checks and no open
messages, retaining the same five modeled deallocators. The initial audit
classifier incorrectly required proof-mode termination and every entity body
in SPARK; its false result is retained, with a separate audit accepting the
actual FLOW_MODE terminator and exactly the unchanged reviewed deallocators.
This is flow-only evidence, with zero runtime/functional proof VCs.

The earlier filters selecting a body-local Static postcondition generated zero
proof checks (r2652/r2656) and are explicitly mis-scoped, despite their old
wrapper flag. The corrected filter selects the combined postcondition at its
original aspect location and requires proof_checks>0. The plural-line attempt
and all earlier watchdog/failure reports remain archived. No proof follows
from timeout, added annotations alone or compiler success.

These changes are adopted locally. No commit or push is implied by this
checkpoint, and full-port completion/performance parity remain open.
