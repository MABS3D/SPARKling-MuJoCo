# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-sxza7bwt/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Multiply` | `mj-smooth_math.adb:124` | [unproved_checks](logs/mj-smooth_math__multiply__adb_124.log) | 119 | 4 | 0 | 57.2 |

## Diagnostics

### mj-smooth_math__multiply__adb_124

- `mj-smooth_math.adb:159` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-smooth_math.adb:160` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-smooth_math.adb:161` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-smooth_math.adb:162` (medium): assertion might fail [provers reached time limit before completing the proof]

