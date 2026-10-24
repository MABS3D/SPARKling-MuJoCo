# Explicit flex elasticity in the owned simulation

`MJ.Data.Flex_Elasticity` adds membrane stretching and bending, tetrahedral
elasticity, edge springs/dampers and their generalized forces to the existing
owned rigid Model/Data pipeline. It owns the compiled topology and coefficients;
C supplies only the test reference. `Evaluate` preserves state and rebuilds the
passive contribution before accumulation. `Step` uses the resulting generalized
forces in Euler integration, including activation advancement. The corpus covers
spring/damper disable flags and muscle actuation.

This entry admits contact-free explicit flexes (`flex_interp=0`). It is not the
combined flex collision/constraint solver; interpolation, contact Jacobian
weighting, flex equalities and contact response use the separate
`MJ.Data.Constrained.Flex` child. Its ordinary-flex integrated acceptance is
recorded below; interpolated movement remains open. The geometric adapter is
in `experimental/flex-state-integration`.

## Verification scope, 2026-10-02

The reference remains official MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. Receipts are in
`evidence/20261002-recovery/` and identify exact frozen source closures.

- The full `MJ.Flex_Elastic_Kernels` unit closes **145 proof checks**, zero open,
  after proving each smallest routine. Contracts cover exact ordered floating
  expressions and bounds for elongation, damping, tension, bending, projection
  and accumulation. Two intermediate assertions expose tension sum bounds;
  no assumption, skipped body or suppression was added.
- The final validation snapshot passes **75/75** samples across 25 models with
  **100 steps** each, using the original `2e-10` absolute/relative tolerances.
  The earlier snapshot passes the same corpus in both validation and release.
  The final allocator/assertion changes have validation evidence; the earlier
  release receipt does not cover those later source edits.
- Integration flow is **open**: after fully initializing owned allocations,
  GNATprove exposes 17 remaining diagnostics, mainly SPARK restrictions on
  renaming through variable access paths, plus diagnostic-array initialization.
  This is unfinished proof engineering, not a Silver-only exception or an
  end-to-end Gold claim. The failed flow log is preserved alongside success logs.
- No integrated performance-parity claim follows from these numerical checks.

The build snapshots dependencies into a supplied external directory and records
SHA-256 hashes. `--resume` refreshes only this entry's source/tests and preserves
frozen shared dependencies. Never extend an older receipt to concurrent edits.

```sh
python3 experimental/flex-elasticity-integration/tests/build.py --out /var/tmp/flex-elasticity-check
/var/tmp/sparkling-movement-env/bin/python experimental/flex-elasticity-integration/tests/compare.py --binary /var/tmp/flex-elasticity-check/build/validation/bin/flex_probe --out /var/tmp/flex-elasticity-cases --samples 3 --steps 100
python3 experimental/flex-elasticity-integration/tests/prove.py --build /var/tmp/flex-elasticity-check --out /var/tmp/flex-elasticity-proof --timeout 10
```

Builds/proofs use `-j1` and the resource guard. The proof runner returns failure
when a selected scope has an open obligation; scalar success does not hide a
failed integration check.

Recovery checkpoint (2026-10-03): the fresh variant 5 validation build passes 75/75 samples at 100 steps. Explicit ownership transfer during model detachment/restoration and initialized workspaces close complete integration flow: 81 checks, zero open, 89 warnings. Scalar kernel sources are unchanged from the 145-check whole-unit proof. This is not a functional proof of the complete step or evidence for integrated flex contact response. Variant 4 failed to build; its accidentally reused variant 3 binary results are explicitly marked invalid for variant 4. See `evidence/20261002-recovery/validation5-*` and `flow5-*`.

## Flat DOF ancestry and integrated acceptance, 2026-10-03

`MJ.Flex_Ancestors` follows the pinned C `mj_mergeChain(..., 0)`: select the
compiled weld roots, merge their descending DOF-parent paths without duplicate
common ancestors, then reverse the output into ascending order. `Load` now calls
this kernel directly. It no longer climbs fixed-body parents, initializes an
inclusion bitmap or scans all DOFs for each vertex/edge during admission.
Visited malformed links are rejected before publishing a partial chain.

The whole ancestry unit closes **250 proof checks and 25 flow checks**, including
exact output columns, count, ordering, bounds, termination and empty rejection
output. Small routines and checked static ghost unfolding lemmas were proved
first. Six warnings remain visible (five for recursive ghost models, one for
integer reassociation); the receipt distinguishes closed obligations from its
stricter warning-free pass. This is not a proof of the complete FLEX loader or
its force/equality callers.

The **368-file** frozen source maps are identical in validation and release.
They include the verified common r18 original-force path and the SDF stage2
ordering fix. Both profiles pass:

| Scope | Result in each profile |
| --- | ---: |
| Ancestry leaf: 895 native body pairs, 1,440 valid flat C forests, 10 malformed Ada cases and 10 recoveries | 2,355/2,355 |
| FLEX CSR/topology admission and recovery, including zero DOFs | 152/152 |
| FLEX equalities and mixed rows, 100 steps | 342/342 |
| Ordinary FLEX contacts, 100 steps | 234/234 |

Profile inputs, reference outputs, Ada outputs and numerical records match.
The C leaf oracle uses the unchanged pinned function body and verified headers;
it never runs malformed topology. C data is confined to the test oracle.
The leaf capacity remains 256 DOFs. These finite comparisons do not establish
universal C equivalence, interpolated movement or performance parity. The
ancestry change concerns admission; integrated timing needs its own measurement.

