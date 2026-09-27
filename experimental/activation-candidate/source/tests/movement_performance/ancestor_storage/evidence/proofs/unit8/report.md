# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-bp3kzx_l/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `whole unit` | `mj-ancestor_rows.adb:1` | [unproved_checks](logs/mj-ancestor_rows__whole_unit.log) | 706 | 1 | 0 | 135.2 |

## Diagnostics

### mj-ancestor_rows__whole_unit

- `mj-ancestor_rows.adb:159` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove P.Columns (Starts (J + 1) - 2) = Parents (J) [provers reached time limit before completing the proof]

