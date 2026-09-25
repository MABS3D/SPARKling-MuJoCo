# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-6x26qgpn/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Add` | `mj-spatial_kernels.adb:57` | [unproved_checks](logs/mj-spatial_kernels__add__adb_57.log) | 15 | 1 | 0 | 13.2 |

## Diagnostics

### mj-spatial_kernels__add__adb_57

- `mj-spatial_kernels.ads:79` (medium): postcondition might fail, cannot prove Add'Result (K) = A (K) + B (K) [provers reached time limit before completing the proof]

