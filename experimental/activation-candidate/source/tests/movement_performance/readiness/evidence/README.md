# Readiness and deferred Jacobian evidence

Recorded 2026-09-24. `build.json` identifies the pre-refactor Compatible baseline,
current release and checked binaries, source hashes and unchanged native SIMD C
reference. Sources, executables and reference library hashes were verified before
archiving. `build-inputs.zip` contains the source snapshot, baseline overlay,
projects, logs and harness inputs. Absolute temporary paths are historical.

`first.json` and `repeat.json` contain 15 cases and 1,080 process runs each, with
paired 95% bootstrap intervals, MAD and trajectory-average p95. Their raw ZIPs
retain initial states, MJB/XML models, expected results and process output.
`summary.json` takes medians across three states separately in each session;
it does not pool confidence intervals. The report explains the small 1-DOF
change and the lack of multiple-comparison correction.

`compatible.json` and `strict.json` each record 480 scenarios and 78,720 oracle
comparisons. `exact.json` records byte equality of all 34 emitted output files
per policy against the preceding policy build. Those previous outputs are in
`prior-outputs.zip`; current outputs, inputs and models are in the policy raw
ZIPs. `boundaries.json` and its ZIP preserve 85 cases / 170 reset/retry scenarios.
The C-general-path and edited-armature qualifications from the policy report
continue to apply.

`caches.json` and its raw ZIP preserve an extra 480-scenario checked suite with
exact eager/lazy cache comparisons and lifecycle checks. `cache-probe-inputs.zip`
retains that test-only child and its checked build inputs. `profile.json` records
120 runs with outputs identical to release and counts of six readiness calls per
step, zero Jacobian construction on fast multi-DOF paths, and one materialization
shared by the one-DOF fallbacks. The profile input/raw ZIPs and manifest identify
the instrumentation. Its timers include clock overhead and compiler perturbation;
phase times can be nested and are not interchangeable with release measurements.

`proofs/` retains bounded attempts, including errors and incomplete results:

- `helpers-final`: readiness equivalence 1 check, configuration equality 22,
  configuration transitivity 22, input equality 7, invalidation 1. All closed on
  the final source. Invalidation retains its unused-initial-value warning.
- `wrapper-units`: complete Forward and Kinematics wrapper units, 4 and 10 closed
  checks. These compose callee contracts; they do not establish callee bodies.
- `step-call`: the one precondition check at Euler's private entry call, closed.
- `compose3`: 40/41 checks closed; State_Values preservation remains open.
- `jacobians`: 26/36 checks closed in the short diagnostic. Loop/frame/index
  and preservation obligations remain open.
- `integrate` and `actuation`: initial bounded runs timed out. Zero reported
  proof checks is not a pass.
- Earlier names retain the incremental diagnosis. The first `kinematics` attempt
  omitted its unit from the proof project; the harness was corrected. Earlier
  open attempts are not replaced by or counted as successful proof results.

Proof manifests map source paths to SHA256. `proof-source-objects.zip` contains
each unique source under its hash; copy the corresponding member to each mapped
path to reconstruct a snapshot. The current full pipeline is not claimed Gold
or Silver merely because wrappers or tests pass. See the main report for scope.

`manifest.json` authenticates this evidence and the relevant current source,
harness and documentation. Earlier experiment archives remain unchanged.