Receipts: `evidence/20261003-ancestors/acceptance-r196-r198.json`,
`r197-results.json` and the recorded source manifests. Earlier receipts retain
their original scopes and are not attributed to these newer sources.

## Initial single acceleration solve checkpoint, 2026-10-24

The FLEX path now prepares poses, rigid/passive forces and actuation, adds all
FLEX forces, then solves acceleration once. This follows C's force ordering and
removes the earlier acceleration solve before FLEX accumulation. Public
`MJ.Data.Forward.Evaluate` keeps its full behavior. Readiness, external-force
shape checks and result-publication guards remain; the damped Euler solve is
unchanged. The FLEX force routines were audited for acceleration reads and do
not consume the old acceleration.

A fresh validation snapshot passes the complete C 3.14 regression: **78/78**
metadata/state cases, **54/54** force cases and **234/234** constrained cases.
The force and constrained comparisons run **100 steps**, including the existing
damping, generalized applied forces and contact corpus. Dedicated world-wrench
and stale-acceleration poisoning tests were not rerun in this checkpoint.

The smallest proof scope, `Prepare_Forces_Ready`, remains **open**: GNATprove
rejected a composite local declaration before a loop invariant in
`mj-data-pipeline.adb:455`, before generating verification conditions (**0
checks**). The failed log and exact source closure are preserved; this is not a
Gold claim for the new stage or complete dynamics. The repeatable minimum runner
is `experimental/smooth/tests/prove_prepare_forces.py`.

The C 3.15 runtime rerun is pending: its historical generated foundation lacks
the newly required `Flg_Adhesion` field. C 3.17 integrated acceptance and quiet
release timing of this patch are also pending. No measured performance gain is
claimed. Receipts and frozen inputs are in
[`evidence/20261024-single-solve/`](evidence/20261024-single-solve/).

## Renewed force-preparation acceptance, 2026-10-24

The lexical work record that GNATprove rejected is now outside its loop, with
the same per-body assignment and arithmetic. Frame guarantees are separated
without removal. Explicit ghost equality composition preserves activation
state; two small proved lemmas expose allocation and the unpublished-force flag
while the expensive readiness predicates stay abstract.

The final immutable C 3.15 r142 snapshot closes `Ready_Allocation` (one proof
plus one flow check), `Unpublished_Forces` (one plus one), and
`Prepare_Forces_Ready` (34 plus two): **40 checks, zero open obligations**.
All nine existing context warnings remain visible in each receipt, including
imprecise elementary functions and the recursive-contract warning; the stricter
warning-free `passed` remains false. This proves preservation of state,
activation, inputs, configuration and time, and successful stage readiness
without publishing acceleration, **under the called phase contracts**. It does
not close those phase bodies, force-model mathematics or complete dynamics.
[Proof receipts and retained failed attempts](evidence/20261024-force-frame-proofs-r142/results.json)
and [exact sources/logs/commands](evidence/20261024-force-frame-proofs-r142/proofs.zip)
retain the frontend failure's follow-ups, the state/activation/flag obligations
and watchdogs. These remain engineering history, not mathematical Silver exceptions.

The runtime gates now always include a separate world-wrench comparison. It
applies world-frame forces and torques to bodies, alternates loaded/unloaded
acceleration at fixed pose, checks repeated evaluation and invalid-array
recovery, and compares 100-step movement against the actual C wheel with the
existing tolerances. The original corpus and RNG sequence are unchanged when
this mode is disabled.

| Frozen runtime | State | Ordinary forces | World-wrench / stale-cache | Constrained |
| --- | ---: | ---: | ---: | ---: |
| r136 C 3.14 validation | 78/78 | 54/54 | 54/54 | 234/234 |
| r139 C 3.15 validation | 78/78 | 66/66 | 66/66 | 246/246 |
| r140 C 3.15 release | 78/78 | 66/66 | 66/66 | 246/246 |

Counts include metadata/state samples; they are not all complete simulation
trajectories. The force and constrained comparisons use 100 steps and retain
zero/nonzero damping, generalized applied forces and contact cases. The renewed
3.15 foundation is generated against its genuine pinned ABI, with two serialized
flags and the default internal adhesion field; no compatibility bridge or
version spoof was used. It passes ten Ada suites, Python tests and deterministic
regeneration. [Runtime evidence](evidence/20261024-force-preparation-r140/results.json)
and [archive](evidence/20261024-force-preparation-r140/runtime.zip) retain source
closures, inputs/outputs, logs and exact receipts. The historical foundation
runner now also enforces the agreed 3000 MiB build cap.

The measured r140 executable precedes the final r142 ghost-only refinement.
A [bytewise source-delta audit](evidence/20261024-force-preparation-r140/proof-source-delta.json)
finds all 439 other files identical; removing only the two named static ghost
lemmas and their calls recovers the r140 pipeline source. This is a source audit,
not a claim that two separately built executables have identical timing.
[Quiet release timing](../alignment-3.15/evidence/20261024-single-solve-timing-r140/summary.json)
confirms a 5.18% mean-duration improvement on `free`; the six-model corrected
interval resolves only that workload. Ada's mean duration remains 2.43--3.09 times C's in these
comparisons. C 3.17 runtime migration, broader workload timing,
whole-loader/physics Gold and full-port C parity remain open.
