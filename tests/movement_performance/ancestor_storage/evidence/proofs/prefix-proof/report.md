# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-0x97fk_2/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Dense_Prefix_Start` | `mj-ancestor_rows.ads:119` | [completed_no_unproved](logs/mj-ancestor_rows__dense_prefix_start__ads_119.log) | 11 | 0 | 0 | 3.4 |
| `Build_Offsets` | `mj-ancestor_rows.adb:42` | [unproved_checks](logs/mj-ancestor_rows__build_offsets__adb_42.log) | 81 | 1 | 0 | 28.1 |
| `Append_Row` | `mj-ancestor_rows.adb:90` | [completed_no_unproved](logs/mj-ancestor_rows__append_row__adb_90.log) | 210 | 0 | 0 | 27.6 |

## Diagnostics

### mj-ancestor_rows__build_offsets__adb_42

- `mj-ancestor_rows.adb:64` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Starts (J) <= Starts (K) [provers reached time limit before completing the proof]

