# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-4hvqxcj_/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Rotated_Entry` | `mj-spatial_kernels.adb:2` | [completed_no_unproved](logs/mj-spatial_kernels__rotated_entry__adb_2.log) | 26 | 0 | 0 | 29.2 |
| `Make_Inertia` | `mj-spatial_kernels.adb:31` | [unproved_checks](logs/mj-spatial_kernels__make_inertia__adb_31.log) | 44 | 7 | 0 | 57.7 |
| `Multiply` | `mj-spatial_kernels.adb:56` | [proof_timeout](logs/mj-spatial_kernels__multiply__adb_56.log) | 0 | 0 | 0 | 90.1 |
| `Dot` | `mj-spatial_kernels.adb:91` | [completed_no_unproved](logs/mj-spatial_kernels__dot__adb_91.log) | 31 | 0 | 0 | 17.2 |

## Diagnostics

### mj-spatial_kernels__make_inertia__adb_31

- `mj-spatial_kernels.adb:40` (medium): float overflow check might fail [reason for check: result of floating-point multiplication must be bounded] [possible fix: precondition of subprogram at mj-spatial_kernels.ads:33 should mention Mass] [provers reached time and memory limit before completing the proof]
- `mj-spatial_kernels.adb:40` (medium): range check might fail [reason for check: default component value must fit in the type] [possible fix: precondition of subprogram at mj-spatial_kernels.ads:33 should mention Mass] [provers reached time and memory limit before completing the proof]
- `mj-spatial_kernels.adb:41` (medium): float overflow check might fail [reason for check: result of floating-point multiplication must be bounded] [possible fix: precondition of subprogram at mj-spatial_kernels.ads:33 should mention Mass] [provers reached time and memory limit before completing the proof]
- `mj-spatial_kernels.adb:41` (medium): range check might fail [reason for check: default component value must fit in the type] [possible fix: precondition of subprogram at mj-spatial_kernels.ads:33 should mention Mass] [provers reached time and memory limit before completing the proof]
- `mj-spatial_kernels.adb:42` (medium): float overflow check might fail [reason for check: result of floating-point multiplication must be bounded] [possible fix: precondition of subprogram at mj-spatial_kernels.ads:33 should mention Mass] [provers reached time and memory limit before completing the proof]
- `mj-spatial_kernels.adb:42` (medium): range check might fail [reason for check: default component value must fit in the type] [possible fix: precondition of subprogram at mj-spatial_kernels.ads:33 should mention Mass] [provers reached time and memory limit before completing the proof]
- `mj-spatial_kernels.ads:37` (medium): postcondition might fail, cannot prove Bounded (Make_Inertia'Result, 1.0e36) [provers reached time and memory limit before completing the proof]

