# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-4mtoqess/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Center_Acceleration` | `mj-smooth_dynamics.adb:49` | [unproved_checks](logs/mj-smooth_dynamics__center_acceleration__adb_49.log) | 23 | 1 | 0 | 21.0 |
| `Mass_Force` | `mj-smooth_dynamics.adb:61` | [completed_no_unproved](logs/mj-smooth_dynamics__mass_force__adb_61.log) | 7 | 0 | 0 | 4.1 |
| `Inertial_Torque` | `mj-smooth_dynamics.adb:65` | [unproved_checks](logs/mj-smooth_dynamics__inertial_torque__adb_65.log) | 16 | 1 | 0 | 19.3 |

## Diagnostics

### mj-smooth_dynamics__center_acceleration__adb_49

- `mj-smooth_dynamics.ads:30` (medium): postcondition might fail, cannot prove Center_Acceleration'Result = (Linear_Bias + Cross_Local (Angular_Bias, Offset)) + Cross_Transport (Angular_Velocity, Cross_Local (Angular_Velocity, Offset)) [provers reached time limit before completing the proof]

### mj-smooth_dynamics__inertial_torque__adb_65

- `mj-smooth_dynamics.ads:42` (medium): postcondition might fail, cannot prove Inertial_Torque'Result = MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Angular_Bias) + Cross_Transport (Angular_Velocity, MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Angular_Velocity)) [provers reached time limit before completing the proof]

