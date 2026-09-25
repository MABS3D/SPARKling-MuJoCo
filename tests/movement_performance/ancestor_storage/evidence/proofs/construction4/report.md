# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-j9pye8uf/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Row_OK` | `mj-ancestor_rows.ads:60` | [completed_no_unproved](logs/mj-ancestor_rows__row_ok__ads_60.log) | 65 | 0 | 0 | 4.7 |
| `Copy_Row` | `mj-ancestor_rows.adb:2` | [unproved_checks](logs/mj-ancestor_rows__copy_row__adb_2.log) | 46 | 9 | 0 | 55.5 |
| `Build_Offsets` | `mj-ancestor_rows.adb:23` | [completed_no_unproved](logs/mj-ancestor_rows__build_offsets__adb_23.log) | 63 | 0 | 0 | 17.4 |
| `Append_Row` | `mj-ancestor_rows.adb:49` | [unproved_checks](logs/mj-ancestor_rows__append_row__adb_49.log) | 47 | 1 | 0 | 13.1 |
| `Build` | `mj-ancestor_rows.adb:72` | [unproved_checks](logs/mj-ancestor_rows__build__adb_72.log) | 44 | 1 | 0 | 18.9 |

## Diagnostics

### mj-ancestor_rows__copy_row__adb_2

- `mj-ancestor_rows.adb:6` (medium): range check might fail [reason for check: slice bounds must fit in the underlying array] [possible fix: precondition of subprogram at mj-ancestor_rows.ads:32 should mention Dense] [provers reached time limit before completing the proof]
- `mj-ancestor_rows.adb:9` (medium): array index check might fail [reason for check: result of addition must be a valid index into the array] [provers reached time limit before completing the proof]
- `mj-ancestor_rows.adb:10` (medium): "Target" might not be initialized
- `mj-ancestor_rows.adb:11` (medium): array index check might fail [reason for check: result of addition must be a valid index into the array] [provers reached time limit before completing the proof]
- `mj-ancestor_rows.ads:33` (medium): "Target" might not be initialized in "Copy_Row" [reason for check: OUT parameter should be fully initialized on return] [possible fix: initialize "Target" on all paths, make "Target" an IN OUT parameter or annotate it with aspect Relaxed_Initialization]
- `mj-ancestor_rows.ads:36` (medium): range check might fail, cannot prove upper bound for Dense'Length [provers reached time limit before completing the proof]
- `mj-ancestor_rows.ads:37` (medium): range check might fail, cannot prove upper bound for Target'Length [provers reached time limit before completing the proof]
- `mj-ancestor_rows.ads:38` (medium): "Target" might not be initialized
- 1 more diagnostics in the individual log.

### mj-ancestor_rows__append_row__adb_49

- `mj-ancestor_rows.adb:59` (medium): postcondition might fail, cannot prove Row_OK (Starts, Columns, J) [provers reached time limit before completing the proof]

### mj-ancestor_rows__build__adb_72

- `mj-ancestor_rows.adb:85` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove P.Columns (Starts (J + 1) - 2) = Parents (J) [provers reached time limit before completing the proof]

