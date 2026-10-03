# General constraint solvers — experimental candidate

Ada/SPARK PGS, CG and Newton on an assembled constraint problem, used by the
experimental constrained-step pipeline. The iterative solver's global safety
and functional proof remains open. Complete MuJoCo compatibility and integrated
performance parity remain separate, unfinished objectives.

## Recovery status (2026-10-03)

- The integrated engine now passes its original `Dynamics.Total` and reuses
  the Ada ancestor LDL factor through optional `Smooth_Force`, `Native_Factor`
  and `Native_Inverse` inputs. Omitted arguments preserve the assembled API.
  Factor provenance must match the current mass/free-acceleration pair; its
  global functional proof is still open. No C-exported factor enters the
  production runtime, and strict inertia policy retains its previous path.
- `Native_Inertia` closes 147 proof and 34 flow checks for ordered FP stages,
  frames, bounds and atomic rejection. Fourteen recursive-model warnings remain
  visible (`strict_passed=false`); this does not prove the complete
  factor-to-solution relation or the solver caller. The independent native
  `mj_solveLD` comparison passes 230/230 bitwise in each profile. The composed
  production bytes pass 1232/1232 cases in validation and release: rigid106,
  elliptic254, surface92, forces452, tendons76, assets126 and local assets126.
  Source identity and scope are preserved in
  [the LDL evidence index](evidence/recovery-20261003-native-inertia/index.json).
- A quiet full-step comparison of LDL against the previous original-force
  build gives a 96-DOF paired ratio of 0.95948, CI95% [0.86991, 0.98327].
  Median steps are 73.859 vs 78.470 us; normal C takes 15.037 us, leaving a
  paired Ada/C ratio of 4.945 [4.789, 5.205]. The sphere also improves; the other
  five intervals include 1. All seven states meet the original 2e-9 tolerances.
  CPU2, 15 alternating blocks, eight measured 100-step trajectories and an
  excluded warmup per block are recorded with raw samples and dispersion.
  The separate r16 comparison is cumulative and is not attributed solely to LDL.
- R15 adds scalar Newton rank-one Cholesky updates/downdates, the native
  bracketed-search returns, and the C grouping of compound cost/derivative
  updates. The new update kernel matches 346/346 official C cases bitwise;
  ten scalar minima prove 92 checks, and the vector update and individual
  matrix stores prove 35/12/12 checks. Composed matrix-update proofs and the
  complete floating algorithm model remain open. Elliptic cone updates still
  use the existing full-factor path; arbitrary/duplicate CSR rows retain that
  path until their complete native Hessian traversal is ported.
- R15 standalone checks pass 428/428 dense, 432/432 native CSR and
  215/215 published generalized-force cases. An assembled ball/plane regression
  with forces around 6.6e15 now matches C exactly at nine iteration budgets,
  including its six-iteration final result. This is one preserved problem,
  not a claim that every integrated advanced-actuator trajectory is closed.
  R15 integrated validation/release receipts use their own manifest
  and `verification-scope.json` in `/var/tmp/sparkling-recovery-dynamics-20261003-15`.
- The current scalar and sparse arithmetic helper units pass 54 and 72 checks.
  The domain now includes C regularization/inverse weights from 1e-15 to 1e15,
  including equality rows with a zero Jacobian; `Aref` accepts ±1e30.
- Standalone validation now passes 428 cases after the minval/reference and warm-start domain fixes. The
  integrated elliptic corpus now passes 254/254 at the original tolerances,
  after ordered reductions, diagonal inverse application and compiled simple
  DOF metadata were restored. Other current integrated receipts are tracked in
  `plans/2026-10-02-recovery-dynamics.md`.
- The earlier wide four-lane model and runtime snapshots pass 123 and 165
  whole-unit checks. New exact model contracts and a 60-check congruence lemma
  are proved minimally; the expanded model's whole-unit renewal is pending. The latter frozen report has complete coverage, but its final
  checkout-hash guard detected concurrently added solver files; a final closure
  receipt still needs renewal. The 336-case C comparison matches exactly.
