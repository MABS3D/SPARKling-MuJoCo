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
