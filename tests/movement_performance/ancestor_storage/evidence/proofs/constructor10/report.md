# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-to9eu5na/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Build` | `mj-ancestor_rows.adb:146` | [unproved_checks](logs/mj-ancestor_rows__build__adb_146.log) | 54 | 1 | 0 | 28.4 |

## Diagnostics

### mj-ancestor_rows__build__adb_146

- `mj-ancestor_rows.adb:162` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove P.Columns (Starts (J + 1) - 2) = Parents (J) [provers reached time limit before completing the proof]

