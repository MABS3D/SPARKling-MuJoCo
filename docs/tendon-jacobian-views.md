# Spatial tendon Jacobian views — 2026-09-30

The active tendon phase now passes its existing flat linear/angular Jacobian
buffers directly to `MJ.Spatial_Tendons.Evaluate_Flat`. It no longer constructs
two complete `Body_Jacobian` arrays through `MJ.Tendon_Adapters.Jacobian`.
The original matrix-based API remains available for standalone callers.

Both entry points use one shared path evaluator. The flat reader specifies and
proves the exact component mapping `3 * (body * nv + dof) + component`.
Point shifts still use the COM as origin; wrapping, reduction order, force
channels, rejection behavior and publication of results are unchanged. There
are no new assumptions, trusted bodies, suppressions or production C kernels.

The flat layout validator keeps the previous component domain through
`abs value <= 1e10`. Dimensions are compared in `Int64`, and the public row
length is explicitly bounded before conversion to `Natural`. This prevents
range checks in validation itself, without excluding previously valid inputs.

## Storage and remaining materialization

The two removed arrays contain `6 * nbody * nv` binary64 elements, or
`48 * nbody * nv` bytes. At 33 bodies/64 DOFs that is 101,376 bytes of temporary
array elements per evaluation. This is a source-level storage calculation,
not a measured reduction in process RSS; compiler optimizations may already
avoid some temporary storage.

`Pipeline.Ensure_Jacobians` still builds the dense cache. Tendon evaluation
still visits all DOFs for each relevant segment. C instead computes endpoint
Jacobians on the involved ancestor chains through `mj_jacDifPair`. Avoiding
that dense construction and visiting only those columns remains separate work.
The present change preserves the existing floating-point point-shift algorithm.

## Verification

Fresh checked regression on the retained source hashes passes 400 joint/scalar
scenarios (45,584 comparisons), 320 tendon/scalar scenarios (21,944 comparisons),
32 boundary scenarios and the 280-position/210-DOF capacity check. The two
ball/free plus spatial-tendon combinations remain explicit unsupported cases.

The standalone probe now evaluates every valid path through both matrix and
flat inputs and requires identical status, length, entire Jacobian row, points
and count, including failure output. Each validation/release profile passes
1,044 C differential paths, seven malformed paths and one late atomic-failure
case, plus 4,097 geometry cases and independent finite-difference checks.
The profiles use reproducible sequential random streams, not identical random
fixture sets between profiles.

Minimal scoped proofs close 56 proof obligations with zero open checks:
38 for `Flat_Column`, 4 for `Valid_Flat_Kinematics`, and 7 per evaluator wrapper.
The reader proves its exact component relation and bounds. The wrappers use
the declared `Evaluate_Internal` contract; they do not prove that body's path
algorithm. A fresh complete-unit diagnostic at cvc5/1 second/300 steps records
183 proved and 159 open proof checks. It is not Gold/Silver acceptance or proof
that those properties are false. Whole-path and integration proofs remain open.

## Whole-step timings

Baseline/current Ada and native MuJoCo C 3.14.0 advance the same 64-step Euler
trajectories, with numerical checksums compared at `2e-11` absolute/relative
tolerance. Reset, input and getters are outside timing. GNAT/GCC 16.1.0 uses
`-O3 -gnatp -gnatn -march=native -flto -ffp-contract=off`; the official C library
retains its normal SIMD. One warmup block precedes all six execution orders,
repeated twice, with 1,024 trajectories per executable/block on one logical CPU.
Host activity is not controlled.

Ratios are medians of paired block ratios; brackets are 95% bootstrap intervals
from 10,000 resamples. They are not ratios of the separate overall time medians.

| DOFs / tendons | Current / baseline Ada | Current / C |
|---|---:|---:|
| 2 / 1 | 0.986 [0.959, 1.030] | 1.195 [1.111, 1.265] |
| 8 / 4 | 0.997 [0.975, 1.026] | 1.450 [1.398, 1.464] |
| 16 / 8 | 1.003 [0.992, 1.028] | 1.621 [1.603, 1.631] |
| 64 / 32 | 0.996 [0.989, 1.010] | 2.733 [2.700, 2.755] |

**No stable whole-step speedup or C parity is established.** All baseline
intervals span one, which also does not prove timing equivalence. The change
removes explicit full-buffer conversions; further work must address dense
materialization and column traversal, with fresh contracts and measurements.

Earlier range-comparison, fused-reader and forced-inlining trials are retained
as diagnostics. They are not the delivered code or acceptance evidence; one
fused-reader proof hit its watchdog. No incomplete new fused kernel is retained.

[Source hashes, raw proofs, checked results and timing samples](../experimental/smooth/results/tendon-jacobian-views-20260930/summary.json)
identify the retained `abs-view` variant. The accompanying archive contains the
immutable baseline/current build snapshots and reproduction scripts. Historical
candidate reports remain scoped to their original source hashes.
