# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-x3gmqxq2/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Lever_Component` | `mj-fluid_transport.adb:5` | [completed_no_unproved](logs/mj-fluid_transport__lever_component__adb_5.log) | 13 | 0 | 0 | 5.9 |
| `Lever_Torque` | `mj-fluid_transport.adb:15` | [completed_no_unproved](logs/mj-fluid_transport__lever_torque__adb_15.log) | 32 | 0 | 0 | 14.7 |
| `Project` | `mj-fluid_transport.adb:21` | [completed_no_unproved](logs/mj-fluid_transport__project__adb_21.log) | 10 | 0 | 0 | 15.3 |
| `Merge` | `mj-fluid_transport.adb:26` | [completed_no_unproved](logs/mj-fluid_transport__merge__adb_26.log) | 16 | 0 | 0 | 7.9 |
| `Project_Into` | `mj-data-fluid_tree.adb:2` | [completed_no_unproved](logs/mj-data-fluid_tree__project_into__adb_2.log) | 15 | 0 | 0 | 29.2 |
| `Fold` | `mj-data-fluid_tree.adb:12` | [unproved_checks](logs/mj-data-fluid_tree__fold__adb_12.log) | 47 | 1 | 0 | 41.5 |

## Diagnostics

### mj-data-fluid_tree__fold__adb_12

- `mj-data-fluid_tree.adb:43` (medium): precondition might fail [provers reached time limit before completing the proof]

