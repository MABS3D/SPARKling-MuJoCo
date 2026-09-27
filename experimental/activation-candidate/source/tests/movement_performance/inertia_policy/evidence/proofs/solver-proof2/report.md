# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-b4dv7b7h/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Solve_Compatible` | `mj-data-inertia.adb:315` | [unproved_checks](logs/mj-data-inertia__solve_compatible__adb_315.log) | 118 | 58 | 0 | 66.6 |

## Diagnostics

### mj-data-inertia__solve_compatible__adb_315

- `mj-data-inertia.adb:319` (medium): postcondition might fail, cannot prove Is_Ready (D) [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:319` (medium): in inlined expression function body at mj-data-inertia.adb:319
- `mj-data-inertia.adb:334` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove X in -Limit .. Limit [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:334` (medium): in inlined expression function body at mj-data.ads:488
- `mj-data-inertia.adb:335` (medium): array index check might fail [reason for check: result of addition must be a valid index into the array] [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:342` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove X in -Limit .. Limit [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:342` (medium): in inlined expression function body at mj-data.ads:488
- `mj-data-inertia.adb:343` (medium): range check might fail [reason for check: input value must fit in parameter type] [provers reached time limit before completing the proof]
- 50 more diagnostics in the individual log.

