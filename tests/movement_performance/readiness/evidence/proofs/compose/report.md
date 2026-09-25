# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-jbhjsqv8/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Evaluate_Ready` | `mj-data-pipeline.adb:194` | [unproved_checks](logs/mj-data-pipeline__evaluate_ready__adb_194.log) | 16 | 11 | 0 | 26.8 |

## Diagnostics

### mj-data-pipeline__evaluate_ready__adb_194

- `mj-data-pipeline.adb:212` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:213` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:218` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:219` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:224` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:225` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:230` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:231` (medium): assertion might fail [provers reached time limit before completing the proof]
- 3 more diagnostics in the individual log.

