# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-aqkogr4l/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `whole unit` | `mj-data-jacobians.adb:1` | [completed_no_unproved](logs/mj-data-jacobians__whole_unit.log) | 102 | 0 | 0 | 52.9 |
| `whole unit` | `mj-data-forward.adb:1` | [completed_no_unproved](logs/mj-data-forward__whole_unit.log) | 4 | 0 | 0 | 16.0 |
| `whole unit` | `mj-data-kinematics.adb:1` | [completed_no_unproved](logs/mj-data-kinematics__whole_unit.log) | 10 | 0 | 0 | 29.9 |

## Diagnostics

