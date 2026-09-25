# Recorded policy and profiling evidence

Recorded 2026-09-24. `build.json` identifies the frozen pre-policy baseline,
active Compatible binary, checked probe and native C reference. Active Ada
sources and the executable/library hashes were verified before archival.
`build-inputs.zip` retains sources, the baseline overlay, projects, build logs,
fixtures and harness. `c-build/` preserves the unchanged C build provenance.

`first.json` and `repeat.json` each contain 15 cases / 1,080 process runs and
paired block-median bootstrap intervals. Their raw ZIPs contain the MJB, XML,
initial states, expected final states and all process outputs. `summary.json`
reports observed ranges across six state/session estimates, not pooled CIs.

`compatible.json` and `strict.json` each contain 480 scenarios and 78,720
numeric comparisons. The corresponding raw ZIPs retain complete inputs/outputs.
Both historical rejection suites explicitly select Strict. `boundaries.json`
and its ZIP contain 85 targeted cases run twice after Reset (170 scenarios),
including Compatible numeric-domain failures. The saved model files include
the armature edits described in the main report and test source.

`strict-exact.json` records the comparison of all previously emitted fields
against `../../dynamics_optimization/evidence/checked-numerics.zip`: 480 scenarios,
79,680 scalar fields including status strings, numerically identical. New warning
fields are excluded. The original archive remains unchanged.

## Proof scope

* `proofs/kernels`: four minimal scalar routines, all closed.
* `proofs/kernels-unit`: complete `MJ.Solver_Kernels`, 18 checks, zero open.
* `proofs/solver-proof`: an earlier analysis error in conditional Old attributes;
  corrected in the next snapshot. It is not a proof pass.
* `proofs/solver-proof2`: final composed solver, 118 checks / 58 open diagnostics
  with CVC5 and one second per obligation. No whole-solver Gold/Silver claim.

Each proof manifest maps relative source paths to SHA256 values.
`proof-source-objects.zip` contains each unique source once, named by its hash;
reconstruct the exact snapshot by copying those members to their mapped paths.
Absolute temporary paths in logs are historical. No proof claim is inferred
from numerical tests or from a zero-obligation compiler invocation.

## Profile scope

`profile.json` has 120 instrumented runs whose outputs equal the current release
binary numerically. The raw ZIP retains every output. `profile-inputs.zip` and
`profile-manifest.json` preserve the instrumented sources, build and binary hash.
Instrumentation was built and run separately from the two release measurements.
Times include clock overhead and compiler perturbations; nested phases cannot
be added to their parents. Copies are included in enclosing phases, not all
measured individually. Counts confirm zero condition checks and zero dense
fallbacks in the measured multi-DOF cases.

`manifest.json` records hashes for this evidence and relevant current source,
harness and documentation files. No prior evidence archive was rewritten.
