# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-g_2tpp66/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Try_Recursive` | `mj-data-forces.adb:10` | [unproved_checks](logs/mj-data-forces__try_recursive__adb_10.log) | 89 | 33 | 0 | 130.9 |

## Diagnostics

### mj-data-forces__try_recursive__adb_10

- `mj-data-forces.adb:16` (medium): postcondition might fail, cannot prove X in Work_Real [provers reached time limit before completing the proof]
- `mj-data-forces.adb:16` (medium): in inlined expression function body at mj-smooth_dynamics.ads:75
- `mj-data-forces.adb:36` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove V (0) in -Limit .. Limit [provers reached time limit before completing the proof]
- `mj-data-forces.adb:36` (medium): in inlined expression function body at mj-spatial_kernels.ads:10
- `mj-data-forces.adb:41` (medium): precondition might fail, cannot prove R (0, 0) in -Limit .. Limit [provers reached time limit before completing the proof]
- `mj-data-forces.adb:41` (medium): in inlined expression function body at mj-smooth_math.ads:28
- `mj-data-forces.adb:42` (medium): precondition might fail, cannot prove V (0) in -Limit .. Limit [provers reached time limit before completing the proof]
- `mj-data-forces.adb:42` (medium): in inlined expression function body at mj-smooth_math.ads:19
- 25 more diagnostics in the individual log.