- New `Dense_Cholesky` follows C's dense column order and deficient-pivot
  clamping. Its 385 factor/rank/solve cases match exactly, including deficient
  columns and pivot-threshold neighbors. All minimal routines and the final
  whole unit pass 348 checks with complete coverage and no open obligations;
  reviewed runtime-sqrt and recursive-model diagnostics remain explicit.
  Per-column and substitution-row exact functional contracts are proved.
  That 348-check receipt scopes the local-contract revision; the new global
  factor/rank model and preservation lemmas require a fresh whole-unit proof.
  Dense Newton now uses this factor and solve: validation/release have identical
  records on the seven integrated r7 corpora, with 106/106 rigid, 254/254 elliptic,
  92/92 surface, 452/452 force and 76/76 tendon cases. Asset trajectories remain
  117/126 in each of two corpora. Global final-factor/solution and rank relations
  and complete integrated compatibility remain open. No proof of real-arithmetic
  accuracy is inferred from these results.
- `Sparse_Cholesky` now follows C's symbolic and numeric reverse L'L order,
  retaining structural zeros and the CSC update order. The r10 corpus has
  395/395 native C cases with bitwise matching structures, factors, ranks and
  solves (dimensions 1–128, diagonal/chain/tree/random/dense structures, scale,
  deficient pivots, threshold neighbors and signed zero cases).
  `Update`7, `Scale`5 and `Symbolic`91 checks pass locally; the symbolic post
  establishes valid structure, not universal equivalence to C's symbolic
  algorithm. Factor/solve and whole-unit proofs remain open.
  The integrated dispatcher honors explicit dense/sparse and Auto at nv>=60;
  the caller supplies Hessian support from mass ancestors and constraint CSR,
  including zero-valued entries. R62 validation passes rigid106/106,
  elliptic254/254 and forces452/452; standalone passes428/428 against each
  dense and sparse oracle. R62 and later proof edits have separate manifests.
  The previous universal dense dispatch caused a measured6.00x regression on
  a96-DOF sparse workload relative to r7 with only the old Newton restored.
  The frozen r62 integrated sparse path reduces the 96-DOF workload to
  89.48 us from r7's 400.39 us; C takes 16.00 us. This is still 5.60x C.
  The later support-list optimization has not yet been measured in isolation.
- The old Cholesky helper gained preservation lemmas during recovery; the fresh
  whole-unit run reached its watchdog. The 266-check receipt below belongs to
  the earlier frozen source, not the current modified unit.

Whole-engine compatibility and performance parity remain open.
The remaining sections retain the earlier isolated-candidate evidence and
measurements; they must be read against their source manifests.

## Historical baseline and scope (before recovery)

## Problem and supported rows

`MJ.Constraint_Solvers.Solve` receives the effective symmetric positive-definite
metric `M`, dense Jacobian `J`, smooth acceleration, reference acceleration and
row metadata. It solves the same regularized constraint objective as MuJoCo:

- equality rows;
- bounded DOF/tendon friction-loss rows;
- unilateral limit and frictionless-contact rows;
- pyramidal contacts represented by unilateral pyramid-edge rows;
- elliptic contact blocks of dimension 3, 4 or 6, including torsional and rolling
  friction and anisotropic tangential regularization.

For PGS, the dual matrix is `J M^-1 J^T + diag(R)`. CG and Newton minimize the
primal Gauss-plus-constraint cost. All three return acceleration and row forces.
Input arrays must start at 1. The current workspace accepts **1–128 DOFs** and
**0–256 rows**; these are explicit candidate limits, not MuJoCo limits.

