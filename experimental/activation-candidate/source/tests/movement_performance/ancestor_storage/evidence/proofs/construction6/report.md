# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-cjg2gncz/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prove_Row_Frame` | `mj-ancestor_rows.adb:50` | [analysis_error](logs/mj-ancestor_rows__prove_row_frame__adb_50.log) | 0 | 0 | 2 | 1.9 |
| `Append_Row` | `mj-ancestor_rows.adb:60` | not_run_analysis | 0 | 0 | 0 | 0.0 |

## Diagnostics

### mj-ancestor_rows__prove_row_frame__adb_50

- `mj-ancestor_rows.adb:51` (error): aspect specifications must come after subprogram specification
- `mj-ancestor_rows.adb:58` (error): expression function must be enclosed in parentheses

