# Active manifold dynamics: performance work, 2026-09-30

The current smooth path saves approximately 15–25% of the previous Ada time in
the multi-DOF benchmark cases. Full performance parity is **not established**:
without external body loads, the 12-DOF scalar chain remains around 18% slower
than C, and the mixed/ball-chain cases need further work or tighter measurements.
The sampled external-load workloads are close to C or faster.

## Changes in the active path

- Reuse quaternions satisfying the existing `Unit_Quaternion` tolerance instead
  of running the scaled normalization again. Inputs outside that tolerance keep
  the original normalizer and tiny-norm identity fallback. The tolerance is
  **64 model epsilons**, broader than C's `mjMINVAL` no-op threshold; this is a
  documented floating-point algorithm difference, checked against C on the
  recorded trajectories, not a universal accuracy proof. The established
  `MJ.Smooth_Math.Normalize` body and its formula contracts are unchanged.
- Initialize a free body's pose directly from its position coordinates, as in
  C `mj_kinematics`, avoiding the fixed frame that would be fully overwritten.
- Evaluate the angular-increment sine once for its three components.
- Inline small spatial products/dot products and packed solver row updates.
  Arithmetic order, pivot clamping, rejection reductions and functional kernel
  contracts remain unchanged; the final solver body is byte-identical to the
  baseline body. An experimental absolute-value rejection variant was discarded.
- Invalidate the old mass result without clearing its dense storage before CRB.
  CRB initializes its complete candidate; the dense fallback still clears its
  workspace through the existing `Reset_Mass`. The new contract preserves the
  old matrix and state while clearing mass/force validity flags.

C still assembles directly into its compact ancestor representation. Our active
CRB path retains a dense candidate/publication and repacks it for the solves.
Removing that remaining representation round-trip is a concrete next target,
along with short-row factorization costs. Remaining numeric-domain checks have
not been removed on the basis of timing results.

C algorithm references are the pinned 3.14.0 implementations of
[`mj_kinematics`, `mj_crb`, `mj_factorM`](../mujoco/src/engine/engine_core_smooth.c),
[`mju_normalize4`](../mujoco/src/engine/engine_util_blas.c) and
[`mju_quatIntegrate`](../mujoco/src/engine/engine_util_spatial.c).

## Whole-step results

Every measured run contains complete Euler steps, including mass, all supported
force channels, actuation, solve and state integration. Every final trajectory
is compared with native MuJoCo C at `atol=rtol=2e-8`. Preparation, reset and I/O
are outside each timed interval. Baseline Ada, current Ada and C run in all six
execution orders, repeated twice: 12 blocks with 7 trajectories and 2 warmups
per executable, pinned to logical CPU 12.

The baseline is an immutable snapshot immediately before this optimization,
including the recently introduced scalar-only tendon-loader guard. Compiler
settings are GNAT/GCC 16.1.0, `-O3 -march=native -gnatn -gnatp`, LTO and
`-ffp-contract=off`. C 3.14.0 retains normal AVX and AVX intrinsics. Release
assertions/check settings are for timing only; numerical validation uses the
separate checked build. The host has concurrent activity. Ratios and intervals
describe these sampled workloads rather than all models or hardware.

Ratios are medians of paired block medians: below one is faster Ada. Brackets
are 95% bootstrap intervals from 10,000 resamples of the 12 paired blocks.
An interval spanning one is inconclusive about a small slowdown/speedup and
does not itself prove performance equivalence. Do not substitute an average
of these percentages for a representative movement workload.

| Workload | Current Ada/C, no external loads | Ada time saved vs baseline |
| --- | ---: | ---: |
| Free body | 0.970 [0.939, 0.994] | 18.1% |
| Ball body | 0.929 [0.894, 0.953] | 17.6% |
| Free + ball + hinge | 1.078 [0.991, 1.124] | 17.7% |
| Ball chain | 1.034 [1.004, 1.059] | 23.9% |
| Scalar hinge | 0.755 [0.739, 0.770] | 11.5% |
| Scalar chain, 12 DOFs | 1.177 [1.141, 1.206] | 25.2% |

These trajectories contain 24,000 Euler steps. The external-load run uses
12,000 steps and additionally supplies world-frame forces and torques at every
body COM, using the same inputs for all three executables:

| Workload | Current Ada/C, external loads | Ada time saved vs baseline |
| --- | ---: | ---: |
| Free body | 0.962 [0.935, 1.012] | 15.2% |
| Ball body | 0.875 [0.855, 0.911] | 15.6% |
| Free + ball + hinge | 0.997 [0.966, 1.022] | 16.5% |
| Ball chain | 0.962 [0.950, 0.975] | 22.6% |
| Scalar hinge | 0.681 [0.670, 0.686] | 10.9% |
| Scalar chain, 12 DOFs | 0.972 [0.954, 1.003] | 21.5% |

The external-load advantage cannot be attributed entirely to matrix/solver
speed: body-load projection changes the relative costs of the two pipelines.

## Numerical and proof evidence

The final checked regression contains 400 supported joint/scalar scenarios with
45,584 value comparisons, 320 scalar-tendon regressions with 21,944 comparisons,
32 quaternion/atomic-failure edge scenarios, and the 280-position/210-DOF
capacity check. These passed at the existing `2e-10` comparison tolerances.

During this work, the concurrently edited tendon loader rejects `nq != nv`.
The two free/ball plus spatial-tendon fixtures now explicitly test
`UNSUPPORTED_FEATURE`; they are excluded from the supported trajectory counts.
This limitation is retained, not silently bypassed. It is separate from the
performance changes and differs from the earlier merged numerical snapshot.

Focused final proofs close the exact predicate result, preservation of an
already unit quaternion, and mass invalidation's matrix/state/frame contracts:
7 proof checks and 5 flow checks across three subprograms, zero open checks.
The mass helper exposes the existing assembly layout through a proved
`Ghost => Static` call, without a runtime scan or trusted assumption.

Broader new manifold integration/normalization proofs remain open. Fresh whole
spatial-kernel diagnostics timed out; solver-unit diagnostics left three checks
open at the recorded budgets, despite unchanged arithmetic bodies. Neither those
rows nor the full dynamics are counted as Gold/Silver passes. No new assumption,
trusted body or runtime-check suppression was added to claim proof completion.

The evidence folder records baseline/current source hashes, checked manifests,
binary hashes, compiler flags, CPU information, block ratios, dispersion and
proof diagnostics:
[`manifold-performance-20260930`](../experimental/smooth/results/manifold-performance-20260930/).
The profiling report is from an instrumented, non-LTO intermediate build; its
call costs are diagnostic and are not release performance percentages.

Reproduce checked validation with Python containing MuJoCo 3.14.0 and NumPy,
and GNAT/GPRbuild on `PATH`, using a fresh output directory:

```sh
python experimental/smooth/tools/test_manifolds.py \
  --out /tmp/manifold-checked --expect-scalar-tendons
```

For already-built release binaries, supply the pre-change baseline explicitly:

```sh
python experimental/smooth/tools/benchmark_manifolds.py \
  --ada /path/current-ada --baseline /path/baseline-ada --c /path/native-c \
  --out /tmp/manifold-timing --cpu 12 --steps 24000 --blocks 12
```

Add `--external` for the body-load workload. The generated project/compiler
configuration is retained in the manifest; an instrumented or checked binary
must not be substituted for one of the release binaries.
