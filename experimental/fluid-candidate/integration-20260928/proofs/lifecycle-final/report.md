# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-9y_5_k__/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Make_Box` | `mj-data-fluid_phase.adb:18` | [unproved_checks](logs/mj-data-fluid_phase__make_box__adb_18.log) | 27 | 3 | 0 | 88.0 |
| `Make_Ellipsoid` | `mj-data-fluid_phase.adb:46` | [proof_timeout](logs/mj-data-fluid_phase__make_ellipsoid__adb_46.log) | 0 | 0 | 0 | 150.1 |
| `Append_Element` | `mj-data-fluid_phase.adb:102` | [completed_no_unproved](logs/mj-data-fluid_phase__append_element__adb_102.log) | 8 | 0 | 0 | 5.4 |
| `Build` | `mj-data-fluid_phase.adb:118` | [proof_timeout](logs/mj-data-fluid_phase__build__adb_118.log) | 0 | 0 | 0 | 150.3 |
| `Initialize` | `mj-data-fluid_phase.adb:205` | [completed_no_unproved](logs/mj-data-fluid_phase__initialize__adb_205.log) | 7 | 0 | 0 | 23.8 |
| `Release` | `mj-data-fluid_phase.adb:12` | [completed_no_unproved](logs/mj-data-fluid_phase__release__adb_12.log) | 1 | 0 | 0 | 6.2 |

## Diagnostics

### mj-data-fluid_phase__make_box__adb_18

- `mj-data-fluid_phase.adb:24` (medium): postcondition might fail [provers reached time and memory limit before completing the proof]
- `mj-data-fluid_phase.adb:40` (medium): assertion might fail [provers reached time and memory limit before completing the proof]
- `mj-data-fluid_phase.adb:41` (medium): float overflow check might fail [reason for check: result of floating-point addition must be bounded] [provers reached time and memory limit before completing the proof]

