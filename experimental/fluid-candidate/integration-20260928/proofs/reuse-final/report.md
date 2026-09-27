# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-vx47jecj/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Ready_Properties` | `mj-data-forces_phase.adb:788` | [completed_no_unproved](logs/mj-data-forces_phase__ready_properties__adb_788.log) | 2 | 0 | 0 | 32.0 |
| `Forward_Bodies` | `mj-data-forces_phase.adb:196` | [unproved_checks](logs/mj-data-forces_phase__forward_bodies__adb_196.log) | 79 | 1 | 0 | 57.1 |
| `Recursive_Forces_Buffers` | `mj-data-forces_phase.adb:369` | [completed_no_unproved](logs/mj-data-forces_phase__recursive_forces_buffers__adb_369.log) | 33 | 0 | 0 | 23.6 |
| `Try_Recursive` | `mj-data-forces_phase.adb:415` | [completed_no_unproved](logs/mj-data-forces_phase__try_recursive__adb_415.log) | 9 | 0 | 0 | 14.3 |
| `Publish_Gravity_Bias` | `mj-data-forces_phase.adb:799` | [completed_no_unproved](logs/mj-data-forces_phase__publish_gravity_bias__adb_799.log) | 21 | 0 | 0 | 98.6 |
| `Recursive_Path` | `mj-data-forces_phase.adb:830` | [unproved_checks](logs/mj-data-forces_phase__recursive_path__adb_830.log) | 38 | 1 | 0 | 94.3 |
| `Recursive_Path` | `mj-data-forces_phase.adb:852` | [unproved_checks](logs/mj-data-forces_phase__recursive_path__adb_852.log) | 38 | 1 | 0 | 21.4 |
| `Compute_Ready` | `mj-data-forces_phase.adb:1040` | [unproved_checks](logs/mj-data-forces_phase__compute_ready__adb_1040.log) | 36 | 2 | 0 | 117.2 |

## Diagnostics

### mj-data-forces_phase__forward_bodies__adb_196

- `mj-data-forces_phase.adb:253` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove SK.Bounded (Velocity (K), 1.0e12) [provers reached time limit before completing the proof]

### mj-data-forces_phase__recursive_path__adb_830

- `mj-data-forces_phase.adb:834` (medium): postcondition might fail [provers reached time limit before completing the proof]

### mj-data-forces_phase__recursive_path__adb_852

- `mj-data-forces_phase.adb:834` (medium): postcondition might fail [provers reached time limit before completing the proof]

### mj-data-forces_phase__compute_ready__adb_1040

- `mj-data-forces_phase.adb:1042` (medium): postcondition might fail [provers reached time limit before completing the proof]
- `mj-data-forces_phase.adb:1093` (medium): precondition might fail [provers reached time limit before completing the proof]