The checked input domain is documented in `Solve`: input matrix/vector entries
within ±1e10 in that snapshot, regularization and its reciprocal within
[1e-12, 1e12] before the recovery extension described above, friction
coefficients and cone `mu` within [1e-5, 1e5]. `R*D` is checked to 1e-12; elliptic
regularization ratios to 1e-10. A cone header carries its dimension and following
rows carry dimension zero. The metric must be exactly symmetric; Cholesky
rejects pivots below 1e-15. Dynamic numerical failures preserve both output
vectors. Iteration limits publish the last iterate with an explicit status.

`Converged` means a MuJoCo-style stopping criterion fired; it is **not** a
machine-checked theorem that an exact optimum was reached. Warm starts are
provided by the caller; the engine's choice between old and smooth acceleration
is outside this API. Initial PGS forces are projected to feasibility.

## Following the C implementation

The reference is **MuJoCo 3.14.0**, upstream commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. The official latest-release API was
checked again on 2026-10-02 and still reported stable tag 3.14.0.
Sources: `mujoco/src/engine/engine_solver.c`, `engine_core_constraint.c`, and
`engine_util_solve.c` at that revision.

Implemented from those sources:

- PGS block shuffling with the same fixed-seed PCG32 sequence, Nesterov momentum
  and adaptive restart, projected scalar steps, normal-ray updates and
  tangential ellipsoid QCQP. The QCQP uses explicit 2/3-dimensional inverses and
  the generic Cholesky path, with C's 20-iteration budget and thresholds.
- CG metric preconditioning and the current **Hager–Zhang** direction update.
- Newton with the full cone curvature in the Hessian. Cone Hessians are only
  computed for Newton; PGS and CG skip them.
- Bracketed Newton line search and shifted cost differences, including
  rationalized differences inside the elliptic cone and at zone transitions.
- The initial primal gap test, Newton gradient gate, scaled improvement,
  gradient/decrement stopping tests, and explicit iteration statistics.

Floating-point operation order and Cholesky representation are not bit-identical
to every C kernel. A line-search budget event is counted and an improving step
can still be used by the outer solver, as in C. This API returns
`Line_Search_Limit` if no improving step is available at that limit; it rejects
non-improving fallback steps. `Curvature_Repairs` exposes the nonpositive-curvature
fallback instead of silently hiding it. All normal differential cases require
zero such repairs.

The production work still missing includes compact/sparse metric and Jacobian
interfaces, cached factors and workspaces, incremental Newton Hessian updates,
island dispatch, engine-selected warm starts, NoSlip and end-to-end integration.
An already assembled effective SPD metric can be passed, but IPC, damping/flex
metric assembly and specialized C preconditioners were not ported here.

## Validation and proof

Both validation (`-gnata -gnato -gnatVa`) and optimized (`-O3 -gnatn
-march=native`) builds pass the same tests. Runtime range checks remain enabled
in the optimized profile; this candidate does not use `-gnatp`.

| Check | Result per build |
| --- | --- |
| Native-C assembled-problem comparisons | 193/193 accepted; 192 meet the direct error threshold |
| Analytic scalar solutions | 18/18 |
| Warm-start checks | 189/189 |
| Invalid input / non-SPD atomic rejection | 3/3 |
| No-row and zero-iteration cases | 6/6 |
| Total differential/analytic suite | **409/409** |
| Numeric-domain stress | 240/240 finite outcomes; 4 atomic numerical rejections |
| Deterministic replay | 240/240 |
| Capacity boundaries | 5/5 |
| Direct Cholesky edge checks | 18/18 |
| Exact observable comparison with pre-refactor Ada executable | 211/211 |

The native reference is the official MuJoCo 3.14.0 shared library, with dense
Jacobians, disabled warmstart/islands/Euler damping and no NoSlip/IPC. Fixtures
include equalities, DOF and tendon friction, joint limits, contacts of dimensions
1/3/4/6, multiple contacts, mixed rows and varying `impratio` and velocities.
PGS also has fixed-seven-iteration comparisons to exercise shuffle and momentum.
These tests compare solver inputs and outputs, not full-pipeline timings.

