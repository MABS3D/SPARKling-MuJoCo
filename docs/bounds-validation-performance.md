# Array bound checks: measured improvement, parity still open

This is the frozen scan-only experiment. The later [compact-mass retry](compact-mass-retry.md)
extends the unused helper and its tests; source-match records below refer to the
scan-only capture, not a live assertion about subsequent edits.

Measured on 2026-09-26 against Ada commit
`bf265c8f544e8e151c62a30634cd1d44ea613c3d` and normal SIMD MuJoCo 3.14.0 C.
The only active runtime change is in `MJ.Bounds_Kernels.All_Within`: replace
`X not in -Limit .. Limit` with `not (abs X <= Limit)` inside the existing integer
rejection reduction. The exact interval postcondition, nonnegative-limit
precondition and inclusive endpoints are unchanged. Singleton, scalar and
fixed-size predicates remain unchanged. No physical arithmetic is reordered,
threshold relaxed, readiness scan removed, or warning/deallocator changed.

## What the C source actually does

Reference: MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.
In `src/engine/engine_core_smooth.c`, `mj_crb` (line 1894) copies body inertias,
accumulates them backwards, clears compact storage once, and walks
`dof_parentid` while decrementing the compact row address. It computes the
inertia-times-motion product once per non-simple DOF; simple DOFs use a cached
diagonal. `mj_factorM` (line 1979) copies the compact matrix directly into factor
storage before sparse factorization.

Our CRB already uses the composite-inertia algorithm, ancestor walks and simple
DOF diagonals. The remaining structural difference is dense symmetric mass
publication followed by `Load_Ancestor_Factor` / `AR.Copy_Matrix` gathering its
ancestor entries. The rejected compact prototype removed those operations but
increased total runtime; its report documents the evidence and integration gaps.
Compact representation remains a priority, not an achieved optimization.

C also validates position, velocity and acceleration in `engine_forward.c`
(`mj_checkPos`, `mj_checkVel`, `mj_checkAcc`) and control during actuation.
`mju_isBad` in `engine_util_misc.c` explicitly tests NaN and the two bounds.
It does not perform our full readiness predicate or three mutable readiness
predicates. Counting these as equivalent scans would therefore be misleading.
The accepted magnitude test optimizes our own validation overhead; it is not a
claim that C uses this exact expression. Its release assembly has one vector
magnitude mask and one floating comparison per vector, retaining the integer
rejection reduction that avoids the previously observed Boolean-reduction
compiler problem.

## Integrated movement results

Ryzen 7 9800X3D, CPU 12, GNAT/GCC 16.1, release flags and binary/source hashes
in the build record. Two independent sessions, 24 alternating blocks per case,
11 models, three initial states and four 100-step trajectories per process:
4,752 timed processes, 1,900,800 steps. No concurrent proof or build during timing.
Input preparation and output are outside the timed region.

Ranges below are per-state medians across both sessions, not confidence bounds.
Positive savings mean faster than prior Ada. A current/C ratio above one means
slower than C. Paired bootstrap 95% intervals are within-session and unadjusted
for multiple comparisons. Full records include MAD, p95 and extrema.

| Model | Time saved vs prior Ada | Current / C | Intervals wholly below prior Ada |
| --- | ---: | ---: | ---: |
| `hinge_motor` | -0.3 to 0.1% | 1.17–1.18× | 0/6 |
| `branched_multijoint` | -0.1 to 1.9% | 1.54–1.57× | 0/6 |
| `chain_12` | 0.7 to 2.4% | 1.92–1.99× | 2/6 |
| `crb_no_damping` | -0.5 to 0.4% | 1.97–2.01× | 0/6 |
| `crb_chain_24` | 0.5 to 3.4% | 1.94–1.97× | 5/6 |
| `ancestor_star_24` | 1.9 to 3.0% | 2.53–2.59× | 6/6 |
| `ancestor_forest_24` | 1.8 to 3.6% | 2.25–2.29× | 6/6 |
| `ancestor_branches_24` | 2.0 to 3.5% | 2.25–2.28× | 6/6 |
| `simple_hinges_6` | 0.9 to 1.1% | 2.47–2.50× | 6/6 |
| `simple_sliders_6` | -0.3 to 0.2% | 1.58–1.59× | 0/6 |
| `simple_mixed_8` | -0.7 to 0.2% | 1.69–1.70× | 0/6 |

