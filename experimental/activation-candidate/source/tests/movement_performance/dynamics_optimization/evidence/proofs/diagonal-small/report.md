# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-sqp7qm2h/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prepare_Scaled_Diagonal` | `mj-smooth_dynamics.adb:83` | [unproved_checks](logs/mj-smooth_dynamics__prepare_scaled_diagonal__adb_83.log) | 24 | 3 | 0 | 28.9 |

## Diagnostics

### mj-smooth_dynamics__prepare_scaled_diagonal__adb_83

- `mj-smooth_dynamics.adb:91` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Pivots (K) = Factor (K * N + K) / Scale [provers reached time limit before completing the proof]
- `mj-smooth_dynamics.adb:91` (medium): array index check might fail [reason for check: result of addition must be a valid index into the array] [provers reached time limit before completing the proof]
- `mj-smooth_dynamics.ads:67` (medium): range check might fail, cannot prove upper bound for Pivots'Length [provers reached time limit before completing the proof]