The direct error threshold is `2e-7 + 1e-8*max(abs(C result))`. In one mixed
elliptic PGS case, the candidate stops after 152 sweeps versus C's 149; maximum
acceleration difference is 1.14e-6 and force difference 5.18e-5. An independent
floating-point primal/dual-gap diagnostic gives approximately **6.93e-11** for
the candidate and **4.11e-10** for C. The discrepancy is within the distance
bounds from both gaps. The test records this separate acceptance path explicitly;
it is not bitwise equivalence or a formally certified interval bound.

`MJ.Constraint_Scalar` has **54 discharged checks**, covering exact binary64
piecewise force/cost/curvature, projection, scalar-step and cone-zone contracts.
`MJ.Constraint_Order` has **8 discharged checks**, including the exact modular
PCG32 state transition and output. Both whole-unit runs check all entities,
no skipped proofs/flows, no assumptions and no missing entities, after individual
subprogram runs. Neither result establishes the correctness of `Solve`.

On 2026-10-02, the common factorization and triangular solves were extracted to
`MJ.Constraint_Solvers.Cholesky` and connected to PGS, CG, Newton and the generic
QCQP path. The whole helper unit passes **266 checks**, with every entity covered,
zero open obligations, no skipped proofs/flows and no assumptions. Diagnosis
started with all 17 minimal subprograms; affected routines were rechecked after
subsequent refinements. The whole-unit report and current source hashes are in
`evidence/2026-10-02/summary.json`.

The proved functional scope is explicit:

- Ordered binary64 reductions, including the original ±1e100 accumulator
  rejection policy.
- Exact factor-cell and forward/transposed substitution-row arithmetic,
  preserving all other entries. Failed individual updates preserve their input.
- Bounded partial workspaces, a lower-triangular factor, positive successful
  pivots, safe helper composition, and exact preservation of a zero RHS.

The public factor/backsolve contracts do **not yet** express a complete model of
the final nonzero factor/solution. Their local arithmetic and frame properties
are proved, but a final global relation and real-arithmetic error bounds remain
separate work. The standard Ada runtime sqrt is the existing boundary: its
magnitude is checked before storage. Six diagnostics are retained and reviewed:
two `numeric-variant` notices for controlled ghost-model unfolding and four
`imprecise-call` notices for sqrt. There are zero unreviewed warnings. This does
not establish a new accuracy theorem for the runtime square root.

Array predicates and reduction models use static ghost assertions, so they add
no matrix/vector scans. Scalar operand bounds are proved static preconditions;
using constrained formal parameter types there added redundant runtime range
checks. Dynamic checks on newly computed accumulator values and the sqrt result
remain explicit. The existing outer solver maps a numeric failure to
`Numeric_Limit`, preserving the user's acceleration and force vectors in the
regression tests; the full formal composition of that public API is still open.

The October 1 diagnostic (9 closed / 15 open checks for the old nested `Factor`)
and the failed unrestricted solver proof remain historical evidence. They are
superseded for the extracted helper, not for the entire iterative solver.
The remaining proof work includes caller preconditions, workspace initialization,
QCQP, cone/Hessian evaluation, line search and the PGS/CG/Newton iteration
invariants. These are pending engineering tasks, with no Silver waiver.

The final validation and release builds each pass 409 differential/analytic
checks, 240 stress cases, 240 deterministic replays, 5 capacity cases and 18
Cholesky edges. Across 193 native-C fixtures plus 18 analytic cases, every
reported result and statistic is exactly identical to the saved pre-refactor
Ada executable. This is sampled regression evidence, not universal equivalence.

## Performance of this change

A diagnostic repeats each assembled fixture 300 times, in seven alternating
before/after rounds, pinned to one CPU. It measures process wall time, including
startup and I/O, and compares Ada executables built with the same release flags.
It is not a C timing comparison or an integrated movement-step benchmark.

| Solver | Median time change | Range of paired changes |
| --- | ---: | ---: |
| PGS | **+5.44%** | +2.26% to +10.63% |
| CG | -1.45% | -5.15% to +8.94% |
| Newton | +3.39% | -10.89% to +10.42% |

