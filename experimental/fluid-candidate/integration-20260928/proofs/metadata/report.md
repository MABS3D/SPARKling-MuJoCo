# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-jpkwy51o/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Inverse_Mass` | `mj-fluid_metadata.adb:2` | [completed_no_unproved](logs/mj-fluid_metadata__inverse_mass__adb_2.log) | 6 | 0 | 0 | 3.8 |
| `Box_Length` | `mj-fluid_metadata.adb:6` | [completed_no_unproved](logs/mj-fluid_metadata__box_length__adb_6.log) | 17 | 0 | 0 | 10.2 |
| `Make_Box` | `mj-data-fluid_phase.adb:18` | [unproved_checks](logs/mj-data-fluid_phase__make_box__adb_18.log) | 25 | 2 | 0 | 84.2 |
| `Make_Ellipsoid` | `mj-data-fluid_phase.adb:45` | [proof_timeout](logs/mj-data-fluid_phase__make_ellipsoid__adb_45.log) | 0 | 0 | 0 | 150.1 |

## Diagnostics

### mj-data-fluid_phase__make_box__adb_18

- `mj-data-fluid_phase.adb:40` (medium): float overflow check might fail [reason for check: result of floating-point addition must be bounded] [provers reached time and memory limit before completing the proof]
- `mj-data-fluid_phase.adb:40` (medium): float overflow check might fail [reason for check: result of floating-point addition must be bounded] [provers reached time and memory limit before completing the proof]

