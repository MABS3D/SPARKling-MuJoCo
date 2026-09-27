# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-7o16px77/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Complete_Passive` | `mj-data-forces_phase.adb:713` | [unproved_checks](logs/mj-data-forces_phase__complete_passive__adb_713.log) | 21 | 3 | 0 | 78.7 |
| `Complete_Passive` | `mj-data-forces_phase.adb:732` | [unproved_checks](logs/mj-data-forces_phase__complete_passive__adb_732.log) | 21 | 3 | 0 | 6.1 |
| `Compute_Ready` | `mj-data-forces_phase.adb:1040` | [analysis_error](logs/mj-data-forces_phase__compute_ready__adb_1040.log) | 0 | 0 | 4 | 2.8 |
| `Forward_Bodies` | `mj-data-forces_phase.adb:196` | not_run_analysis | 0 | 0 | 0 | 0.0 |

## Diagnostics

### mj-data-forces_phase__complete_passive__adb_713

- `mj-data-forces_phase.adb:718` (medium): postcondition might fail [provers reached time limit before completing the proof]
- `mj-data-forces_phase.adb:752` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-data-forces_phase.adb:753` (medium): precondition might fail [provers reached time limit before completing the proof]

### mj-data-forces_phase__complete_passive__adb_732

- `mj-data-forces_phase.adb:718` (medium): postcondition might fail [provers reached time limit before completing the proof]
- `mj-data-forces_phase.adb:752` (medium): assertion might fail [provers reached time limit before completing the proof]
- `mj-data-forces_phase.adb:753` (medium): precondition might fail [provers reached time limit before completing the proof]

### mj-data-forces_phase__compute_ready__adb_1040

- `mj-data-forces_phase.adb:1076` (error): subtype constraint cannot depend on variable input "D" [E0007]
- `mj-data-forces_phase.adb:1076` (error): use instead a constant initialized to the expression with variable input
- `mj-data-forces_phase.adb:1076` (error): launch "gnatprove --explain=E0007" for more information
- `mj-data-forces_phase.adb:1076` (error): subtype constraint cannot depend on variable input "D"