The star, forest and branching 24-DOF workloads improved in all six state/session
comparisons. The chain improved in five of six; smaller effects elsewhere are
not advertised as established wins. No case had a paired interval wholly above
one, but this does not prove absence of regressions on other workloads/hardware.
We have improved integrated movement modestly; we have **not** reached C parity.

| Model | Current time per step | C time per step |
| --- | ---: | ---: |
| `hinge_motor` | 0.517–0.521 µs | 0.440–0.444 µs |
| `crb_chain_24` | 9.306–9.498 µs | 4.803–4.864 µs |
| `ancestor_star_24` | 10.539–10.649 µs | 4.042–4.175 µs |
| `ancestor_forest_24` | 7.933–8.086 µs | 3.462–3.573 µs |
| `ancestor_branches_24` | 8.169–8.326 µs | 3.567–3.714 µs |
| `simple_mixed_8` | 1.338–1.362 µs | 0.793–0.800 µs |

## Proof and numerical evidence

| Scope | Result | What it establishes |
| --- | --- | --- |
| Whole `MJ.Bounds_Kernels` | 7 checks closed, zero unproved/errors | Exact equivalence to the universal inclusive interval predicate, plus safety |
| Checked and release boundary tests | 564,672 checks each | Finite endpoints, adjacent values, zero/subnormals, large limits, array bases and SIMD tails |
| Numerical differential tests | 624 scenarios / 168,192 comparisons per policy; Strict and Compatible pass | Tested compatibility with C within the supported scope |
| Integrated trajectories | Prior/current Ada maximum difference 0; C maximum absolute difference 3.90e-14 | No observed change to trajectory outputs |
| Readiness instrumentation | 11 models pass; release outputs identical | Still one full and three mutable checks per successful step |
| Standalone `MJ.Compact_Inertia` | 149 checks closed; 16 dependency files hash-identical to final source | Separate lookup/projection/expansion contracts, not active mass assembly |

Proofs are modular under called contracts. They do not establish complete
dynamics, memory lifetime or ideal physical accuracy. Runtime boundary tests
cover finite Ada values; this work adds no new NaN/Infinity API guarantee.
The extra dense mass API tests check freshness, repeated queries, invalid sizes
and output arrays ending at `Integer'Last` independently of private storage.

## Rejected experiments

- [Direct compact mass](compact-mass.md): integrated multi-DOF regressions;
  runtime integration reverted. The unused proved helper and structural tests
  remain available. Two prototype integration proof checks were unresolved.
- Magnitude predicates in fixed-size math/spatial routines: promising pilots,
  but arithmetic unit revalidation left open obligations. Reverted; solver
  timeouts are unfinished proof engineering, not mathematical Silver exceptions.
- Extending magnitude checks to singleton/scalar predicates: proofs passed,
  but two full sessions showed 5–19% regressions. Reverted. These results must
  not be confused with the accepted array-only candidate.
- Empty/small-array shortcuts and removing the first dense mass clear alone:
  no established broad benefit in their pilots; excluded.

Evidence is under `tests/movement_performance/bounds_validation/evidence`.
`performance-session*.zip`, `performance-summary.json`, `build.json`, proof
snapshots, final numerical results and assembly refer to the accepted candidate.
The older compact-helper proof includes a different enclosing source snapshot;
`compact-proof-continuity.json` records its exact unchanged dependency closure.
`rejected-additional-trials.zip` and `fixed-predicate-exploration.zip` are rejected
variants, not results of the active code. See the harness README for reproduction.
