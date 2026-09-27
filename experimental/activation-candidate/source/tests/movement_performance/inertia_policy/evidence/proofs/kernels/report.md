# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-i3vzcqne/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Clamp_Pivot` | `mj-solver_kernels.adb:2` | [completed_no_unproved](logs/mj-solver_kernels__clamp_pivot__adb_2.log) | 2 | 0 | 0 | 3.6 |
| `Reciprocal` | `mj-solver_kernels.adb:4` | [completed_no_unproved](logs/mj-solver_kernels__reciprocal__adb_4.log) | 6 | 0 | 0 | 2.8 |
| `Scale` | `mj-solver_kernels.adb:5` | [completed_no_unproved](logs/mj-solver_kernels__scale__adb_5.log) | 4 | 0 | 0 | 2.8 |
| `Add_Product` | `mj-solver_kernels.adb:7` | [completed_no_unproved](logs/mj-solver_kernels__add_product__adb_7.log) | 6 | 0 | 0 | 2.8 |

## Diagnostics

