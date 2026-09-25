# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-r7x45noj/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Offset_Identity` | `mj-smooth_dynamics.adb:124` | [completed_no_unproved](logs/mj-smooth_dynamics__offset_identity__adb_124.log) | 13 | 0 | 0 | 3.9 |
| `Prove_Symmetric_Element` | `mj-smooth_dynamics.adb:129` | [unproved_checks](logs/mj-smooth_dynamics__prove_symmetric_element__adb_129.log) | 47 | 1 | 0 | 11.4 |
| `Prove_Symmetry_After_Update` | `mj-smooth_dynamics.adb:153` | [completed_no_unproved](logs/mj-smooth_dynamics__prove_symmetry_after_update__adb_153.log) | 22 | 0 | 0 | 12.5 |
| `Store_Symmetric` | `mj-smooth_dynamics.adb:172` | [completed_no_unproved](logs/mj-smooth_dynamics__store_symmetric__adb_172.log) | 16 | 0 | 0 | 5.4 |

## Diagnostics

### mj-smooth_dynamics__prove_symmetric_element__adb_129

- `mj-smooth_dynamics.adb:144` (medium): assertion might fail [provers reached time limit before completing the proof]

