# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-rpho_7ci/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Make_Inertia` | `mj-spatial_kernels.adb:31` | [unproved_checks](logs/mj-spatial_kernels__make_inertia__adb_31.log) | 44 | 1 | 0 | 34.2 |
| `Angular_Component` | `mj-spatial_kernels.adb:56` | [completed_no_unproved](logs/mj-spatial_kernels__angular_component__adb_56.log) | 39 | 0 | 0 | 3.1 |
| `Linear_Component` | `mj-spatial_kernels.adb:71` | [completed_no_unproved](logs/mj-spatial_kernels__linear_component__adb_71.log) | 15 | 0 | 0 | 2.9 |
| `Multiply` | `mj-spatial_kernels.adb:80` | [unproved_checks](logs/mj-spatial_kernels__multiply__adb_80.log) | 100 | 1 | 0 | 13.8 |
| `Joint_Motion` | `mj-spatial_kernels.adb:105` | [unproved_checks](logs/mj-spatial_kernels__joint_motion__adb_105.log) | 22 | 1 | 0 | 13.8 |
| `Wrench` | `mj-spatial_kernels.adb:116` | [completed_no_unproved](logs/mj-spatial_kernels__wrench__adb_116.log) | 35 | 0 | 0 | 15.1 |
| `Add_Wrenches` | `mj-spatial_kernels.adb:128` | [completed_no_unproved](logs/mj-spatial_kernels__add_wrenches__adb_128.log) | 11 | 0 | 0 | 4.3 |

## Diagnostics

### mj-spatial_kernels__make_inertia__adb_31

- `mj-spatial_kernels.ads:51` (medium): postcondition might fail, cannot prove Bounded (Make_Inertia'Result, 1.0e36) [provers reached time and memory limit before completing the proof]

### mj-spatial_kernels__multiply__adb_80

- `mj-spatial_kernels.ads:77` (medium): postcondition might fail, cannot prove Multiply'Result = [Angular_Component (I (0), I (3), I (4), I (8), I (7), V (0), V (1), V (2), V (4), V (5), False), Angular_Component (I (3), I (1), I (5), I (8), I (6), V (0), V (1), V (2), V (3), V (5), True), Angular_Component (I (4), I (5), I (2), I (7... [provers reached time and memory limit before completing the proof]

### mj-spatial_kernels__joint_motion__adb_105

- `mj-spatial_kernels.ads:92` (medium): postcondition might fail, cannot prove Bounded (Joint_Motion'Result, 1.0e12) [provers reached time limit before completing the proof]

