# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-fim86p0z/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Store_Velocity` | `mj-data-forces_phase.adb:197` | [completed_no_unproved](logs/mj-data-forces_phase__store_velocity__adb_197.log) | 9 | 0 | 0 | 28.6 |
| `Forward_Bodies` | `mj-data-forces_phase.adb:211` | [completed_no_unproved](logs/mj-data-forces_phase__forward_bodies__adb_211.log) | 80 | 0 | 0 | 66.7 |

## Diagnostics

