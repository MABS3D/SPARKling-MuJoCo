# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-pbe5_qh0/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Pack_Inertia` | `mj-spatial_kernels.adb:31` | [completed_no_unproved](logs/mj-spatial_kernels__pack_inertia__adb_31.log) | 2 | 0 | 0 | 3.4 |
| `Make_Inertia` | `mj-spatial_kernels.adb:36` | [unproved_checks](logs/mj-spatial_kernels__make_inertia__adb_36.log) | 44 | 1 | 0 | 33.0 |
| `Multiply` | `mj-spatial_kernels.adb:85` | [completed_no_unproved](logs/mj-spatial_kernels__multiply__adb_85.log) | 100 | 0 | 0 | 9.6 |
| `Joint_Motion` | `mj-spatial_kernels.adb:110` | [completed_no_unproved](logs/mj-spatial_kernels__joint_motion__adb_110.log) | 25 | 0 | 0 | 11.3 |

## Diagnostics

### mj-spatial_kernels__make_inertia__adb_36

- `mj-spatial_kernels.ads:56` (medium): postcondition might fail, cannot prove Make_Inertia'Result = [Shift_Diagonal (Rotated_Entry (R, Diagonal, 0, 0), Mass, Offset (1), Offset (2)), Shift_Diagonal (Rotated_Entry (R, Diagonal, 1, 1), Mass, Offset (0), Offset (2)), Shift_Diagonal (Rotated_Entry (R, Diagonal, 2, 2), Mass, Offset (0), ... [provers reached time and memory limit before completing the proof]

