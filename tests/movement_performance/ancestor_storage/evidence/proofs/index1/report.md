# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-32yvuwon/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Row_OK` | `mj-ancestor_rows.ads:51` | [unproved_checks](logs/mj-ancestor_rows__row_ok__ads_51.log) | 38 | 1 | 0 | 4.1 |
| `Start` | `mj-ancestor_rows.ads:77` | [completed_no_unproved](logs/mj-ancestor_rows__start__ads_77.log) | 6 | 0 | 0 | 2.8 |
| `Length` | `mj-ancestor_rows.ads:78` | [completed_no_unproved](logs/mj-ancestor_rows__length__ads_78.log) | 14 | 0 | 0 | 3.1 |
| `Column` | `mj-ancestor_rows.ads:80` | [completed_no_unproved](logs/mj-ancestor_rows__column__ads_80.log) | 15 | 0 | 0 | 3.1 |
| `Parent` | `mj-ancestor_rows.ads:82` | [completed_no_unproved](logs/mj-ancestor_rows__parent__ads_82.log) | 9 | 0 | 0 | 2.9 |

## Diagnostics

### mj-ancestor_rows__row_ok__ads_51

- `mj-ancestor_rows.ads:58` (medium): overflow check might fail, cannot prove lower bound for Starts (Columns (A) + 1) - Starts (Columns (A)) [reason for check: result of subtraction must fit in a 32-bits machine integer] [possible fix: precondition of subprogram at line 51 should mention Columns and Starts] [provers gave up before completing the proof]

