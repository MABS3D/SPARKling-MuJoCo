# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-ecsmr7h5/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Try_Assemble_CRB` | `mj-data-inertia.adb:10` | [unproved_checks](logs/mj-data-inertia__try_assemble_crb__adb_10.log) | 174 | 75 | 0 | 96.2 |

## Diagnostics

### mj-data-inertia__try_assemble_crb__adb_10

- `mj-data-inertia.adb:14` (medium): postcondition might fail, cannot prove X in Work_Real [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:14` (medium): in inlined expression function body at mj-smooth_dynamics.ads:88
- `mj-data-inertia.adb:40` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Root (K) in 0 .. D.Nb - 1 [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:41` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Root (K) in 1 .. K [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:43` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Submass (K) in 0.0 .. 1.0e14 [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:47` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Submass (K) in 0.0 .. 1.0e14 [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:60` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove V (0) in -Limit .. Limit [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:60` (medium): in inlined expression function body at mj-smooth_math.ads:19
- 67 more diagnostics in the individual log.

