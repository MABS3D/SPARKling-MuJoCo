# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-eur_xrmc/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Build` | `mj-data-jacobians.adb:25` | [unproved_checks](logs/mj-data-jacobians__build__adb_25.log) | 57 | 5 | 0 | 53.0 |

## Diagnostics

### mj-data-jacobians__build__adb_25

- `mj-data-jacobians.adb:38` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Linear (I) = 0.0 [provers reached time limit before completing the proof]
- `mj-data-jacobians.adb:47` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Linear (I) = 0.0 [provers reached time limit before completing the proof]
- `mj-data-jacobians.adb:54` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Linear (I) = 0.0 [provers reached time limit before completing the proof]
- `mj-data-jacobians.ads:54` (medium): postcondition might fail, cannot prove Linear (I) = 0.0 [provers reached time limit before completing the proof]
- `mj-data-jacobians.ads:54` (medium): array index check might fail [reason for check: value must be a valid index into the array] [provers reached time limit before completing the proof]

