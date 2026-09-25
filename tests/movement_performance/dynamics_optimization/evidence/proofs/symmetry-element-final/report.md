# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-_vo6a1ek/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prove_Symmetric_Element` | `mj-smooth_dynamics.adb:129` | [completed_no_unproved](logs/mj-smooth_dynamics__prove_symmetric_element__adb_129.log) | 45 | 0 | 0 | 6.9 |

## Diagnostics

