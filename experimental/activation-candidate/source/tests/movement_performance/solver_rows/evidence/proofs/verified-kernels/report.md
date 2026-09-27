# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-rllm8tgy/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `whole unit` | `mj-solver_kernels.adb:1` | [completed_no_unproved](logs/mj-solver_kernels__whole_unit.log) | 64 | 0 | 0 | 16.5 |
| `whole unit` | `mj-bounds_kernels.adb:1` | [completed_no_unproved](logs/mj-bounds_kernels__whole_unit.log) | 7 | 0 | 0 | 3.6 |

## Diagnostics

