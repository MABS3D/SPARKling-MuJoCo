# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-ciwyjd5c/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `whole unit` | `mj-solver_kernels.adb:1` | [analysis_error](logs/mj-solver_kernels__whole_unit.log) | 0 | 0 | 2 | 1.8 |
| `whole unit` | `mj-bounds_kernels.adb:1` | not_run_analysis | 0 | 0 | 0 | 0.0 |

## Diagnostics

### mj-solver_kernels__whole_unit

- `mj-solver_kernels.adb:25` (error): quantified expression must be parenthesized
- `mj-solver_kernels.adb:43` (error): quantified expression must be parenthesized

