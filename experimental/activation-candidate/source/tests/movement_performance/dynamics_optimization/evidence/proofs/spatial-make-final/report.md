# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-e9iouate/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Make_Inertia` | `mj-spatial_kernels.adb:36` | [unproved_checks](logs/mj-spatial_kernels__make_inertia__adb_36.log) | 44 | 1 | 0 | 33.6 |

## Diagnostics

### mj-spatial_kernels__make_inertia__adb_36

- `mj-spatial_kernels.ads:57` (medium): postcondition might fail, cannot prove Make_Inertia'Result (0) = Shift_Diagonal (Rotated_Entry (R, Diagonal, 0, 0), Mass, Offset (1), Offset (2)) [provers reached time and memory limit before completing the proof]

