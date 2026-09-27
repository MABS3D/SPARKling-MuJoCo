# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-jr6qv5bt/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `whole unit` | `mj-spatial_kernels.adb:1` | [unproved_checks](logs/mj-spatial_kernels__whole_unit.log) | 383 | 1 | 0 | 131.8 |

## Diagnostics

### mj-spatial_kernels__whole_unit

- `mj-spatial_kernels.adb:63` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Result (J) in -3.0e40 .. 3.0e40 [provers reached time limit before completing the proof]

