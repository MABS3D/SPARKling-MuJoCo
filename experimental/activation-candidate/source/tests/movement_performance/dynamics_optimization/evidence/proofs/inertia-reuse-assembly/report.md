# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-jlt8aluw/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Add_Mass_Body` | `mj-smooth_dynamics.adb:162` | [unproved_checks](logs/mj-smooth_dynamics__add_mass_body__adb_162.log) | 72 | 15 | 0 | 134.9 |

## Diagnostics

### mj-smooth_dynamics__add_mass_body__adb_162

- `mj-smooth_dynamics.adb:173` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove A (MJ.Smooth_Kernels.Matrix_Offset (N, I, J)) = A (MJ.Smooth_Kernels.Matrix_Offset (N, J, I)) [provers reached time and memory limit before completing the proof]
- `mj-smooth_dynamics.adb:173` (medium): in inlined expression function body at mj-smooth_dynamics.ads:63
- `mj-smooth_dynamics.adb:175` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove A (Row * N + Column) = Body_Entry (Original (Row * N + Column), N, Row, Column, Linear, Angular, Mass, R, Diagonal) [provers reached time limit before completing the proof]
- `mj-smooth_dynamics.adb:176` (medium): array index check might fail [reason for check: result of addition must be a valid index into the array] [provers reached time and memory limit before completing the proof]
- `mj-smooth_dynamics.adb:177` (medium): array index check might fail [reason for check: result of addition must be a valid index into the array] [provers reached time and memory limit before completing the proof]
- `mj-smooth_dynamics.adb:179` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove A (MJ.Smooth_Kernels.Matrix_Offset (N, I, J)) = A (MJ.Smooth_Kernels.Matrix_Offset (N, J, I)) [provers reached time and memory limit before completing the proof]
- `mj-smooth_dynamics.adb:179` (medium): in inlined expression function body at mj-smooth_dynamics.ads:63
- `mj-smooth_dynamics.adb:181` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove A (Row * N + Column) = Body_Entry (Original (Row * N + Column), N, Row, Column, Linear, Angular, Mass, R, Diagonal) [provers reached time limit before completing the proof]
- 7 more diagnostics in the individual log.

