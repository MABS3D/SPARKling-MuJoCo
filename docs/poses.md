# Pose primitives

`MJ.Poses` provides fixed-storage, scalar-first quaternion pose operations with
caller-owned position and quaternion outputs. Its reference is MuJoCo 3.14.0,
commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`; the official stable release
was rechecked on 2026-09-24 at https://github.com/google-deepmind/mujoco/releases/latest.

| API | Reference | Specified floating-point behavior |
|---|---|---|
| `Compose` | `mju_mulPose` | Normalize the ordered Hamilton product; rotate the second translation with the original first quaternion, then add the first translation. |
| `Inverse` | `mju_negPose` | Conjugate quaternion; rotate translation with the conjugate; negate the result. |
| `Transform` | `mju_trnVecPose` | Rotate point, then add translation. |

Each operation has separate-result and explicit in-place overloads. The in-place
composition replaces its left operand; its right operand remains distinct.
The separate outputs and inputs follow SPARK's non-aliasing rules. In-place
wrappers preserve old inputs before invoking the underlying operations. In
particular, a direct `mju_mulPose` call with its quaternion output aliasing its
first input is not the reference for our in-place composition: that would
replace the quaternion before the translation uses it. The C fixture snapshots
the source pose, just as the Ada overload does. It also snapshots the point
for in-place transformation: the upstream inline rotation requires a distinct
output. These copies are included in the timed C operations.

## Contracts and domain

Position, point and input quaternion components must be finite Tier0 values
(`[-1e10,1e10]`). No exact unit-length precondition is imposed. The Gold target
is the actual ordered floating-point algorithm, including the identity branch
and all normalization branches. Transform implements the upstream inline rotation
formula with a proved scalar-quaternion shortcut: when all three vector
components are zero, the correction is exactly zero for finite inputs. The
ghost model retains the upstream identity-only branch and full formula, so the
shortcut is proved against the original behavior. There is no extra zero-vector
branch in Transform; inverse reuses the verified quaternion
rotation, including its zero-vector shortcut. Conjugation is the geometric
inverse for a unit quaternion; `Inverse` does not claim arbitrary nonunit poses
are invertible by conjugation. No exact rounded round-trip, unit norm, or
orthogonality identity is asserted.

Quaternion `Norm` and `Normalize` now accept Tier1 inputs (`[-1e30,1e30]`),
allowing a product of two Tier0 quaternions to be normalized without restricting
pose inputs. The normalization output has a conservative Tier2 bound. The prior
Tier1 output guarantee is retained conditionally for Tier0 inputs. The square
and scalar scaling helpers use wider bounds; their executable arithmetic,
ordered sum, near-unit no-op and tiny-length identity fallback are unchanged.
The standard runtime square-root contract remains the existing trust boundary.

`Compose` and `Transform` positions have a conservative Tier3 output bound;
`Inverse` positions have Tier2. These modular bounds accommodate the existing
rotation contract and are not estimates of physical pose magnitudes. Chaining
these APIs still requires the caller to establish the next call's input domain;
the current square-root contract does not itself prove an approximate-unit-norm
bound. That accuracy/domain closure property remains separate work.

Private scalar cells separately prove the rotation intermediate, the ordered
rotation-plus-translation coordinate, and normalization scaling. Transform
composes these proved relations; per-branch assertions establish initialization,
bounds and each coordinate before joining the branches. These proof-only
assertions add no executed arithmetic.

The scalar result stores use proof-based initialization (`Relaxed_Initialization`
with an explicit proved `Initialized` postcondition), as in the rotation kernel.
No allocations, new assumptions, skipped bodies or runtime proof models are
introduced. The value-returning `MJ.Quaternions.Product` has the same proved ordered
component contract as `Multiply`; it gives composition an explicit intermediate
value. Inversion similarly reuses `MJ.Rotations.Conjugated`. The private
normalization wrapper supplies a modular result relation;
it uses the normal square-root/threshold path directly, while public quaternion
normalization retains its proved exact-zero/exact-one shortcuts. Composition
hides only the expression body of that ghost model to avoid
re-expanding the arithmetic in callers. The model and helper remain proved.

## Reproduction

From the project root with native GNAT, GPRbuild, GNATprove and Python on PATH:

```sh
python3 tests/poses/prove_small.py
# For diagnosis, restrict to declaration names containing a substring:
# python3 tests/poses/prove_small.py --match Transform
python3 tests/poses/prove.py --unit mj-quaternions
python3 tests/poses/prove.py --unit mj-poses
python3 tests/poses/prove.py --unit mj-rotations
gprbuild -p -P tests/poses/checks.gpr -XPOSE_MODE=development -j2
python3 tests/poses/numeric.py --mode development
gprbuild -p -P tests/poses/checks.gpr -XPOSE_MODE=validation -j2
python3 tests/poses/numeric.py --mode validation
gprbuild -p -P tests/poses/checks.gpr -XPOSE_MODE=release -j2
python3 tests/poses/numeric.py --mode release
python3 tests/poses/measure.py --output tests/poses/performance.json
```

Proof runs use separate unit directories and the repository freshness/coverage
gate. Differential tests compile actual pinned upstream sources with normal
platform SIMD. They cover independent half-turn, pure translation, zero-product
fallback and nonunit-product normalization anchors, threshold neighbors,
subnormals, signed zeros, all quaternion sign combinations at the bound, and
random inputs. Numerical equality does not assert equality of zero sign bits
and does not constitute a universal equivalence proof to C.

Benchmark preparation and checksums are outside both clocks. Each output slot is
visited once in a batch. Each language has one noinline timing loop per operation;
the kernels use their normal inlining policy. Matching flags, memory barriers,
CPU affinity, alternating samples, dispersion and source/binary hashes are
recorded. Release disables runtime checks in both languages (`-gnatp` and
`-DNDEBUG`); development and validation keep them enabled. The timed Ada
entry point uses C-compatible typed pointers with an explicit seven-double pose
layout; no extra alignment requirement is added to the kernel API. In-place C wrappers include the required source snapshots within the
same timed scope as Ada. All six pose paths and the value-returning quaternion product are checked
numerically before timing. The standalone product is also benchmarked against
`mju_mulQuat`.

## Scope and status

The 2026-09-24 snapshot proves the Gold floating-point contracts and runtime
safety of the three units below. Diagnosis first covered 17 minimal subprograms;
fresh complete-unit runs then passed the coverage and source-freshness gates.

| Complete unit | Proved checks | Unproved | Warnings |
|---|---:|---:|---:|
| `MJ.Quaternions` | 422 | 0 | 7 |
| `MJ.Poses` | 204 | 0 | 2 |
| `MJ.Rotations` | 68 | 0 | 0 |
| Total | 694 | 0 | 9 |

Eight warning records concern the existing runtime square-root modeling
boundary; one concerns GNATprove ignoring `Loop_Optimize`. No new assumption,
skipped body or trusted implementation was introduced. See the
[proof justifications](proof-justifications.md) and
[proof receipts and reports](../tests/poses/evidence/README.md).

Numerical regression passed in development, validation and release:

| Suite | Input cases per profile | Scalar comparisons per profile |
|---|---:|---:|
| Poses | 9,404 | 357,352 |
| Quaternions | 4,023 | 152,874 |
| Rotations | 6,377 | 153,048 |

That is **1,989,822 scalar comparisons** across the nine runs. Pose tests also
passed independent anchors, in-place equivalence and input-preservation checks.
The main project release compilation of `MJ.Poses` passed. These tests compare
finite numerical values, not the sign bits of zero.

### Performance remains an acceptance blocker

The complete reference run used an AMD Ryzen 7 9800X3D under WSL2, GNAT/GCC 16.1.0,
31 alternating C/Ada sample pairs per case and a 25 ms target per sample.
Of 70 pose/product cases, **43 were faster, 20 within measured noise, and
7 slower**. The earlier complete run, preserved in
[before-scalar-shortcut](../tests/poses/evidence/before-scalar-shortcut/summary.json),
had 28 slower cases with the same sampling parameters. Standard separate-result
Transform (pattern 0) improved from 1.0811 to 1.0149 times C's cost.
Scalar-quaternion Transform cases 2, 3, 8 and 9 now cost about 0.48 times C;
all ten in-place Transform cases were faster in this run.

The seven open cases are below. Ratios are medians of paired Ada/C timings,
not ratios of independently computed medians. Values above 1 favor C; the
95% bootstrap interval determines classification without a fixed slowdown
allowance.

| Operation | Pattern | Ada/C ratio | 95% interval |
|---|---|---:|---:|
| Compose in place | 4: nonunit quaternion | 1.00777 | [1.00110, 1.01717] |
| Compose in place | 5: tiny quaternion | 1.01436 | [1.01038, 1.01992] |
| Transform | 0: general unit quaternion | 1.01494 | [1.00914, 1.02220] |
| Transform | 4: nonunit quaternion | 1.00935 | [1.00418, 1.02356] |
| Transform | 5: tiny quaternion | 1.00554 | [1.00009, 1.01297] |
| Transform | 6: Tier0 limits | 1.01156 | [1.00373, 1.01377] |
| Transform | 7: zero translations and point | 1.01434 | [1.00691, 1.02019] |

The separate normalization regression measured 16 Norm/Normalize cases:
7 faster, 9 within noise, none slower. Two small slowdowns in the preceding
run did not recur in the focused follow-up or the final complete run; the
preceding results are retained. Performance evidence is specific to these
inputs, build settings and hardware.

Disassembly confirms packed SIMD arithmetic in the Ada transform, composition
and quaternion product loops. The measured hot loops contain no calls or fused
multiply-add instructions. SIMD is available to the SPARK implementation;
remaining differences require optimization of the emitted code while preserving
the ordered arithmetic and Gold contracts.

The performance gate is **OPEN**. The five separate-result Transform cases and
two in-place Compose cases above remain historical slowdown flags; faster
cases do not compensate for them. See the [complete evidence index](../tests/poses/evidence/README.md)
for raw paired samples, source/binary hashes, compiler flags and disassembly.

### Optimization follow-up

The [subsequent investigation](../tests/poses/evidence/optimization-round2/README.md)
measured six source variants and rejected all of them for promotion. Two further
source prototypes did not finish focused proof diagnostics, and a compiler-flag
probe produced no useful change in the relevant hot loops. The original sources,
contracts and release settings were restored; the rebuilt executable has the
same SHA-256 as the complete reference run at the end of that investigation.
After the subsequent matrix-transpose optimization, the three complete units
were proved again: 694 checks, zero unproved, nine reviewed warnings.
[Fresh receipts](../tests/matrix_performance/evidence/README.md) bind that proof
to the updated source tree; the historical pose receipts remain unchanged.
This proof refresh makes no new pose performance claim.

A focused baseline repeat and a balanced same-executable control give the
strongest repeated slowdown evidence for tiny Compose in-place, nonunit Transform
and Tier0-limit Transform. General Transform and zero-point Transform change
classification between interleaved sample groups of identical code. Nonunit
Compose in-place and tiny Transform are inconclusive in both new sessions.
No historical flag is declared fixed, and these focused sessions do not replace
the complete reference run. Intervals are individual within-session estimates;
an interval containing 1 is inconclusive, not proof of equivalence. There is no
universal 1.5% noise threshold.

General Transform in-place still takes about 16% less time than C and general
Inverse in-place about 25% less time in both control groups. These favorable
cases should be preserved; their gains do not establish an aggregate workload
speedup without representative operation frequencies and integration measurements.
The new [build comparator](../tests/poses/compare_builds.py) compares candidate
Ada directly with baseline Ada while also retaining C/C and both Ada/C controls.

This increment supplies pose primitives. It does not migrate the experimental
smooth kinematics, verify the body/joint pose recursion, or establish
whole-engine performance. Accuracy/domain closure remains pending as described
above. The pre-existing matrix performance gate remains open independently.
