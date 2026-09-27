# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-bvf2v3g4/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Append_Element` | `mj-data-fluid_phase.adb:97` | [unproved_checks](logs/mj-data-fluid_phase__append_element__adb_97.log) | 10 | 1 | 0 | 28.4 |
| `Build` | `mj-data-fluid_phase.adb:113` | [unproved_checks](logs/mj-data-fluid_phase__build__adb_113.log) | 74 | 1 | 0 | 97.5 |
| `Fold` | `mj-data-fluid_tree.adb:12` | [completed_no_unproved](logs/mj-data-fluid_tree__fold__adb_12.log) | 58 | 0 | 0 | 29.8 |

## Diagnostics

### mj-data-fluid_phase__append_element__adb_97

- `mj-data-fluid_phase.adb:100` (medium): range check might fail [provers reached time limit before completing the proof]

### mj-data-fluid_phase__build__adb_113

- `mj-data-fluid_phase.adb:123` (medium): postcondition might fail [provers reached time limit before completing the proof]

