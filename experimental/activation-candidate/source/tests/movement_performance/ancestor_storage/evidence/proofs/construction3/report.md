# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-jhc0an67/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Row_OK` | `mj-ancestor_rows.ads:60` | [analysis_error](logs/mj-ancestor_rows__row_ok__ads_60.log) | 0 | 0 | 3 | 1.8 |
| `Copy_Row` | `mj-ancestor_rows.adb:2` | not_run_analysis | 0 | 0 | 0 | 0.0 |
| `Build_Offsets` | `mj-ancestor_rows.adb:23` | not_run_analysis | 0 | 0 | 0 | 0.0 |
| `Append_Row` | `mj-ancestor_rows.adb:49` | not_run_analysis | 0 | 0 | 0 | 0.0 |
| `Build` | `mj-ancestor_rows.adb:71` | not_run_analysis | 0 | 0 | 0 | 0.0 |

## Diagnostics

### mj-ancestor_rows__row_ok__ads_60

- `mj-ancestor_rows.ads:71` (error): expression function must be enclosed in parentheses
- `mj-ancestor_rows.ads:73` (error): missing ";"
- `mj-ancestor_rows.ads:74` (error): aspect specifications not allowed here

