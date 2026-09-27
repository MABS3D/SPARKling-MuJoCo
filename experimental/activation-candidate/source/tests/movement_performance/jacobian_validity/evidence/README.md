# Independent Jacobian validity evidence

Recorded 2026-09-24. `build.json` identifies the preceding readiness build as
baseline, current release/checked binaries and native SIMD C reference. Current
sources, binaries, reference library and C++ runtime hashes were verified before
archiving. `build-inputs.zip` retains source, baseline overlay, projects, logs,
harness inputs and the report. Absolute temporary paths are historical.

`first.json` and `repeat.json` each contain 15 cases / 1,080 process runs. Raw ZIPs
retain MJB/XML fixtures, initial states, expected final states and all outputs.
`summary.json` aggregates state-specific medians separately in each session,
not pooled intervals. The report discusses paired 95% intervals, the inconclusive
small 1-DOF change, lack of multiplicity correction and trajectory-average tails.

`compatible.json` and `strict.json` each record 480 scenarios / 78,720 comparisons.
Their raw ZIPs contain all inputs/outputs. `exact.json` records hashes and byte
equality for all 34 output files per mode against the preceding readiness build;
`prior-outputs.zip` preserves those earlier files. `boundaries.json` and its raw
ZIP retain 85 solver-policy cases / 170 reset/retry scenarios with the existing
policy fixture qualifications.

`caches.json` and its raw ZIP retain the separate 480-scenario checked cache suite,
including stale ±1e100 values, incoherent flags, exact eager/rebuilt caches, failed
hinge materialization, retry, other-cache and physical-state preservation.
`cache-inputs.zip` and its manifest preserve the test-only build inputs.

`profile.json` records 120 separate instrumented runs with release-equivalent
outputs. `profile-summary.json` aggregates diagnostic phase times. The profile
input/raw ZIPs and manifest identify the instrumentation. It verifies six entry
checks per step and unchanged construction/solve/fallback counts. Nested timers
include clock overhead and compiler perturbation and are not release attribution.

Proof evidence retains both incremental attempts and final outcomes:

- `final-units`: 102 closed checks in the Jacobians unit; 4/10 in the complete
  public Forward/Kinematics wrapper units.
- `ensure5`: 12 closed checks for materialization/readiness/frame preservation.
- `frame-components`: 28 closed checks for configuration equality from equivalent
  component-wise array premises.
- `helpers-final`: readiness compatibility, valid-Jacobian bounds, and invalidation
  are closed. Invalidation retains its unused-initial-value warning.
- Earlier column, build and wrapper attempts preserve the diagnostics that led
  to corrected null/length premises and proof assertions.
- `reader-boundaries` used wrong line selections; `readers-final` selected the
  calls but also reported zero proof checks. Neither is counted as proof evidence.

The exact column/store contracts and traversal's bounds/initialization/world-row
properties are proved. A full topology-to-physical-Jacobian functional refinement,
other dynamics/state bodies and the complete simulation remain outside these
claims. This is not a whole-pipeline Gold/Silver completion claim.

Proof manifests map source paths to SHA256 values. `proof-source-objects.zip`
contains each unique source under its hash; copy those members to their mapped
paths to reconstruct each snapshot. `manifest.json` authenticates this evidence
and relevant current source/harness/documentation. Earlier archives were not
rewritten.
