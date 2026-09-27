# Recorded dynamics optimization evidence

Recorded on 2026-09-24. `summary.json` contains the observed ranges across the
three states and two sessions, not confidence intervals for pooled workloads.
`first.json` and `repeat.json` retain every timing sample and paired per-case
95% bootstrap interval. Both runs completed, with 1,080 process invocations
each; the raw ZIPs retain models, initial states, expected states and stdout.

`build.json` records source hashes, compiler flags/versions, commands and binary
hashes for frozen baseline, active release, checked active probe and native C.
`build-inputs.zip` preserves their source and project inputs and the harness.
The baseline is reconstructed by overlaying the complete `baseline/` directory
on the current snapshot's `experimental/smooth/src/`, first removing that
directory's current Ada sources (including the new spatial package).
The build script performs this operation in an isolated temporary snapshot.
`c-build/` is the unchanged upstream C build provenance from the earlier
experiment; its library hash matches this run. No C source optimization was
disabled for the comparison. Executables themselves are not checked in.

`checked-numerics.json` and its ZIP retain 480 scenarios / 78,720 comparisons
with the checked probe, seven normalization boundary cases and 14 policy cases.
The probe hash matches `build.json`. Numerical tolerance is not a proof or a
worst-case error bound.

## Formal evidence

The reports preserve the actual chronological source variants, including
failed attempts and timeouts. They must not be summed into a whole-pipeline
proof claim. The useful final/local results are:

| Report directory under `proofs/` | Scope and result |
|---|---|
| `spatial-unit-final` | Complete spatial kernel unit: 413 proof checks, zero open |
| `spatial-frame-small`, `spatial-add-fields`, `spatial-pack-fields` | Minimal routines checked before the final whole-unit run |
| `reuse-final-proof` | Five cache/scaled-pivot routines, all closed |
| `body-forces-fields` | Center acceleration and inertial torque, both closed |
| `body-forces-small` | Mass_Force closed; the other two earlier failures are superseded by `body-forces-fields` |
| `symmetry-element-final` | Corrected element symmetry lemma, closed |
| `symmetric-small` | Offset identity, update lemma and symmetric store closed; earlier element-lemma timeout superseded above |
| `damping-small` | Damping_Present closed |
| `crb-compose-release` | Final CRB orchestration: 174 checks, 75 open diagnostics |
| `rne-compose-final` | Final recursive-force orchestration: 89 checks, 45 open diagnostics |

The last two are bounded diagnostics with CVC5, one second per obligation,
level zero. These counts describe those invocations, not impossibility of
proof. No whole-state/dynamics or Silver claim is made. Earlier `*-final`
directory names reflect intermediate development attempts; use the table
above and source hashes to disambiguate them.

Every report has its own `manifest.json` with source path→SHA256 mapping.
`proof-source-objects.zip` stores each unique source file once, named by its
SHA256. Reconstruct an exact proof snapshot by copying each ZIP member to the
relative path in that report's mapping. Recorded absolute `/tmp` paths are
historical. Local helper bodies/contracts retained after their minimal proof
are not a claim that the later whole `MJ.Smooth_Dynamics` unit closes.

`manifest.json` authenticates this evidence plus the relevant current sources,
fixtures, harness and documentation. Historical evidence outside this directory
was not rewritten.
