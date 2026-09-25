# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-etygn4eh/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Solve_Compatible` | `mj-data-inertia.adb:320` | [unproved_checks](logs/mj-data-inertia__solve_compatible__adb_320.log) | 101 | 47 | 0 | 63.4 |

## Diagnostics

### mj-data-inertia__solve_compatible__adb_320

- `mj-data-inertia.adb:324` (medium): postcondition might fail, cannot prove Stable_Ready (D) [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:324` (medium): in inlined expression function body at mj-data.ads:593
- `mj-data-inertia.adb:340` (medium): loop invariant might not be preserved by an arbitrary iteration [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:341` (medium): array index check might fail [reason for check: result of addition must be a valid index into the array] [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:348` (medium): loop invariant might not be preserved by an arbitrary iteration [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:348` (medium): loop invariant might fail in first iteration [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:349` (medium): range check might fail [reason for check: input value must fit in parameter type] [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:349` (medium): array index check might fail [reason for check: result of addition must be a valid index into the array] [provers reached time limit before completing the proof]
- 39 more diagnostics in the individual log.

