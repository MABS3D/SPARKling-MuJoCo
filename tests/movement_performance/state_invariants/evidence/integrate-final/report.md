# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-q_zkz2f9/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Integrate` | `mj-data-euler.adb:5` | [unproved_checks](logs/mj-data-euler__integrate__adb_5.log) | 55 | 8 | 0 | 108.5 |

## Diagnostics

### mj-data-euler__integrate__adb_5

- `mj-data-euler.adb:42` (medium): assertion might fail, cannot prove X in Tier0_Real [provers reached memory limit before completing the proof]
- `mj-data-euler.adb:42` (medium): in inlined expression function body at mj-smooth_kernels.ads:67
- `mj-data-euler.adb:43` (medium): assertion might fail, cannot prove X in Tier0_Real [provers reached memory limit before completing the proof]
- `mj-data-euler.adb:43` (medium): in inlined expression function body at mj-smooth_kernels.ads:67
- `mj-data-euler.adb:46` (medium): assertion might fail [provers reached memory limit before completing the proof]
- `mj-data-euler.adb:48` (medium): assertion might fail [provers reached memory limit before completing the proof]
- `mj-data-euler.adb:49` (medium): precondition might fail, cannot prove A.Timestep = B.Timestep [provers reached memory limit before completing the proof]
- `mj-data-euler.ads:24` (medium): postcondition might fail, cannot prove Is_Ready (D) [provers reached memory limit before completing the proof]

