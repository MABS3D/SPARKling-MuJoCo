# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-u6y_rf2_/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Accumulate` | `mj-data-fluid_phase.adb:312` | [unproved_checks](logs/mj-data-fluid_phase__accumulate__adb_312.log) | 20 | 1 | 0 | 110.2 |
| `Make_Box` | `mj-data-fluid_phase.adb:18` | [completed_no_unproved](logs/mj-data-fluid_phase__make_box__adb_18.log) | 25 | 0 | 0 | 56.3 |

## Diagnostics

### mj-data-fluid_phase__accumulate__adb_312

- `mj-data-fluid_phase.adb:331` (warning): "Forces" is set by "Fold" but not used after the call
- `mj-data-fluid_phase.adb:331` (warning): "Torques" is set by "Fold" but not used after the call
- `mj-data-fluid_phase.ads:32` (medium): postcondition might fail [provers reached time limit before completing the proof]

