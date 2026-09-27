# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-meexc6q2/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Center_Acceleration` | `mj-smooth_dynamics.adb:49` | [completed_no_unproved](logs/mj-smooth_dynamics__center_acceleration__adb_49.log) | 33 | 0 | 0 | 16.5 |
| `Inertial_Torque` | `mj-smooth_dynamics.adb:65` | [completed_no_unproved](logs/mj-smooth_dynamics__inertial_torque__adb_65.log) | 24 | 0 | 0 | 22.7 |

## Diagnostics

