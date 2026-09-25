# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-pcrorpmw/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Rotated_Entry` | `mj-spatial_kernels.adb:2` | [unproved_checks](logs/mj-spatial_kernels__rotated_entry__adb_2.log) | 22 | 3 | 0 | 30.1 |
| `Shift_Diagonal` | `mj-spatial_kernels.adb:10` | [completed_no_unproved](logs/mj-spatial_kernels__shift_diagonal__adb_10.log) | 13 | 0 | 0 | 8.7 |
| `Shift_Offdiagonal` | `mj-spatial_kernels.adb:17` | [completed_no_unproved](logs/mj-spatial_kernels__shift_offdiagonal__adb_17.log) | 8 | 0 | 0 | 4.4 |
| `Make_Inertia` | `mj-spatial_kernels.adb:23` | [unproved_checks](logs/mj-spatial_kernels__make_inertia__adb_23.log) | 35 | 1 | 0 | 32.9 |
| `Add` | `mj-spatial_kernels.adb:35` | [completed_no_unproved](logs/mj-spatial_kernels__add__adb_35.log) | 13 | 0 | 0 | 4.3 |
| `Multiply` | `mj-spatial_kernels.adb:45` | [proof_timeout](logs/mj-spatial_kernels__multiply__adb_45.log) | 0 | 0 | 0 | 60.1 |
| `Dot` | `mj-spatial_kernels.adb:55` | [unproved_checks](logs/mj-spatial_kernels__dot__adb_55.log) | 25 | 1 | 0 | 25.4 |

## Diagnostics

### mj-spatial_kernels__rotated_entry__adb_2

- `mj-spatial_kernels.adb:8` (medium): float overflow check might fail [reason for check: result of floating-point addition must be bounded] [possible fix: precondition of subprogram at mj-spatial_kernels.ads:13 should mention Row] [provers reached time limit before completing the proof]
- `mj-spatial_kernels.adb:8` (medium): float overflow check might fail [reason for check: result of floating-point addition must be bounded] [possible fix: precondition of subprogram at mj-spatial_kernels.ads:13 should mention Row] [provers reached time limit before completing the proof]
- `mj-spatial_kernels.ads:16` (medium): postcondition might fail, cannot prove Rotated_Entry'Result in -1.0e15 .. 1.0e15 [provers reached time limit before completing the proof]

### mj-spatial_kernels__make_inertia__adb_23

- `mj-spatial_kernels.ads:37` (medium): postcondition might fail, cannot prove Bounded (Make_Inertia'Result, 1.0e36) [provers reached time and memory limit before completing the proof]

### mj-spatial_kernels__dot__adb_55

- `mj-spatial_kernels.ads:60` (medium): postcondition might fail, cannot prove Dot'Result in -1.0e68 .. 1.0e68 [provers reached time limit before completing the proof]