PGS has a remaining diagnostic regression; the CG/Newton samples are noisy and
do not establish a stable improvement. No performance-parity claim is made.
Removing redundant constrained-formal conversions reduced the first observed
regression, but did not eliminate it. The next performance work should target
the checked per-term reductions and call boundaries against C's dense kernels,
while retaining the proved domains and failure behavior. Cached/sparse workspaces
and full-pipeline measurements remain pending as before.

## Reproduce

Use the repository's GNAT/GNATprove toolchain and the existing MuJoCo 3.14.0
Python environment. `tests/check.py` snapshots all Ada inputs and source hashes
into a fresh external directory, then uses the repository resource guard.

```sh
python3 experimental/constraint-solvers-candidate/tests/check.py --phase build --out /var/tmp/constraint-solvers-validation
python3 experimental/constraint-solvers-candidate/tests/check.py --phase build --mode release --out /var/tmp/constraint-solvers-release
/var/tmp/sparkling-movement-env/bin/python experimental/constraint-solvers-candidate/tests/differential.py --binary /var/tmp/constraint-solvers-validation/build/validation/bin/solvers_probe --out /var/tmp/constraint-solvers-validation/differential.json
/var/tmp/sparkling-movement-env/bin/python experimental/constraint-solvers-candidate/tests/robustness.py --binary /var/tmp/constraint-solvers-validation/build/validation/bin/solvers_probe --out /var/tmp/constraint-solvers-validation/robustness.json
python3 experimental/constraint-solvers-candidate/tests/check.py --phase small --unit mj-constraint_scalar --out /var/tmp/constraint-scalar-small
python3 experimental/constraint-solvers-candidate/tests/check.py --phase whole --unit mj-constraint_scalar --out /var/tmp/constraint-scalar-whole
python3 experimental/constraint-solvers-candidate/tests/check.py --phase small --unit mj-constraint_order --out /var/tmp/constraint-order-small
python3 experimental/constraint-solvers-candidate/tests/check.py --phase whole --unit mj-constraint_order --out /var/tmp/constraint-order-whole
```

Do not treat an unrestricted `--phase whole` run as a passing release gate: the
solver unit is intentionally still reported open. The next proof step is to
contract the QCQP helpers and discharge the caller/workspace obligations using
the proved Cholesky boundary, then close the iteration invariants.
Integrated performance comparisons still require reusable workspaces and
C-equivalent assembled inputs; the process timing above is only diagnostic.

The portable evidence is in `evidence/2026-10-01/summary.json`, with full primitive
SPARK reports and per-case differential results. The failed whole-unit run is
retained as failed evidence, alongside the successful minimal diagnosis:

```sh
python3 experimental/constraint-solvers-candidate/tests/check.py --phase small --unit mj-constraint_solvers --only Factor --no-inlining --timeout 1 --wall-timeout 90 --out /var/tmp/constraint-factor-diagnostic
```

The new helper proof and edge tests are reproduced with fresh output directories:

```sh
python3 experimental/constraint-solvers-candidate/tests/check.py --phase small --unit mj-constraint_solvers-cholesky --proof per_path --timeout 15 --out /var/tmp/constraint-cholesky-small-repro
python3 experimental/constraint-solvers-candidate/tests/check.py --phase whole --unit mj-constraint_solvers-cholesky --proof per_path --timeout 15 --out /var/tmp/constraint-cholesky-whole-repro
```

The normal build commands now also build and execute `cholesky_edges`.
`tests/compare_previous.py` accepts `--before`, `--after` and `--out`; optional
`--timing-repeats 300 --rounds 7` reproduces the diagnostic workload. Record CPU
affinity and load when comparing timings. The evidence directory preserves the
baseline source snapshot, binary hashes, compiler identity, flags, hardware,
raw samples, proof diagnostics and numerical test results.
