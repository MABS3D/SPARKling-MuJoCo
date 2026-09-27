# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-im097v9b/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Add_Row` | `mj-solver_kernels.adb:12` | [completed_no_unproved](logs/mj-solver_kernels__add_row__adb_12.log) | 24 | 0 | 0 | 6.6 |
| `Scale_Row` | `mj-solver_kernels.adb:32` | [completed_no_unproved](logs/mj-solver_kernels__scale_row__adb_32.log) | 12 | 0 | 0 | 4.1 |

## Diagnostics

