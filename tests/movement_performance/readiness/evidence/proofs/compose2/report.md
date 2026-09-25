# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-3lqw1uqg/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Evaluate_Ready` | `mj-data-pipeline.adb:194` | [unproved_checks](logs/mj-data-pipeline__evaluate_ready__adb_194.log) | 41 | 2 | 0 | 48.0 |

## Diagnostics

### mj-data-pipeline__evaluate_ready__adb_194

- `mj-data-pipeline.adb:226` (medium): precondition might fail, cannot prove B = C [provers reached time limit before completing the proof]
- `mj-data-pipeline.ads:34` (medium): postcondition might fail, cannot prove State_Values (D) = State_Values (D)'Old [provers reached time limit before completing the proof]

