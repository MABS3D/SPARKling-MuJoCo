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
weighting, flex equalities and contact response remain separate integration
work. The geometric adapter is in `experimental/flex-state-integration`.

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
