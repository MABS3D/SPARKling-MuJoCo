# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-49debiw5/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Make_Ellipsoid` | `mj-data-fluid_phase.adb:46` | [unproved_checks](logs/mj-data-fluid_phase__make_ellipsoid__adb_46.log) | 87 | 45 | 0 | 56.0 |
| `Build` | `mj-data-fluid_phase.adb:118` | [unproved_checks](logs/mj-data-fluid_phase__build__adb_118.log) | 80 | 16 | 0 | 38.2 |
| `Build_Wrenches` | `mj-data-fluid_phase.adb:214` | [unproved_checks](logs/mj-data-fluid_phase__build_wrenches__adb_214.log) | 163 | 104 | 0 | 79.8 |

## Diagnostics

### mj-data-fluid_phase__make_ellipsoid__adb_46

- `mj-data-fluid_phase.adb:52` (medium): divide by zero might fail [possible fix: add precondition (Mass /= 0) to subprogram at line 46] [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:53` (medium): postcondition might fail, cannot prove E.Position = Read_Vector (M.Geoms.Geom_Pos.all, 3*G) [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:53` (medium): precondition might fail, cannot prove Offset >= A'First [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:53` (medium): pointer dereference check might fail [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:54` (medium): pointer dereference check might fail [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:55` (medium): pointer dereference check might fail [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:56` (medium): pointer dereference check might fail [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:57` (medium): pointer dereference check might fail [provers reached time limit before completing the proof]
- 37 more diagnostics in the individual log.

### mj-data-fluid_phase__build__adb_118

- `mj-data-fluid_phase.adb:160` (medium): pointer dereference check might fail [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:160` (medium): array index check might fail [reason for check: value must be a valid index into the array] [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:169` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Elements'First = 0 [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:169` (medium): range check might fail, cannot prove upper bound for Elements'Length [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:171` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove FK.Element_Valid (Elements (I), Nb) [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:171` (medium): array index check might fail [reason for check: value must be a valid index into the array] [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:177` (medium): precondition might fail, cannot prove abs (((Q (0)*Q (0) + Q (1)*Q (1)) + Q (2)*Q (2)) + Q (3)*Q (3) - 1.0) <= 64.0 * Real'Model_Epsilon [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:177` (medium): in inlined expression function body at mj-smooth_math.ads:107
- 8 more diagnostics in the individual log.

### mj-data-fluid_phase__build_wrenches__adb_214

- `mj-data-fluid_phase.adb:225` (medium): postcondition might fail, cannot prove V (0) in -Limit .. Limit [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:225` (medium): in inlined expression function body at mj-smooth_math.ads:19
- `mj-data-fluid_phase.adb:247` (medium): precondition might fail, cannot prove V (0) in -Limit .. Limit [possible fix: loop at line 241 should mention Linear in a loop invariant] [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:247` (medium): in inlined expression function body at mj-smooth_math.ads:19
- `mj-data-fluid_phase.adb:247` (medium): precondition might fail, cannot prove V (0) in -Limit .. Limit [possible fix: loop at line 241 should mention Angular in a loop invariant] [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:247` (medium): in inlined expression function body at mj-smooth_math.ads:19
- `mj-data-fluid_phase.adb:248` (medium): precondition might fail, cannot prove V (0) in -Limit .. Limit [provers reached time limit before completing the proof]
- `mj-data-fluid_phase.adb:248` (medium): in inlined expression function body at mj-smooth_math.ads:19
- 96 more diagnostics in the individual log.

