# MuJoCo 3.15 alignment candidate

Reference: official [3.15.0 release](https://github.com/google-deepmind/mujoco/releases/tag/3.15.0),
commit `9ea3cdfcae93bf2cc4dc0e1a1627c5a39a1e06e5`, verified 2026-10-07.
The production pin is still 3.14.0 until all engine consumers migrate together.
The generator recognizes exact 3.14 and 3.15 schemas; each generated reader
accepts only its own dumped ABI. Old MJB images are not relabelled.

## Support fusion integrated checkpoint, 24 October 2026

The published solver fusion passes the complete FLEX gates: 456 cases in both
3.15 profiles and 420 in production 3.14 validation. A quiet, paired six-model
comparison with r140 gives mean duration changes from −0.37% to −2.89%; every
95% interval includes zero. No speedup or equivalence is established. Ada still
takes about 2.38–3.12 times historical C3.15 on these workloads. The current
C3.17 migration and global solver Gold remain separate, unfinished work.
[Raw timing, uncertainty, runtime receipts and frozen inputs](evidence/20261024-support-fusion-timing-r145/README.md).

## Verified foundation, frozen r3

The real 3.15 headers have 97 size entries and 483 pointer fields. Regeneration
removes `nflexevpair`, `flex_internal`, `flex_evpairadr`, `flex_evpairnum` and
`flex_evpair` consistently from the model, layouts, allocation/release, readers,
reference validation and test serializer. Fixed option/visual/statistic layouts
are unchanged. The corpus was compiled by the actual 3.15 wheel.

- 96 models compiled, zero skipped; all ten Ada suites and 72 Python tests pass.
- All 13 `Read_Sizes_k` minima close 656 obligations (630 proof, 26 flow),
  zero warnings, no skipped scope or assumptions. Successful decoding maps each
  field to its exact signed 64-bit byte value. Every helper preserves fields
  outside its chunk, including on rejection.
- The native SDF fixture loads successfully. A type-8 geometry without a mesh
  reference rejects with `Invalid_Reference/Geom_Dataid`; plugin detection uses
  `nplugin`, rather than treating all SDF geometries as plugins.

Receipts, logs, manifests, exact frozen reader/generator inputs and upstream
delta inventory: [evidence](evidence/20261007-foundation-r3/size-minima.json).
These prove the stated minima on r3. They do not prove the complete MJB loader,
all validation/engine callers, real-arithmetic accuracy, or timing parity.
The r4 generator also adds the `Sizes_Decoded` functional model and the public
`Read_Sizes` postcondition. Their fresh proofs close 198 and 23 obligations,
respectively, without warnings. The combined 877-obligation closure uses the r3
minima: an explicit source audit confirms every reader body and external callee
input is unchanged, and the only Ada delta is the parent specification/model.
See the [composition receipt](evidence/20261007-foundation-r4/size-closure.json).

The same generator/contracts are applied to the production 3.14 reader, keeping
its actual 98-size/487-pointer ABI. Fresh 3.14 validation passes all ten Ada
suites, 72 Python tests and 96 compiled corpus models. All 15 size-reader/model
scopes close 885 obligations (856 proof, 29 flow), zero warnings. This is the
historical frozen production snapshot, preceding the new FLEX helpers. All 15
generator outputs passed isolated regeneration. See the
[production receipt](evidence/20261007-production-314/size-closure.json).
The proved functional scope is successful decoding and helper frame behavior;
full failure-diagnostic/prefix specifications and the complete loader's array
content contracts remain separate work.

## FLEX migration and minimum proofs, 2026-10-07

The coordinated overlay removes retired internal-contact storage and imports,
filters static/static pairs at dispatch, and implements C 3.15's greedy contact
selection followed by stable compaction. Material loading uses the actual
24-value 3D stiffness block; membrane blocks remain 21 values. The shared
`Without_Flex` factory helper preserves every non-FLEX size field exactly.
Its refreshed r6 proof and the ABI-dependent stiffness-stride proof each close
three obligations without warnings; all r6 foundation tests pass.
See the [foundation receipts](evidence/20261007-foundation-r6/results.json).

Bending now gathers world-space vertex velocities, accumulates forces per vertex,
and scatters reactions through each complete ancestor chain. Welded attachments,
arbitrary slide-axis ordering, free joints and vertex offsets are included.
The r4 runtime closure passes 78 contact/state cases, 66 force trajectories and
246 constrained trajectories of 100 steps against actual C 3.15. Extra cases
include independently rotated vertices, hinge/weld offsets, free-joint bending
and two tetrahedra with distinct reference geometry.
See the [runtime receipts](evidence/20261007-flex-r4/results.json).

The r7 proof refinement widens the world-velocity domain, unfolds the fixed
four-term row without changing its accumulation order, and distinguishes the
spring curvature addition from damping. Its three minimum proofs close 93
obligations: `Prefix_Count` 13, `Compact` 45, `Bending_Update` 35. These establish
the mask/count relation, stable survivor order, preserved prefix/tail, and the
ordered floating-point row with its branch and bounds. Two unsuppressed GNATprove
notes about recursive model contracts occur in each selection scope; their
obligations are closed, and the receipts retain `passed=false` for those
non-warning-free runs. There are no assumptions, suppressions or skipped scope.
The bending scope has no warnings. The complete force/collision callers,
global physics and performance remain separate. See the
[minimum closure](evidence/20261007-flex-proof-minima/r7/closure.json).
Fresh validation of the r7 refinement also passes 78/78 contact/state cases,
66/66 force trajectories and 246/246 constrained trajectories. Every source hash
matches the r7 proof snapshot exactly. See the
[final runtime receipt](evidence/20261007-flex-r7/results.json) and
[source composition audit](evidence/20261007-flex-proof-minima/r7/runtime-source-match.json).
The fresh production 3.14 regression also passes its 78/78 contact/state cases,
54/54 force trajectories and 234/234 constrained trajectories. Its ten Ada
suites, 72 Python tests and isolated regeneration pass, and foundation inputs
match the worktree freeze exactly. Its engine is copied directly from the live
sources with no modern overlay or fixture translation. See the
[production foundation](evidence/20261007-production-314-r2/results.json) and
[production FLEX receipt](evidence/20261007-flex-production-314-r1/results.json).
The production `Without_Flex` and stiffness-stride helpers also each close
three fresh obligations without warnings on that exact 3.14 snapshot.

Fixture migration removes the rejected `internal` XML attribute. For legacy
bare XYZ-slide vertex bodies with explicit inertia and joint damping, a massless
noncolliding marker geom preserves damping while satisfying the 3.15 compiler's
new admission rule. The four retired-internal cases remain: they check absence
of same-FLEX internal contacts and still compare external contacts, forces and
trajectories. Negative r1/r2/r3 receipts and failed minimum attempts are retained.
SNH models explicitly reject until their cubic/volume energy, PSD tangent and
discrete integration are implemented; they are never evaluated as StVK.

## Coordinated work still required

### Sparse elliptic Newton performance investigation

The r7 release candidate passes the same 78 state/contact, 66 force and 246
constrained cases as its validation build. A quiet CPU-0 measurement against the
actual 3.15 native wheel uses twelve alternating blocks, eight 100-step batches
per block and one excluded warmup trajectory. Parsing, model creation/reset and
output remain outside the timed step loop. The independent baseline in this
first measurement is deliberately the same Ada binary: its near-one ratio is
calibration, not an optimization gain.

The cross-FLEX `element_elastic_cross_elliptic_6` case measures 1036.35 us/step
in Ada and 25.74 us/step in C: paired median 40.32, bootstrap 95% interval
[38.65, 41.46]. The other five cases measure 2.53--3.31 times C. These workload
ratios do not establish performance for unsupported MuJoCo features.

A separate 20,000-step instrumented run matches the C trajectory. Gprof
attributes 89.13% of sampled process time to the `Evaluate_Block` symbol and
5.53% to sparse numerical factorization; inlining prevents treating the first
number as a line-level attribution. Source inspection finds the mixed-row
Newton path repeatedly assembling all DOF pairs with two nested contact-dimension
loops, including inactive blocks and zero columns. C 3.15's `HessianConeFolded`
instead factors each local cone Hessian, replaces its sparse contact rows by
`Lc' * Jc`, and builds a lower-triangular weighted Gram matrix before adding
mass. The shared solver candidate now implements that folded path for sparse
elliptic solves. Its new minimum contracts specify the ordered transform and
Gram arithmetic. Five fresh minima close 214 checks: `Add_Scaled` 13,
`Fold_Value` 98, `Unfold_Fold` 58, `Fold_Column` 36 and `Gram_Update` 9.
They prove the ordered floating-point transform, its finite bounds and the
specified weighted Gram arithmetic. The model explicitly handles all six
possible prefix lengths. Four scopes are warning-free; `Fold_Column` retains
one unsuppressed GNATprove array-initialization precision note, with no open
obligations. No new assumptions, suppressions or trusted bodies are used.
These minima do not close the complete assembly/factor/solver callers or prove
an exact real-arithmetic Hessian identity.

The new r8 release source hashes exactly match the proof snapshot and pass all
78 state/contact cases, 66 force trajectories and 246 constrained trajectories.
Its quiet paired release comparison uses the same six workloads and actual C
3.15 native SIMD implementation:

| Workload | Prior Ada us/step | New Ada us/step | C us/step | Paired new/prior, 95% interval | Paired new/C, 95% interval |
| --- | ---: | ---: | ---: | --- | --- |
| membrane_Newton_3 | 10.63 | 10.41 | 4.11 | 0.978 [0.934, 1.022] | 2.537 [2.470, 2.627] |
| free | 18.03 | 17.88 | 5.37 | 0.998 [0.957, 1.021] | 3.330 [3.289, 3.387] |
| element_2_sphere | 11.28 | 11.15 | 4.46 | 0.984 [0.950, 1.008] | 2.493 [2.432, 2.522] |
| element_mixed_pyramidal_3 | 27.96 | 27.70 | 10.33 | 0.986 [0.970, 1.055] | 2.690 [2.670, 2.733] |
| element_elastic_cross_elliptic_6 | 1032.72 | 123.63 | 24.53 | 0.119 [0.118, 0.122] | 5.032 [4.857, 5.094] |
| element_elastic_self_bvh_pyramidal_3 | 54.07 | 54.09 | 16.44 | 1.002 [0.972, 1.016] | 3.281 [3.213, 3.337] |

The elliptic case reduces time by 88.13% (paired median); the other five
intervals include one, so their small changes are not claimed as speedups or
regressions. All measured trajectories match C within 2e-9 absolute/relative
tolerance. The large improvement is not C parity: the case remains about five
times slower, and complete feature/Gold coverage is still open. Dense cone
rank updates, C's cached fold/update cost gate and complete caller proofs remain
port work. Instrumented times are diagnostic and are not release timings.
See the [minimum closure](evidence/20261007-cone-fold-r8/closure.json).
The shared solver change also passes a fresh validation build against actual
C 3.14: 78/78 state/contact cases, 54/54 force trajectories and 234/234
constrained trajectories. The production foundation remains its actual 3.14
ABI and no modern FLEX overlay or fixture migration is applied in that run.
See [production regression](evidence/20261007-cone-fold-r8/production-314/results.json)
and [paired release measurements](evidence/20261007-cone-fold-r8/paired-time/results.json).
The separate r8 profile repeats 100,000 steps and matches the C trajectory.
Sparse numerical factorization now accounts for 44.17% of sampled process time,
the inlined elliptic-response/assembly symbol for 17.73%, and sparse backsolve
for 6.14%. There are 389,000 numerical factor calls over 102,000 evaluated
states, including endpoint evaluations outside the 100,000 integration steps.
This makes factorization/reuse the next measured target; the profile does not
establish which of its guards, layout or arithmetic contributes most. See the
[profile receipt](evidence/20261007-cone-fold-r8/current-profile/results.json).

The sparse-factor follow-up replaces the old `Update`/`Scale` argument
subtypes with the same explicit static domains and caches C's row multiplier.
Result acceptance guards remain. Division/root setup and the ordered row loops
are proved as separate minima; no assumption, suppression or new trusted body
is introduced. Fifteen scoped receipts close **481 checks**, including the
ordered CSC updates, off-diagonal publication, pivot-clamping/root relation,
row/vector frames, diagonal progression and ordered `L^-T` scatter.
`Prepare_Row` and `Factor` are verified only against their current finite-bound
and integrity contracts: the complete ordered factor model, symbolic closure,
forward four-lane solve and whole solver callers are still unfinished proof
engineering. The existing unsuppressed `Sqrt` modeling warning remains visible.
See [scoped closure](evidence/20261007-sparse-args-r15/closure.json).

The final release snapshot passes **395/395 bitwise native-C comparisons** of
symbolic layouts, factors, ranks and sparse solves, plus **78/78 state/contact,
66/66 force and 246/246 constrained trajectories** against actual C 3.15.
The native corpus covers sizes 1–128, multiple structural patterns, deficient
pivots, threshold neighbours and signed zeros. These finite tests are distinct
from universal equivalence proofs. The 441-file release source map is identical
to the final proof freeze; reused earlier minima have byte-identical bodies and
unchanged non-body context. See [native comparison](evidence/20261007-sparse-args-r15/native-315/cases/results.json)
and [source audit](evidence/20261007-sparse-args-r15/runtime-proof-source-audit.json).

The first r11 timing run is retained as diagnostic evidence because archival
compression overlapped its early workloads. Its quiet-window flag is not treated
as acceptance evidence. WSL I/O errors interrupted the first production-3.14
regression; its generated binaries were found truncated after recovery. The
already completed 3.15 and baseline release binaries and source hashes were
rechecked and remain intact. The fresh final-source production regression now passes **78/78 state/contact,
54/54 force and 234/234 constrained trajectories**. The final quiet release
comparison uses 24 alternating blocks, 16 measured 100-step trajectories per
block, excluded warmups and pinned CPU 0; no compilation, archival or compression
runs concurrently. All measured states match actual C 3.15 within 2e-9.

| Workload | Prior Ada us/step | New Ada us/step | C us/step | Paired new/prior, 95% interval | Paired new/C, 95% interval |
| --- | ---: | ---: | ---: | --- | --- |
| membrane_Newton_3 | 14.55 | 14.48 | 5.41 | 0.997 [0.971, 1.023] | 2.644 [2.608, 2.731] |
| free | 18.21 | 18.19 | 5.62 | 0.990 [0.978, 1.002] | 3.177 [3.146, 3.208] |
| element_2_sphere | 11.44 | 11.19 | 4.64 | 0.986 [0.979, 0.993] | 2.418 [2.370, 2.438] |
| element_mixed_pyramidal_3 | 28.46 | 27.42 | 10.54 | 0.961 [0.956, 0.972] | 2.600 [2.583, 2.623] |
| element_elastic_cross_elliptic_6 | 126.02 | 100.58 | 25.04 | 0.804 [0.781, 0.812] | 3.968 [3.907, 4.042] |
| element_elastic_self_bvh_pyramidal_3 | 54.96 | 50.15 | 17.48 | 0.867 [0.857, 0.883] | 2.795 [2.742, 2.849] |

Ratios are medians of paired block ratios; they need not equal the ratios of
the separately summarized times. The elliptic case reduces time by **19.65%**
(95% interval 18.80–21.88%), and the self-collision case by **13.27%**
(11.72–14.31%). Sphere and mixed-pyramidal cases also show smaller resolved
gains; membrane and free intervals include one, so their small shifts are not
claimed as speedups. No resolved regression is observed in these six cases.
The slow elliptic workload remains **3.968x C** [3.907, 4.042]; this is progress,
not parity or full-port completion. See [production regression](evidence/20261007-sparse-args-r15/production-314/results.json)
and [paired timings](evidence/20261007-sparse-args-r15/paired-time/results.json).


## CSC scratch headroom, 7–8 October 2026

The CSC subtraction no longer tests `Residual` after every scalar update.
The public `Factor` input domain is unchanged. A constructive ghost budget
bounds the scratch vector across all rows, including valid patterns whose fill
closure is not established: each strictly ordered CSC prefix changes any entry
at most once, and each numeric row spends at most `Max_Dofs` contributions.
The exact power-of-two envelope is bounded by
`(128*128+1)*2**799 < 1e245`. The step and budget arithmetic is static ghost code;
there is no runtime counter or additional scan. Pivot, Operand, scaled-row and
reverse-scatter guards remain.

**334 checks close in nine changed scopes**, including the ordered expression
and frame of `Update_Row`, its headroom lemma and caller composition through
`Prepare_Row`, `Clear_Row` and `Factor`. The existing Sqrt warning stays visible.
This closes the scratch bound used to remove this guard; the complete ordered
factor/assembly model, symbolic fill closure, forward solve and global solver
caller proofs remain unfinished. See [closure](evidence/20261008-sparse-headroom-r24/closure.json).
The final source passes **395/395 bitwise native-C cases**, **390 integrated
C 3.15 checks** and **366 production C 3.14 checks**. All 441 release sources
match the immutable final proof freeze; the reused r23 row body/specification
and other 440 files are unchanged. See [source audit](evidence/20261008-sparse-headroom-r24/runtime-proof-source-audit.json).

The updated instrumented full-process profile attributes **349/1047 samples
(33.33%)** to factorization and **259/1047 (24.74%)** to Newton, chiefly Hessian
Gram assembly. Raw histogram addresses are mapped using exact ELF symbol sizes:
plain gprof misleadingly labels 271 samples as `Evaluate_Block`, whose actual
symbol contains only two. Sampling, inlining and initialization/reset/I/O prevent
an exact instruction-cost or release-time claim. The initial profiling run
failed before simulation with an omitted stack limit; its failed receipt and
runner are retained. The corrected run uses the same instrumented binary and
matches actual C to 2.78e-17. See [profile audit](evidence/20261008-sparse-headroom-r24/profile-audit.json).

The final quiet comparison alternates prior r15 Ada, current r24 Ada and actual
SIMD C 3.15 over **24 blocks × 16 measured 100-step trajectories**, excluding
warmups, pinned to CPU 0. No other build, proof, archive or compression runs in
this window. Every state matches C within 2e-9.

| Workload | Prior Ada us/step | Current Ada us/step | C us/step | Paired current/prior, 95% interval | Paired current/C, 95% interval |
| --- | ---: | ---: | ---: | --- | --- |
| membrane_Newton_3 | 10.52 | 10.52 | 4.22 | 0.992 [0.971, 1.005] | 2.487 [2.445, 2.521] |
| free | 17.97 | 18.18 | 5.72 | 1.006 [0.992, 1.026] | 3.159 [3.129, 3.242] |
| element_2_sphere | 11.40 | 11.20 | 4.64 | 0.989 [0.983, 1.006] | 2.428 [2.377, 2.452] |
| element_mixed_pyramidal_3 | 27.38 | 27.22 | 10.54 | 0.994 [0.986, 1.007] | 2.620 [2.602, 2.627] |
| element_elastic_cross_elliptic_6 | 101.62 | 97.33 | 25.42 | 0.935 [0.924, 0.963] | 3.713 [3.547, 3.829] |
| element_elastic_self_bvh_pyramidal_3 | 46.99 | 45.24 | 16.57 | 0.963 [0.950, 0.974] | 2.747 [2.703, 2.775] |

Paired median block ratios need not equal ratios of the separate timing medians.
The elliptic case improves **6.54%** (95% interval **3.69–7.63%**), and self
collisions **3.72%** (**2.61–4.97%**). The other four intervals include one:
no resolved improvement or regression is claimed for them. Absolute timings
from older runs are not used to calculate these gains. The worst case remains
**3.713× C [3.547, 3.829]**; overall parity, full feature coverage and complete
Gold remain open. See [paired timing](evidence/20261008-sparse-headroom-r24/paired-time/results.json).

P95 trajectory tails are also retained; these pooled percentiles are distinct
from the paired mean ratios above.

| Workload | Prior Ada p95 us/trajectory | Current Ada p95 us/trajectory | C p95 us/trajectory | Current/prior p95, paired-block bootstrap 95% |
| --- | ---: | ---: | ---: | --- |
| membrane_Newton_3 | 1159.3 | 1470.1 | 527.7 | 1.268 [0.961, 1.348] |
| free | 2178.6 | 2141.4 | 675.7 | 0.983 [0.844, 1.152] |
| element_2_sphere | 1244.5 | 1226.4 | 510.6 | 0.986 [0.948, 1.051] |
| element_mixed_pyramidal_3 | 3032.6 | 3206.0 | 1173.4 | 1.057 [0.956, 1.305] |
| element_elastic_cross_elliptic_6 | 14895.0 | 13969.9 | 4118.4 | 0.938 [0.897, 0.966] |
| element_elastic_self_bvh_pyramidal_3 | 5239.5 | 5067.8 | 1889.3 | 0.967 [0.930, 1.014] |

The larger point estimates for membrane and mixed-pyramidal tails have intervals
including one; no causal tail regression is established. Elliptic p95 improves,
while self-collision p95 uncertainty still includes one. The audit resamples
24 paired blocks with 5000 draws and performs no further timing run.
See [tail audit](evidence/20261008-sparse-headroom-r24/paired-time/tail-audit.json).

Disk C: filled during archival after the native comparison. Only verified,
completed or interrupted generated object/proof caches were removed and trimmed;
source snapshots, receipts, failed attempts and every required benchmark binary
were preserved. The subsequent production regression and quiet measurement
completed successfully.

## Cached sparse Gram rows, 8 October 2026

The r38 candidate follows the scalar branch of C 3.15
`mju_sqrMatTDSparseNumeric`: compute weight times the left value once per
result-row contribution and skip zero scales. Quadratic rows read the existing
dense Jacobian; folded cone rows read their packed local matrix. Neither path
copies a Jacobian row. `Gram_Scale` and `Gram_Scaled` take `Real` with static
domain contracts, removing the repeated `Folded_Value` argument conversions.
The final `Operand` guard is retained: the permitted folded domain is
`+/- 6 * 2**437`, so arbitrary allowed contributions can exceed `1e120`.

Twelve arithmetic, source, ordering, prefix and preservation minima close
**508 checks**. Their ordered floating expressions and unchanged-cell relations
are stronger than bounds alone. The archived reuse audit verifies identical
owned contracts/bodies, scalar type bounds and external proof dependencies.
At r38 the complete `Gram_Row` scope had **123 proved checks and three open obligations**:
preservation of other rows, composition of the preservation precondition, and
the complete preservation assertion. These are unfinished proof engineering,
not a mathematical reason to accept Silver. Full assembly and caller proofs
also remain open. No new assumption, suppression or trusted body was introduced.
See [proof closure](evidence/20261008-gram-r38/closure.json),
[type/context audit](evidence/20261008-gram-r38/proof-context-type-audit.json)
and [all attempts](evidence/20261008-gram-r38/attempts).

The fresh native probe passes **700/700 bitwise ordered-model cases**, including
packed/dense sources, empty and irregular supports, signed zeros, subnormals,
underflow, extreme values and partial rejection, with sizes from 1 to 128.
Of these, **434 accepted zero-seed cases match the actual C scalar/sparse branch
bit for bit**. The 590 accepted and 110 rejected cases have different scopes:
nonzero seeds and early numeric-limit rejection use the explicit ordered model.
This is not a universal C equivalence claim or a supernode benchmark.
The 3.15 release passes **390 integrated checks** (78 state, 66 forces, 246
constrained), and the unchanged 3.14 production pin passes **366** (78, 54, 234)
with validation checks enabled. All 441 frozen proof inputs match the 3.15
release and native snapshot. See [combined receipts](evidence/20261008-gram-r38/results.json).

The quiet benchmark uses r24 as the prior Ada baseline, r38 as the candidate,
and normal native SIMD C 3.15, on CPU 0. It alternates 24 blocks with 16 measured
100-step trajectories per block and excludes one warmup trajectory. No build,
proof or archival job overlaps timing. All final states agree within `2e-9`.
Ratios are medians of paired block-mean ratios; the absolute times below are
separate median block means and must not be divided to reconstruct those ratios.

| Workload | Prior Ada us/step | r38 Ada us/step | C us/step | r38/prior, bootstrap 95% | r38/C, bootstrap 95% |
| --- | ---: | ---: | ---: | --- | --- |
| membrane_Newton_3 | 10.735 | 10.711 | 4.253 | 1.001 [0.981, 1.029] | 2.515 [2.473, 2.540] |
| free | 18.271 | 18.327 | 5.614 | 1.002 [0.982, 1.022] | 3.233 [3.158, 3.281] |
| element_2_sphere | 11.390 | 11.463 | 4.721 | 1.014 [0.990, 1.023] | 2.417 [2.384, 2.451] |
| element_mixed_pyramidal_3 | 27.544 | 27.813 | 10.752 | 1.007 [0.993, 1.016] | 2.584 [2.522, 2.609] |
| element_elastic_cross_elliptic_6 | 96.361 | 86.601 | 25.788 | 0.901 [0.895, 0.912] | 3.400 [3.319, 3.421] |
| element_elastic_self_bvh_pyramidal_3 | 46.378 | 46.571 | 16.696 | 0.994 [0.985, 1.021] | 2.798 [2.752, 2.849] |

The elliptic workload improves **9.94%**, with a 95% interval of **8.83–10.46%**.
The other five intervals include one, so neither gains nor regressions are
resolved there. Elliptic pooled p95 improves 7.64% (paired-block bootstrap
4.04–10.49%); all five other p95 intervals include one. C parity is still absent:
the worst median ratio remains **3.40 times C**. Raw observations, model/input
hashes, binary hashes, compiler flags, hardware and both drivers are retained in the
[paired data](evidence/20261008-gram-r38/paired-time/results.json) and
[tail audit](evidence/20261008-gram-r38/paired-time/tail-audit.json).
The r38 evidence inventory verified **2265 hashes**, preserving all previous
1742 entries. The complete port, production 3.15 adoption, global Gold and
representative C parity remain unfinished.

## Named Gram models and updated profile, 8 October 2026

The r45 candidate names two existing properties as static ghost expression
functions: `Gram_Ordered_Prefix` describes each ordered floating update and
`Gram_Unchanged` describes every cell outside the processed support pairs.
They retain the complete input domain, evaluation order, zero branch and
unchanged-cell relation. The helper contracts and loop invariants use these
same models, reducing duplicated nested quantifiers without adding assumptions
or runtime scans. The per-iteration ghost snapshot is a local constant.

The two models close **23 and 12 checks**; the updated preservation and row
progress lemmas close **59 and 102**. Together with ten unchanged minima whose
owned contracts, bodies, scalar bounds and external dependencies were audited,
the selected closure has **514 checks across 14 scopes**. The complete
`Gram_Row` scope has **61 proved checks and one open postcondition obligation**.
The final composition remains unfinished proof engineering; this is not a
Silver exception. Full assembly and caller Gold remain open.
See [closure and reuse audit](evidence/20261008-gram-model-r45/closure.json)
and [all proof attempts](evidence/20261008-gram-model-r45/attempts.json).

Fresh r45 builds pass **700 ordered-model cases**, including **434 bitwise
matches to actual C**, plus **390 integrated 3.15 checks** and **366 production
3.14 validation checks**. The native and 3.15 release builds match all **441**
frozen proof inputs. These numerical results do not close the remaining formal
obligation. See [combined receipts](evidence/20261008-gram-model-r45/results.json)
and [source audit](evidence/20261008-gram-model-r45/runtime-source-audit.json).

The r38 instrumented full-process profile collected **970 histogram samples**
and matches the actual C trajectory to `1.11e-16`. Sized ELF symbols attribute
312 samples (**32.16%**) to sparse factorization, 174 (**17.94%**) to the primal
Newton loop, 62 (**6.39%**) to sparse backsolve, and 45 (**4.64%**) to symbolic
construction. The actual `Evaluate_Block` symbol contains only six samples;
gprof's flat-label attribution of 19.59% to that name includes adjacent code.
The mapper now supports `--all-symbols`, retains aliases as one bucket and
accounts separately for samples outside sized text symbols. Four-byte bins,
inlining and full-process initialization/I/O limit this attribution; it is not
a release timing or a measurement of the Ada/C cost difference.
See [sized-symbol audit](evidence/20261008-gram-model-r45/profile/sized_symbols.json).

A new quiet comparison uses r38 as the prior Ada baseline and normal SIMD C
3.15, with 24 alternating blocks of 16 measured 100-step trajectories, CPU 0,
one warmup per block and state tolerance `2e-9`. All six paired median-ratio
intervals and all six paired-block p95 intervals include one: these proof edits
show no resolved speed gain or regression. The worst current/C paired median
is **3.321 [3.266, 3.387]**, on the elliptic crossing workload. The corresponding
current/prior ratio is **1.0048 [0.9996, 1.0102]**. Parity remains absent.
See [raw timing and build metadata](evidence/20261008-gram-model-r45/paired-time/results.json)
and [tail audit](evidence/20261008-gram-model-r45/paired-time/tail-audit.json).

C 3.15 `mju_cholFactorNumeric` consumes contiguous CSR numeric rows and direct
CSC offsets. At r45 the candidate retained dense numeric H/L storage with a
sparse pattern. Compact numeric storage, C's cached cost gate and rank updates
were still performance targets; the following r53 section records the first
measured representation change. The r45 inventory verified **2709 hashes**,
preserving all **2265** prior entries. The complete port and representative C parity remain unfinished.

| Upstream change | Remaining port work |
| --- | --- |
| Removed internal FLEX collisions | Candidate state/dispatch migration tested; complete caller proofs and atomic production adoption remain. |
| Articulated FLEX attachments | Standard force/reaction path tested; discrete CG assembly and optimized motion-axis path remain. |
| FLEX bending coupling and Hessian cache | World-space passive bending tested and ordered row proved; discrete cross-coordinate Hessian/cache integration remains. |
| Experimental 3D SNH elasticity | Port the discrete-integrator path and PSD Hessian projection; preserve default StVK. |
| Actuator world orientation | SO3 site/refsite candidate now composes body-quaternion times site-quaternion, with noncommuting trajectory tests; ordinary scalar-site integration and caller Gold remain. |
| Actuator dampratio | Match operational-space inertia in model compilation; test multi-DOF tendon/site actuators. |
| Capsule multicontact | Port the new single-shot capsule collision branches and contact ordering. |
| insidesite enclosed sensor | Implement directed clearance/protrusion behavior and corresponding compiler attribute. |
| MJB buffers above 2 GiB | Replace the port's Natural-sized buffer/index limit with a coordinated wide-size representation. |

The integrated movement candidate uses the frozen foundation and the current
engine sources. Its numerical tests compare full trajectories with the actual
C 3.15 engine; they are independent of formal and performance acceptance.
The validation build passes 106 constraint/load trajectories and 226 mixed-force
trajectories of 100 steps, plus three activation/capacity atomicity checks.
See the [movement receipts](evidence/20261007-movement-r1/results.json).
The compiler still relies on upstream-produced MJBs. Full MuJoCo feature
coverage, complete Gold and representative integrated C performance parity
remain open.

## Contiguous Cholesky candidate: r53 and row-view follow-up

The new `Packed_Cholesky` backend stores numeric L rows contiguously and uses
those rows directly for reverse factorization and backsolve. The sparse caller
no longer keeps a persistent dense L matrix. Factorization overwrites every
used row and clears only the touched scratch slots; the native probe starts L
with `1e120` to expose accidental reuse of old values.

This is a partial representation change: H is still dense, symbolic CSR/CSC
indices remain two-dimensional, allocation still reserves triangular capacity,
and scalar rank updates use an expand/update/pack bridge. Direct compact H
assembly, flat metadata with cached CSC-to-L slots, packed rank updates and C's
cached cost gate remain unfinished.

The r53 selected closure contains **326 checks across 12 minimum scopes**.
`Expand` closes its obligations but emits an imprecise nested-array initialization
warning; that receipt does not pass the driver's warning-free gate. Full
factorization, backsolve and caller functional Gold remain open. No new trusted
body, assumption or suppression is introduced.
See [scoped closure](evidence/20261008-packed-cholesky-r53/closure.json).

Fresh r53 builds pass **395 native C comparisons**, **390 integrated 3.15
checks** and **366 production 3.14 validation checks**. The native and 3.15
release builds match all **443** frozen proof inputs. These finite differential
cases do not prove universal C equivalence.

The quiet r53 comparison against r45 uses 24 alternating blocks, 16 measured
100-step trajectories per block, CPU 0 and normal SIMD C 3.15. Every trajectory
passes the state comparison. The elliptic crossing workload regresses by
**3.86% [2.48%, 5.81%]** and self-collision by **2.85% [0.37%, 3.70%]**;
the other four median-ratio intervals include one. The sphere workload also
has a resolved p95 regression: **18.41% [0.35%, 25.63%]**. The worst current/C
median ratio is **3.463 [3.408, 3.533]**. This candidate has not established a
performance improvement or C parity.
See [raw paired timing](evidence/20261008-packed-cholesky-r53/paired-time/results.json)
and [paired tail audit](evidence/20261008-packed-cholesky-r53/paired-time/tail-audit.json).

The r53 instrumented full-process profile attributes 331 of 1023 samples
(**32.36%**) to packed factorization, 188 (**18.38%**) to the primal Newton loop
and 60 (**5.87%**) to packed backsolve. The inner row update remains the main
factorization hotspot. These sampled, instrumented full-process observations
identify a target; they do not establish the cause or size of the release
regression. The follow-up replaces repeated whole-vector indexing with a
contiguous row view while preserving the exact ordered update contract.
The r60 row-update proof closes **99 checks**, including the ordered component
relation, the frame property and the scratch envelope. Its constructive ghost
prefix lemma closes **68 checks**, and the single-cell setter closes **9**.
Together with audited unchanged scopes, the selected closure has **420 checks
across 14 scopes**. Ghost snapshots and lemmas are removed from executable code;
no precondition was narrowed to make this update proof pass. Fresh native tests
again pass **395/395** against C. The 3.15 release integration also passes **390/390** checks; the production
3.14 validation build passes **366/366**. Both use the same owned packed kernel
and caller as the r60 proof snapshot. Whole factorization/backsolve/caller Gold
remains pending.
See [r60 scoped closure](evidence/20261008-packed-row-view-r60/closure.json)
and [native/integrated receipts](evidence/20261008-packed-row-view-r60/results.json).

A fresh quiet r60 comparison against r45 still resolves three median regressions:

| Workload | Current/prior paired median [95% CI] | Current/C paired median [95% CI] |
| --- | --- | --- |
| membrane Newton | 0.9979 [0.9818, 1.0109] | 2.5020 [2.4890, 2.5251] |
| free | 1.0014 [0.9669, 1.0325] | 3.4099 [3.2536, 3.6885] |
| two-sphere contact | 1.0106 [0.9980, 1.0367] | 2.4811 [2.4087, 2.5929] |
| mixed pyramidal | 1.0388 [1.0152, 1.0665] | 2.6592 [2.6330, 2.7002] |
| elliptic crossing | 1.0461 [1.0312, 1.0562] | 3.5605 [3.4635, 3.5993] |
| self-collision | 1.0211 [1.0031, 1.0322] | 2.8607 [2.8134, 2.9008] |

All trajectory states pass. The worst central current/C ratio is **3.561**;
no representative C parity or median improvement is established. The absolute
free-workload timings vary markedly from the earlier run; comparisons use the
paired blocks in this run, not ratios across sessions. The p95 ellipse ratio is
**1.0967 [1.0086, 1.1614]**, while self-collision is **0.9606 [0.8551, 0.9995]**;
the other four p95 intervals include one. The tail improvement does not erase
the self-collision median regression.
See [raw r60 timing](evidence/20261008-packed-row-view-r60/paired-time/results.json)
and [tail audit](evidence/20261008-packed-row-view-r60/paired-time/tail-audit.json).

The numeric factor's executable symbol shrinks from 2892 to 2868 bytes in the
native probe, but both versions retain index/range/overflow/invalid-data check
call targets. Static size is not a speed or check-frequency measurement.
The row view closes its functional proof but does not resolve the regression.
The sparse rank-update bridge is used only by `Build_Scalar_Hessian`; the
non-scalar cone path builds H and calls `Factor_Hessian` each time. Removing
that bridge cannot alone address the measured elliptic hotspot. The next
representation work must cover flat CSR column indices, direct CSC-to-numeric
L slots, compact H assembly and the scalar rank-update path, matching the
actual C traversal and operation order.

The r60 evidence inventory verified **3580 hashes**, preserving all prior
entries. The [3.14 follow-up receipt](evidence/20261008-packed-row-view-r60/followup/results.json)
records the independent production regression and source-identity check.
All negative proof attempts and performance observations remain archived.
The complete port, full functional Gold and representative C parity remain open.

## Flat CSR/CSC metadata candidate: r67

The numeric factor/backsolve call path now uses a `Flat_Pattern`: flat typed
CSR column indices, flat CSC row indices, separate offsets/counts and a direct
CSC-to-numeric-L slot map. The inner update visits matching contiguous L and
column slices and reads the multiplier directly from that cached slot, following
3.15 `mju_cholFactorNumeric`. CSC order and the four-lane backsolve grouping are
unchanged. A private `Max_Dofs`-capacity scratch vector lets the compiler use
the established DOF index subtype without changing the visited row support.
The production DOF limit is still 128; arbitrary larger C models remain pending.

The sparse caller reuses `Flat_Pattern.Address` for conversion/rank-update
bridges. The duplicate prefix-offset construction and separate offset vector
introduced during this conversion have been removed in r67. The symbolic
construction still produces the old two-dimensional pattern first; direct flat
symbolic construction, actual-NNZ allocation, compact H assembly and packed
rank updates remain unfinished. The scalar rank-update bridge still expands
and packs a dense matrix. This is not the completed C representation.

The selected new closure has **408 checks across 11 minimum scopes**: ordered
column separation, exact row updates and frame/budget properties, exact CSR/CSC
copies, prefix offsets and their capacity envelope. The inner row update closes
**71 checks**. All scopes are audited against the final owned source fragments
and unchanged external dependencies. `Build_Flat` retains **four open obligations**
(two prefix-preservation obligations, one index check and final `Valid_Flat`).
Constructor composition, full factorization/backsolve functional Gold and caller
Gold remain unfinished proof engineering; none is a Silver mathematical exception.
No assumption, suppression or new trusted body is introduced.
See [new scoped closure](evidence/20261008-flat-cholesky-r67/closure.json)
and [all proof attempts](evidence/20261008-flat-cholesky-r67/attempts.json).

The native probe emits actual flat metadata and decodes the numeric CSC slots,
so its comparison checks the new representation rather than reprinting the old
pattern. Its poisoned L initialization and bitwise factor/rank/solve comparisons
pass **395/395** against official C 3.15. The r65 and r66 integrated builds pass
**390/390**; r66 production 3.14 validation passes **366/366**. The final r67
receipts below record the retest after removing the duplicated offset scan.
Numerical tests do not close the constructor proof or establish universal C
compatibility.

The first quiet flat comparison, r66 against r45, resolves an elliptic median
improvement of **3.30% [1.75%, 4.22%]**, with current/C **3.252 [3.221, 3.304]**.
Free and mixed pyramidal medians regress by **3.12% [2.57%, 3.89%]** and
**3.48% [2.27%, 5.23%]** respectively; the other three intervals include one.
The free p95 ratio is **1.0277 [1.0101, 1.0628]**; the other five p95 intervals
include one. All states pass. This improvement on one workload is not aggregate
C parity or acceptance of the remaining regressions. Independent sessions are
not paired comparisons against r60. See [r66 raw timing](evidence/20261008-flat-cholesky-r67/paired-time-r66/results.json).

The final r67 native and release builds pass **395/395** and **390/390**
checks after removing the duplicated offset construction. The final production
3.14 regression also passes **366/366** (78 state, 54 forces, 234 constrained).
All **443** frozen
engine inputs match the final runtime source manifests. The constructor's
owned source is unchanged from the incomplete r66 proof receipt; the caller
and native probe reuse its offsets directly. These changes do not close the
four constructor obligations. The archived native inputs and outputs preserve
the actual flat-layout comparison, including the decoded CSC slot map.

The final quiet r67 comparison uses r45 and normal SIMD C, with 24 alternating
blocks of 16 measured 100-step trajectories, CPU 0 and state tolerance `2e-9`:

| Workload | Current/prior paired median [95% CI] | Current/C paired median [95% CI] |
| --- | --- | --- |
| membrane Newton | 1.0145 [1.0056, 1.0269] | 2.5347 [2.5042, 2.5612] |
| free | 1.0203 [1.0149, 1.0338] | 3.2787 [3.2332, 3.3228] |
| two-sphere contact | 1.0173 [1.0139, 1.0245] | 2.4419 [2.4262, 2.4731] |
| mixed pyramidal | 1.0388 [1.0186, 1.0480] | 2.6651 [2.6070, 2.7036] |
| elliptic crossing | 0.9680 [0.9600, 0.9724] | 3.2479 [3.2116, 3.2788] |
| self-collision | 1.0319 [1.0073, 1.0423] | 2.7809 [2.7215, 2.8470] |

All states pass. The elliptic median improves by **3.20% [2.76%, 4.00%]**;
the other five median intervals resolve regressions. Their sizes range from
**1.45%** (membrane) to **3.88%** (mixed pyramidal). The worst central current/C
ratio is **3.279 [3.233, 3.323]**, on the free workload. All six paired-block
p95-ratio intervals include one. This is not representative integrated parity
or acceptance of those regressions. The ratio of separately computed median
timings is not the paired median-ratio estimator, particularly on the
self-collision workload with substantial timing drift; raw paired observations
are retained. Separate r66/r67 sessions do not isolate the effect of removing
the duplicate offset scan.
The r67 evidence inventory verifies **4408 hashes**, preserving all 3580 prior
entries; [final regression receipts](evidence/20261008-flat-cholesky-r67/results.json)
record these scopes.
See [final paired timing](evidence/20261008-flat-cholesky-r67/paired-time-r67/results.json)
and [tail audit](evidence/20261008-flat-cholesky-r67/paired-time-r67/tail-audit.json).

## Flat constructor functional closure: r76

The four r67 `Build_Flat` obligations are now closed. The constructor proves
`Matches_Flat`: all used CSR columns and CSC rows match the symbolic input,
each cached numeric slot equals its CSR offset plus symbolic position, and the
result satisfies the full flat-layout integrity predicate. The r76 constructor
closes **87 checks** and its constructive validity composition closes **100**.
Pointwise copies, row separation, prefix preservation and cached-entry validity
are proved in smaller subprograms before composition. These are properties of
conversion from the given valid symbolic pattern; this does not prove the
symbolic algorithm's universal equivalence to C or the full numeric factorization.

Fresh r76 receipts close **1097 checks across 31 warning-free minimum scopes**.
Both offset models also prove that their predicate evaluation is safe: predecessor
bounds precede sums, using bounds already implied by their original row predicates.
The full validity model checks global bounds before reading row entries. The
valid input domain and all original layout/copy properties are retained.
See [scoped receipts](evidence/20261008-flat-constructor-r76/selected-owned-proofs.json)
and [source/dependency audit](evidence/20261008-flat-constructor-r76/dependencies.json).

This work exposed a real malformed-pattern validation defect. A two-row CSC
pattern can refer to position three in a later row whose invalid length is three;
the old validator indexed a two-column array before rejecting that later row.
The position check now uses the minimum of the row length and matrix dimension,
without adding a traversal. Valid patterns already satisfy that bound. A runtime
regression reproduces the old index-check exception and verifies rejection after
the fix. The validator's **34 owned safety checks** close; GNAT's pre-existing
`imprecise-call` warning on `Sqrt` at body line 363 lies outside this ADS function
and remains preserved. The strict driver therefore retains `passed=false` for
that warning-bearing receipt; it is not counted among the 31 warning-free scopes.
See [validator receipt and limitation](evidence/20261008-flat-constructor-r76/validator-totality.json).

The final native probe passes **395/395** bitwise C 3.15 comparisons, including
its new malformed-CSC self-check. The r76 integrated 3.15 release corpus passes
**390/390** (78 state, 66 forces, 246 constrained). All **443** frozen engine
inputs match the final native/runtime manifests. The final production 3.14 regression passes **366/366** (78, 54, 234).
The [follow-up receipts](evidence/20261008-flat-constructor-r76/followup/results.json)
preserve both corpora and the expected before-fix exception.
These results do not establish whole dynamics Gold or representative C parity.

The evidence inventory verifies **5102 hashes**, preserving all 4408 prior
entries. The complete port, direct flat symbolic construction, actual-NNZ
allocation, compact H assembly and packed rank updates remain unfinished.
Full numeric factor/backsolve functional Gold and their caller proofs remain open.

The final r76 quiet run compares **r76 directly with r67** and normal SIMD C,
24 alternating blocks × 16 measured 100-step trajectories, one warm-up and CPU 0.
All states match. Paired median block-mean ratios (95% bootstrap intervals) are:

| Workload | r76/r67 | r76/C |
|---|---:|---:|
| membrane_Newton_3 | 0.9959 [0.9771, 1.0054] | 2.483 [2.448, 2.504] |
| free | 1.0044 [0.9872, 1.0275] | 3.195 [3.151, 3.260] |
| element_2_sphere | 0.9897 [0.9774, 1.0065] | 2.391 [2.354, 2.417] |
| element_mixed_pyramidal_3 | 1.0011 [0.9913, 1.0101] | 2.663 [2.576, 2.704] |
| element_elastic_cross_elliptic_6 | 0.9904 [0.9762, 0.9974] | 3.227 [3.196, 3.268] |
| element_elastic_self_bvh_pyramidal_3 | 0.9995 [0.9749, 1.0155] | 2.759 [2.696, 2.852] |

Five central r76/r67 intervals include one; the elliptic ratio resolves a
**0.96% [0.26%, 2.38%]** median improvement. This run does not resolve a central
regression. The complete-block paired p95 audit resolves sphere and self-contact
reductions of **19.79% [5.15%, 22.73%]** and **5.21% [1.45%, 8.97%]**; the other
four tail intervals include one. These are workload-specific observations rather
than a claim that the validator alone caused the tail changes. Current/C remains
**2.39–3.23**, with elliptic worst at **3.227 [3.196, 3.268]**; aggregate parity
remains unachieved. Comparisons between separate benchmark sessions do not isolate
an optimization effect. [Raw paired timing](evidence/20261008-flat-constructor-r76/paired-time/results.json)
and [tail audit](evidence/20261008-flat-constructor-r76/paired-time/tail-audit.json)
retain every model, input, trajectory, source manifest and compiler setting.

## Direct symbolic construction and actual-NNZ storage: r83

The solver now follows C's two-phase `mju_cholFactorSymbolic`: count CSR/CSC
entries with the reverse elimination tree, then write the flat columns, CSC rows
and numeric-slot map directly. CSC traversal order is preserved, including
unsorted rows. The normal factor/solve path no longer builds the three dense
symbolic index tables or converts them into a flat layout. The numeric factor
and flat metadata allocate exactly the counted entries, rather than triangular
capacity. Dense H and the input support mask remain; this is not compact H
assembly or removal of all quadratic workspace. The legacy pattern is rebuilt
only inside incremental rank updates, whose numeric factor still uses a dense
bridge. The unused sparse-Newton workspace on other solver branches is only N
numeric slots.

The final frozen engine has **443 inputs**, identical to the core inputs of the
final native and integrated 3.15 builds. Native testing passes **407/407** exact
C 3.15 comparisons of symbolic order/maps, factors, ranks and normal SIMD
solves, plus the separate malformed-CSC startup regression. Twelve added cases
cover upper-only masks, ignored lower-only support and absent input diagonals.
An independent clique-elimination model also matches C's support and both count
vectors in all 407 cases. These are finite checks, not a universal equivalence
proof. The integrated 3.15 release corpus passes **390/390**, and production
3.14 regression passes **366/366**: **1163 comparisons** in total.

Four final warning-free minimum scopes close **137 checks**: row ordering (18),
column separation (21), exact row packing with frame properties (68), and full
numeric packing (30). Exact numeric expansion closes **64 checks** with one
preserved `multidimensional-array-init` warning; its strict receipt retains
`passed=false`. The r81 constructor (87), validity composition (100) and validity
predicate (13) also close; their definitions and the flat-layout model are
unchanged in the final source. The extra directly exposed CSR bounds/order are
already clauses of the row-validity predicate. The auxiliary universal proof of
that predicate equivalence remains unfinished and is not counted as closed.

Global symbolic Gold remains open: the count traversal proves 76 checks but its
full success/valid-plan/model postcondition is unproved. Filling proves 147
checks with the complete postcondition and a model-call precondition still open.
Mass-row addition (51 proved checks), mass composition (41), its progress lemma
(111), and the legacy adapter (125, r81) retain open obligations. Full functional
numeric factor/backsolve and caller/dynamics Gold remain unfinished. These are
proof-engineering gaps, not mathematical Silver exceptions. Conservative link
bounds and the final O(N) count/write consistency checks remain in the new
symbolic traversal until its global contracts close.

The final quiet benchmark compares **r83 directly with r76** and normal SIMD C:
24 alternating blocks, 16 measured trajectories of 100 steps each, one warm-up,
CPU 0. Every final state passes. Paired median block-mean ratios and 95%
bootstrap intervals are:

| Workload | r83/r76 | r83/C |
|---|---:|---:|
| membrane_Newton_3 | 0.9702 [0.9631, 0.9941] | 2.473 [2.429, 2.499] |
| free | 0.9671 [0.9527, 0.9860] | 3.182 [3.143, 3.232] |
| element_2_sphere | 0.9792 [0.9668, 0.9886] | 2.393 [2.371, 2.410] |
| element_mixed_pyramidal_3 | 1.0288 [0.9901, 1.0408] | 2.657 [2.585, 2.741] |
| element_elastic_cross_elliptic_6 | 0.9894 [0.9734, 0.9944] | 3.204 [3.142, 3.234] |
| element_elastic_self_bvh_pyramidal_3 | 0.9408 [0.9221, 0.9510] | 2.682 [2.642, 2.731] |

Five scenes resolve median reductions of **1.06–5.92%**; the mixed scene's
**+2.88%** interval includes one, so its central regression is unresolved. The
paired complete-block p95 bootstrap resolves membrane/self-contact reductions
of **18.53% [0.30%, 26.26%]** and **11.10% [4.44%, 21.85%]**, but also a mixed
scene regression of **8.32% [0.09%, 22.64%]**. Free, sphere and elliptic tail
intervals include one. This tail regression is retained as a follow-up target;
there is no aggregate acceptance or C-parity claim. Current/C remains
**2.39–3.20**, worst on the elliptic scene. Differences between separate timing
sessions do not isolate an optimization effect.

[Final evidence](evidence/20261008-direct-symbolic-r83/results.json),
[all proof attempts](evidence/20261008-direct-symbolic-r83/attempts.json),
[paired timing](evidence/20261008-direct-symbolic-r83/paired-time/results.json)
and [tail audit](evidence/20261008-direct-symbolic-r83/paired-time/tail-audit.json)
preserve the final source archive, earlier negative attempts, exact runners,
models, inputs, outputs and compiler/reference receipts. No complete-port,
production 3.15 migration or whole-dynamics proof is established by this work.

## Flat mass addition: minimum functional proofs and C regression, r90

Mass addition now uses an inlined one-cell numerical operation, with separate
Ghost contracts for prefix advancement, row composition and conversion to the
public full-matrix model. These preserve the ordered floating-point addition,
ensure a cell is updated at most once and preserve every unvisited cell. Ghost
snapshots and proof traversals add no release scans. The input domain remains
square matrices with entries in ±1e100 on a valid flat factor pattern. Splitting
range/frame quantifiers and using 1..F.N under the existing square/size
preconditions does not weaken the public contract or exclude inputs.

Eleven unchanged final minimum declarations/bodies have warning-free closed
receipts: **486 checks**. The newly closed minimum scopes in this continuation
are Mass_Result_Point (44), Mass_Progress_Row (63), Flat_Mass_Progress (63) and
Mass_Result_Row (55): **225 checks**. The remaining closed scopes cover selected
prefix membership (10), its ordered step (13), scalar composition (6), the
actual cell write and frame (28), prefix point (64), prefix composition (78)
and full-row point (62). Exact declaration/body continuity is recorded against
the final frozen source; predicates and supporting contracts retain their
meaning. Individual scopes prove their contracts under called contracts, not
whole solver or dynamics Gold.

The complete mass routine is **not yet Gold**. At the normal three-second
prover limit its numerical row retains three functional obligations, the
public-model conversion retains two, and the complete public routine retains
one. Increasing to ten seconds does not close the conversion; numerical-row
and complete-routine attempts hit the 240-second guard and have no complete
proof report. They remain failed attempts. A proof-only Inline_For_Proof
experiment on the membership predicate improved one scope and worsened callers;
it was reverted. These are unfinished proof-engineering tasks, not Silver
exceptions for mathematical limitations. No assumptions, trusted bodies or
suppression were added.

The new native differential suite calls actual C 3.15
`mju_cholFactorSymbolic` and `mju_addToMatSparse`. It checks **180/180** cases:
nine sizes (1..128), five support families, and ordinary, ±1e100, signed-zero
and tiny values. It compares the entire dense result bitwise, including cells
outside the factor support and their signed zero. Both sparse operands have
the same fixed CSR support; this does not test general sparse unions or compact
H assembly. Formal floating-point equality is distinct from signed-zero bitwise
equivalence; the latter is finite test evidence here.

All **443 frozen core inputs** match the final native and integrated 3.15
builds. Sparse symbolic/factor/SIMD-solve regression passes **407/407** plus its
separate malformed-CSC startup check. Integrated 3.15 passes **390/390**
(78 state, 66 force, 246 constrained trajectories), and unchanged-production
3.14 passes **366/366** (78, 54, 234). Total: **1343 comparisons**. Earlier
inlining-experiment builds also passed; the final evidence uses fresh builds of
the restored source, not those binaries.

A fresh quiet paired benchmark compares **r90 with r83 and normal SIMD C**:
24 alternating blocks, 16 measured 100-step trajectories per block, one warm-up,
CPU 0. All final states pass. Median block-mean ratios with 95% bootstrap
intervals are:

| Workload | r90/r83 | r90/C |
|---|---:|---:|
| membrane_Newton_3 | 1.0031 [0.9708, 1.0385] | 2.554 [2.490, 2.728] |
| free | 1.0024 [0.9865, 1.0170] | 3.167 [3.066, 3.220] |
| element_2_sphere | 1.0054 [0.9911, 1.0148] | 2.419 [2.397, 2.445] |
| element_mixed_pyramidal_3 | 1.0037 [0.9983, 1.0302] | 2.811 [2.743, 2.844] |
| element_elastic_cross_elliptic_6 | 0.9958 [0.9821, 1.0052] | 3.174 [3.136, 3.202] |
| element_elastic_self_bvh_pyramidal_3 | 0.9954 [0.9791, 1.0096] | 2.657 [2.599, 2.705] |

No median or p95 change resolves against r83 in this run. Mixed p95 is centrally
**+6.21%**, with interval **[-2.58%, +14.56%]**. The previous resolved r83/r76
mixed tail regression remains documented; this new r90/r83 comparison does not
establish its removal. There is no C-parity or aggregate performance acceptance:
r90 still takes **2.42–3.17 times C's time** on these six supported scenes.
Changes between separate timing sessions cannot be attributed to optimization.

[Evidence and scope](evidence/20261008-mass-addition-r90/results.json),
[all proof attempts](evidence/20261008-mass-addition-r90/attempts.json),
[declaration continuity](evidence/20261008-mass-addition-r90/proof-continuity.json),
[paired timing](evidence/20261008-mass-addition-r90/paired-time/results.json)
and [tail audit](evidence/20261008-mass-addition-r90/paired-time/tail-audit.json)
preserve exact sources, runners, failed attempts and numerical inputs/outputs.
The complete port, production 3.15 migration, symbolic/numeric solver Gold and
whole-dynamics proof remain unfinished.

## Gold closure of flat mass addition: r96

The complete flat mass-addition kernel now closes its exact floating-point
sum, bounded-output and unvisited-cell frame contracts on a valid flat factor
pattern. **All 13 mass-path minimum scopes are freshly proved on the same
final source: 576 checks, no open obligations or warnings.** This supersedes
the six open mass obligations recorded at r90. It does not close symbolic
construction, factor/backsolve functionality, solver callers or whole dynamics.

The numerical row writes one cell using the proved inlined scalar `Mass_Sum`;
its expression is exactly A+B. A whole-matrix in/out helper obscured the frame
at the caller and is no longer needed. Ghost snapshots inherit the source
array bounds, making their relation to the original matrix explicit. The complete routine
separately carries the bounded-output and functional assertions.

`Row_Selected` is now a public Ghost expression function with the same exact
membership definition and proved postcondition: existence of a column in the
specified CSR prefix. The public mass contract uses that predicate directly.
Its input domain and requested output relation are unchanged: every supported
cell equals old H+M, all others equal old H, and outputs remain within ±2e100
for inputs within ±1e100. This is a specification abstraction, not a weaker
condition or a claim of universal C bitwise equivalence. The redundant
conversion lemmas and old numerical matrix helper were removed. Proof-only
loops and snapshots add no release scans; release Ada runtime checks remain.
No assumptions, suppressions or new trusted bodies were introduced.

| Fresh minimum scope | Closed checks |
|---|---:|
| Row_Selected | 10 |
| Mass_Sum | 5 |
| Mass_Value_Progress | 6 |
| Flat_Row_Ordered | 18 |
| Flat_Column_Separate | 21 |
| Selected_Step | 13 |
| Mass_Prefix_Point | 64 |
| Mass_Prefix_Progress | 78 |
| Add_Mass_Flat_Row | 103 |
| Mass_Row_Point | 62 |
| Mass_Progress_Row | 63 |
| Flat_Mass_Progress | 63 |
| Add_Mass_Flat | 70 |
| **Total** | **576** |

The frozen engine's **443 core inputs** match the final native and integrated
3.15 build inputs. Native fixed-support mass tests pass **180/180 bitwise**,
including signed zero and the entire unvisited matrix frame; sparse
symbolic/factor/normal-SIMD-solve tests pass **407/407** plus the separate
malformed-CSC startup check. Integrated 3.15 passes **390/390** and production
3.14 regression passes **366/366**. Total: **1343 numerical comparisons**.
Their support/coverage limitations documented at r90 still apply; no general
sparse-union, complete-port or production-3.15 migration claim is implied.

A new quiet paired benchmark compares **r96 against r90 and normal SIMD C**:
24 alternating blocks, 16 measured trajectories of 100 steps, one warm-up,
CPU 0. Every final state passes. Paired median block-mean ratios and 95%
bootstrap intervals are:

| Workload | r96/r90 | r96/C |
|---|---:|---:|
| membrane_Newton_3 | 1.0022 [0.9954, 1.0309] | 2.479 [2.419, 2.533] |
| free | 1.0039 [0.9981, 1.0343] | 3.171 [3.149, 3.203] |
| element_2_sphere | 1.0041 [0.9898, 1.0102] | 2.413 [2.395, 2.433] |
| element_mixed_pyramidal_3 | 1.0062 [0.9908, 1.0094] | 2.799 [2.779, 2.843] |
| element_elastic_cross_elliptic_6 | 1.0094 [0.9972, 1.0308] | 3.171 [3.081, 3.217] |
| element_elastic_self_bvh_pyramidal_3 | 1.0055 [0.9931, 1.0281] | 2.699 [2.653, 2.727] |

No median or p95 change resolves against r90. Mixed p95 is centrally **-4.11%**
with interval **[-15.58%, +4.33%]**; this does not establish removal of the old
r83/r76 mixed tail regression. Current/C is still **2.41–3.17**, so performance
parity and aggregate acceptance remain unmet. Separate timing sessions do not
isolate an optimization effect. The next structural bottleneck remains dense
H assembly: C constructs J'DJ directly in sparse rows, adds sparse mass and
then fills the numeric factor; our caller still assembles a dense matrix.

[Closure and scope](evidence/20261008-mass-gold-r96/results.json),
[complete mass-path proof closure](evidence/20261008-mass-gold-r96/proof-closure.json),
[all proof attempts](evidence/20261008-mass-gold-r96/attempts.json),
[paired timing](evidence/20261008-mass-gold-r96/paired-time/results.json)
and [tail audit](evidence/20261008-mass-gold-r96/paired-time/tail-audit.json)
preserve the final sources, exact runners, failed intermediate attempts and
numerical inputs/outputs. Earlier indexed evidence remains unchanged.

## Direct compact numerical Hessian, r102 (2026-10-08)

Sparse Newton now assembles numeric Hessian entries directly into flat factor
support and passes that vector to `Factor_Values`. Its dense H allocation is
empty. This covers both scalar rows and folded elliptic/quadratic blocks;
dense Newton keeps its original matrix path. Incremental rank updates still
materialize the legacy dense factor bridge. Symbolic masks, the assembled M/J
interface, coalesced Jacobian support and general sparse-union semantics remain
separate work. This is an experimental structural candidate, **not an accepted
performance improvement**.

The mass vector path has fresh Gold closure: exact loads and floating-point
additions, bounds and preservation of all other slots. Its nine scopes total
**394 checks**. The single compact Gram write adds **13**, and its `Gram_Scaled`
dependency adds **7**: **414 checks in 11 warning-free minima**, on one immutable
443-input engine. These proofs retain valid-flat-pattern/finite-domain and SPARK
aliasing assumptions. They introduce no assumptions, trusted bodies, suppressed
checks, or narrower public input domains.

Global `Gram_Row_Flat` still has one functional postcondition open. Numeric
`Factor_Values` has seven open obligations: transpose-slot/index bounds, ordered
prefix and residual preconditions, preservation/initialization of bounds and the
positive diagonal postcondition. Its current contracts do not yet specify the
complete ordered factor algorithm. These are pending proof engineering, not
mathematical Silver exceptions. Whole solver/caller and dynamics Gold remain
open. The stronger helper results must not be promoted to those wider claims.

Final native comparisons pass **700/700** compact Gram cases (including partial
numeric rejection, zero scales, signed zero, subnormals and untouched cells),
**180/180** compact mass cases and **407/407** compact factor/normal-SIMD-solve
cases. Of the Gram cases, **434** compare bitwise with actual C; the remaining
266 use the ordered scalar model for nonzero initial matrices/rejection. Mass
uses identical fixed CSR support in both operands, not general sparse union.
Integrated C 3.15 passes **390/390** (78 state, 66 forces, 246 constrained
100-step trajectories), and production C 3.14 passes **366/366**. Total:
**2,043 numerical comparisons**, of which 1,777 use actual C. The 443 core inputs
match final native and 3.15 integrated build inputs. Production migration to
3.15 remains unapplied.

A quiet paired release comparison uses r96 as baseline and normal SIMD C 3.15:
24 alternating blocks × 16 measured 100-step trajectories, one warm-up per
block, CPU 0. All final states pass. Ada retains runtime checks with
`-O3 -gnatn -march=native -ffp-contract=off`.

| Workload | r102/r96, paired median [95% CI] | r102/C [95% CI] |
|---|---:|---:|
| membrane_Newton_3 | 1.0010 [0.9719, 1.0145] | 2.533 [2.485, 2.578] |
| free | 1.0024 [0.9660, 1.0251] | 3.240 [3.194, 3.328] |
| element_2_sphere | 1.0068 [0.9898, 1.0221] | 2.462 [2.373, 2.591] |
| element_mixed_pyramidal_3 | 1.0205 [0.9800, 1.0519] | 2.767 [2.703, 2.878] |
| element_elastic_cross_elliptic_6 | 1.1827 [1.1653, 1.1997] | 3.759 [3.668, 3.846] |
| element_elastic_self_bvh_pyramidal_3 | 1.0740 [1.0519, 1.0921] | 2.925 [2.873, 2.958] |

**The elliptic +18.27% and self-contact +7.40% median regressions resolve.**
Elliptic p95 also regresses **+23.16% [11.56%, 31.00%]** in the paired-block
bootstrap; other p95 intervals include parity. This measurement does not remove
the historical r83/r76 tail regression. C parity and aggregate acceptance are
unmet; the new sparse storage alone is insufficient.

The source comparison identifies the next structural change, without claiming
measured attribution: `Gram_Row_Flat` searches/merges the factor row for every
outer-product contribution. C `mju_sqrMatTDSparseNumeric` instead visits the
transposed Jacobian for one result row, accumulates all contributions in an N
scratch buffer, and scatters that row once. Port that complete row traversal,
including folded cone values, stable source-slot order and cached transpose
mapping; do not substitute a dense Hessian or an N×K scan.

[Results and scope](evidence/20261008-direct-hessian-r102/results.json),
[minimum closure](evidence/20261008-direct-hessian-r102/minimum-closure.json),
[all attempts](evidence/20261008-direct-hessian-r102/attempts.json),
[paired timing](evidence/20261008-direct-hessian-r102/paired-time/results.json)
and [tail audit](evidence/20261008-direct-hessian-r102/paired-time/tail-audit.json)
preserve the successful and failed attempts, final source, native/integrated
inputs and outputs, and the resolved negative performance result. Earlier
indexed evidence remains unchanged. The full port goal remains active.

## Row-buffer numerical Hessian, r109 (2026-10-08)

Sparse Newton now follows the **single-row** path of C 3.15's
`mju_sqrMatTDSparseNumeric`: traverse a stable transpose of the constraint
Jacobian, accumulate directly into a dense row buffer, scatter once into flat
factor support, and reset the selected columns. The transpose caches integer
source slots; folded elliptic values change without rebuilding that map. The
parent solver no longer calls `Gram_Row_Flat`. Sparse H remains a numeric
vector, and the existing compact mass load/add path is retained.

This implements `ns=1`; C supernode batching remains pending. The parent still
uses coalesced J support and union support for each folded cone, rather than
native CSR slots throughout. Its symbolic masks and M/J interface remain dense,
and incremental rank updates retain the legacy dense factor bridge. No public
input domain has been narrowed. This remains an experimental candidate,
**not an accepted performance improvement or C parity**.

Twelve warning-free minima on immutable r108 close **228 checks**, including
exact rounded single updates, scatter/copy/reset and frame properties, column
uniqueness and selection progression. `Before`, `Term_Value` and `Row_Value`
prove only the bounds of the ghost models; their range contracts are not full
functional Gold. The remaining minima prove their stated functional properties
under their explicit dependencies. No assumptions, suppression or trusted
bodies were introduced. The runner now selects `Hessian_Scatter_Row` separately
from the sparse factor's identically named procedure.

The r109 source changes only the local constant used to declare the transpose
cursor; all twelve proved routines and their contracts are unchanged. The
228-check receipts are explicitly r108 evidence, not a fresh r109 whole-unit
proof. The r109 transpose constructor leaves **five obligations open**: count,
prefix and cursor upper bounds, an output index, and its functional
postcondition. The global Gram proof reaches the 240-second guard, with no
accepted complete scoped report. Its ordered functional postcondition remains
intact. Global Gram/transpose, numeric factor, callers, solver and dynamics Gold
remain pending proof engineering, not mathematical Silver exceptions.

Final r109 native tests pass **237/237** full multirow Gram cases, including
empty rows, sorted duplicate columns, zeros, subnormals and numeric boundaries.
**233** compare bitwise with actual C's single-row accumulation; four rejected
cases use the ordered partial-output model because C has no equivalent bound
rejection. All **237** stable transpose maps compare with actual C. Compact mass
passes **180/180** on identical fixed CSR support, and factor/normal-SIMD-solve
passes **407/407**. Integrated C 3.15 passes **390/390** (78 state, 66 forces,
246 constrained trajectories); production C 3.14 passes **366/366**.
Total: **1,580 numerical cases**, including 1,576 actual-C numeric comparisons;
the 237 transpose comparisons are separate checks of the same Gram cases.
All 445 final core inputs match the native and 3.15 integrated build inputs.
Production migration to 3.15 is still unapplied.

Two separate quiet sessions compare r109 with pre-Hessian r96 and with r102,
respectively. Each uses CPU 0, 24 alternating blocks, 16 trajectories per block,
100 full steps, one warm-up per block, checked final states and normal C 3.15
SIMD. Provers/builds/tests finish before either session; preflight excludes
observed concurrent heavy jobs. Ada keeps runtime checks with
`-O3 -gnatn -march=native -ffp-contract=off`. Ratios below are the median paired
block-mean ratios with 95% bootstrap intervals, not ratios of separate medians.

| Full movement | r109/r96 [95%] | r109/r102 [95%] | r109/C in r96 session [95%] |
|---|---:|---:|---:|
| membrane_Newton_3 | 1.0175 [0.9968, 1.0450] | 0.9992 [0.9689, 1.0183] | 2.5773 [2.4862, 2.6653] |
| free | 1.0093 [0.9907, 1.0592] | 1.0186 [0.9994, 1.0403] | 3.3306 [3.1401, 3.4089] |
| element_2_sphere | 1.0052 [0.9863, 1.0234] | 1.0185 [0.9368, 1.0788] | 2.4615 [2.4211, 2.5359] |
| element_mixed_pyramidal_3 | 1.0041 [0.9630, 1.0429] | 1.0155 [0.9663, 1.0565] | 2.8272 [2.6615, 2.8967] |
| element_elastic_cross_elliptic_6 | 1.1305 [1.0802, 1.1689] | 0.9376 [0.9134, 0.9709] | 3.6193 [3.4862, 3.6988] |
| element_elastic_self_bvh_pyramidal_3 | 1.0572 [1.0219, 1.1092] | 0.9389 [0.9078, 0.9724] | 2.8643 [2.7398, 2.9366] |

The two critical workloads improve against r102 by **6.24% and 6.11%**, both
resolved by their intervals. They remain slower than r96 by **13.05% and
5.72%**, also resolved. Other central changes are unresolved. All paired p95
tail intervals include parity in both sessions; central results do not establish
tail improvement. C parity and aggregate acceptance remain unmet; an unweighted
average of these cases would not establish either. Direct native support,
avoiding repeated setup and C batching remain the next structural targets.

[Complete compressed evidence](evidence/20261008-row-buffer-hessian-r109/complete.zip)
contains all exact stage sources, runners, reports and raw cases. Its member
hashes are recorded in the
[archive manifest](evidence/20261008-row-buffer-hessian-r109/archive-manifest.json).
The incomplete unindexed Windows copy was replaced only after the reconstructed
Linux archive passed its checks. Earlier evidence was preserved.

[Receipts and scope](evidence/20261008-row-buffer-hessian-r109/results.json),
[minimum closure](evidence/20261008-row-buffer-hessian-r109/minimum-closure.json),
[all proof attempts](evidence/20261008-row-buffer-hessian-r109/attempts.json),
[paired r96 timing](evidence/20261008-row-buffer-hessian-r109/paired-time-vs-r96/results.json)
and [paired r102 timing](evidence/20261008-row-buffer-hessian-r109/paired-time-vs-r102/results.json)
preserve final sources, exact runners, compiler failures, warning-bearing
attempts, proof timeouts and raw numerical/timing inputs and outputs. Earlier
indexed evidence remains unchanged.

## SO3 world site quaternion composition, r110 (2026-10-09)

C 3.15 composes both site and reference-site world quaternions as `body * local`.
The production 3.14 adapter preserves that version's `local * body` order.
The new version-specific overlay changes the two quaternion products in the
owned SO3 transmission, keeping its Jacobians and moment frames unchanged.

The checked 3.15 build passes **34/34 trajectories** across 17 SO3 models.
Twelve trajectories are new: shared ancestors and separate body trees, each
with quaternion, expmap and velocity controls. Their initial body/local rotations
do not commute. An independent check against actual C confirms each fixture
detects reversing the site product alone, the reference product alone, or both
(initial length errors 0.33–0.95 radians). The unchanged production 3.14 path
passes **22/22 trajectories** across its eleven existing SO3 models. Each model
has one 100-step trajectory and one single-step trajectory, with applied loads.
Both builds retain runtime checks; all frozen source hashes remain unchanged.

These results cover the owned SO3 path. Ordinary scalar-site transmission still
has only a lower-level kernel accepting caller-provided world poses; its engine
integration remains incomplete. No complete transmission/caller Gold, full
3.15 production adoption or performance claim follows from these comparisons.
The [receipts](evidence/20261009-site-world-quaternion-r110/results.json) and
[complete archive](evidence/20261009-site-world-quaternion-r110/complete.zip)
retain both source closures, commands, warnings, raw MJB/input/output files and
the three independent order checks. All 585 ZIP members were hash-verified;
the [archive manifest](evidence/20261009-site-world-quaternion-r110/archive-manifest.json)
records their hashes.

Reproduce the narrow checked comparison:

```sh
/var/tmp/sparkling-movement315-env/bin/python experimental/alignment-3.15/tests/build_advanced.py \
  --foundation /var/tmp/sparkling-alignment-315-foundation-r6-20261007 \
  --out /var/tmp/sparkling-advanced-315-new \
  --python /var/tmp/sparkling-movement315-env/bin/python --only so3_ --samples 2 --steps 100
```

For production regression, pass the verified 3.14 foundation and Python wheel
with `--production-regression`, using a fresh output directory.

## Cached Hessian rows and transpose minima, r120 (2026-10-09)

`Scatter_Row` retains its slot and column across the copy/reset operations;
`Factor_Values` retains row bounds and transpose offsets. Floating-point order,
pivot clamping, rejection checks and public input domains are unchanged. The
native code shrinks from 1,879 to 1,729 bytes for `Build_Gram` and from 3,466 to
3,271 bytes for `Factor_Values`. The codegen audit still finds per-element
`F.N`/column-base reloads after writes to `L`; the column renaming did not remove
them. Smaller code alone is not performance evidence.

The transpose proof now uses an iterative ghost prefix model, partition/frame
lemmas and private count/offset helpers. **13 minimum scopes close 284 checks
without warnings**, including 67 for the updated scatter. Twelve unchanged
scopes use r114 evidence; the changed offset helper closes 24 checks on r115,
whose engine manifest exactly matches r120. Both complete `Build_Transpose`
attempts reach the 240-second watchdog without a complete scoped report.
`Factor_Values` closes 46 checks with **8 still open and 2 warnings** at the
recorded effort. Global `Build_Gram`, transpose, factor and caller proofs remain
unfinished. Partially initialized caller patterns need their own flow proof;
the public procedure's initialized-record proof boundary does not establish it.
No assumptions, suppressions or narrower public preconditions were added.

Fresh final-source checks pass **824 native cases** (237 Gram, 180 fixed-support
mass, 407 factor/SIMD solve), **390 integrated C 3.15 cases** and **366 production
C 3.14 cases**. Total: **1,580 numerical cases**, including 1,576 actual-C numeric
comparisons and four ordered partial-result rejection checks. Transpose checks
reuse the 237 Gram cases and are not additional cases. The separate SO3 results
above cover a different adapter. Production remains pinned to 3.14.

The earlier r111 instrumented profile now selects corpus sample 1, matching the
release workload: factorization accounts for 24.68% of samples and Gram for
16.82%; symbolic setup accounts for 6.28%. Sized ELF symbols correct ambiguous
raw gprof labels. There are 778,000 Gram/factor calls across 204,000 solves,
including preparatory calls; this is full-process attribution, not release
timing or an exact timed-step ratio. Independent interception of the unchanged
C 3.15 wheel observes exactly **one full Gram and one full factorization per
step**, in every measured step of all six models, with bitwise-equal states and
identical solver statistics. All seven source call sites map to intercepted
PLT sites. Private rank-update routines are not counted by this experiment.
This supports investigating Hessian/factor reuse and incremental updates; it
does not predict a 3.8-fold speedup. A separate recompiled-C counter experiment
is archived as prepared only, not executed evidence.

The quiet release comparison uses CPU 0, 24 alternating blocks, 16 trajectories
per block, 100 full steps and one excluded warm-up trajectory per block. All
states pass against normal C 3.15 SIMD. Runtime checks and the previous release
flags remain enabled. The table reports **ratios of arithmetic means**, with
pointwise 95% paired block-bootstrap intervals (5,000 resamples); this differs
from the median-of-paired-ratios estimator in the preceding r109 table.

| Full movement | Mean duration change r120/r109 [95%] | Mean r120/C |
|---|---:|---:|
| membrane_Newton_3 | -0.04% [-5.33%, +6.12%] | 2.587 |
| free | +2.86% [-1.90%, +7.93%] | 3.398 |
| element_2_sphere | -5.91% [-10.34%, -1.79%] | 2.469 |
| element_mixed_pyramidal_3 | -1.23% [-5.20%, +3.00%] | 2.796 |
| element_elastic_cross_elliptic_6 | -4.36% [-7.86%, -0.41%] | 3.408 |
| element_elastic_self_bvh_pyramidal_3 | -0.76% [-3.38%, +1.72%] | 2.831 |

The two favorable mean estimates are method-specific signals: **all six
median-of-paired-ratios intervals still include parity**. Only sphere's p95
trajectory tail resolves an improvement (-9.84%, interval -18.11% to -5.73%).
Self-BVH's p95 estimate is +12.10%, with interval -4.14% to +20.52%; it does not
establish either regression or equivalence. No multiplicity correction is
applied. Own jobs were idle and observed WSL processes stayed quiet; this does
not exclude all native Windows background activity. No new r96 comparison was
run. C parity, aggregate acceptance and attribution to individual edits remain
open.

[Receipts and scope](evidence/20261009-cached-rows-r120/results.json),
[proof closure](evidence/20261009-cached-rows-r120/proof-summary.json),
[timing summary](evidence/20261009-cached-rows-r120/timing-summary.json), and
the verified archives for
[runtime](evidence/20261009-cached-rows-r120/runtime.zip),
[diagnostics](evidence/20261009-cached-rows-r120/diagnostics.zip),
[proof attempts](evidence/20261009-cached-rows-r120/proofs.zip), and
[timing](evidence/20261009-cached-rows-r120/timing.zip)
retain exact source closures, commands, reports, inputs/outputs, instrumented
binary/profile data, failed attempts and the statistical analysis scripts.
Build objects and proof caches are excluded; prior indexed evidence is preserved.

## Persistent quadratic factor and compact updates, 2026-10-09

The sparse Newton candidate now keeps the quadratic base factor across solver
iterations and updates changed rows directly in its compact representation.
It no longer expands that factor into an N-by-N matrix for rank updates.
Elliptic curvature is refreshed separately on every relevant iteration, including
when a cone keeps its state but changes direction. The choice between cone
updates and folded assembly follows C 3.15's operation-count test and is cached
until its inputs change. A bounded incremental failure falls back to full
assembly; the public input domain was not narrowed. Newton also stops copying
the previous gradients used only by CG. Dense mixed/elliptic factor reuse and
the composed cache/factor-history proof remain pending.

Fresh r122 validation retains runtime checks and passes:

| Scope | Result |
|---|---:|
| Integrated C 3.15 state / forces / constrained trajectories | 78 / 66 / 246 |
| Production C 3.14 state / forces / constrained trajectories | 78 / 54 / 234 |
| Assembled solver, each C version, dense / sparse | 428 / 432 |
| Solver robustness: stress / replay / capacity | 240 / 240 / 5 |
| Independent one-coordinate cone oracle | 18 / 18 |

The independent oracle covers both predicted sides of C's fold/update cost
threshold. It checks the convex optimum, not an instrumented branch count or
universal equivalence. Frozen sources, commands, inputs/outputs and binary hashes
are retained in the [runtime archive](evidence/20261009-hessian-reuse-r122/runtime.zip)
and [runtime stages](evidence/20261009-hessian-reuse-r122/runtime-stages.json).

The previously prepared recompiled-C counter experiment has now run. All twelve
runs (six models, with zero or two preparatory forwards) preserve the unchanged
wheel's states bitwise and its solver statistics. Every measured step performs
one full Gram assembly and one full factorization. In the elliptic fixture, C
averages 29.46 cone rank updates and 7.68 quadratic downdates per step, with no
folded rebuilds; the mixed pyramidal fixture averages 4.27 quadratic updates and
7.64 downdates. These are exact invocation counts, not execution-time shares or
a predicted speedup. The [counter archive](evidence/20261009-hessian-reuse-r122/c-counters.zip)
includes the pinned-source instrumentation and its checks. At the 2026-10-09 publication, final r122 Ada call
counts and quiet release timings had not been run; see the 2026-10-24 timing
section below for the new measurement. The r120 timing table above
remains historical and cannot establish acceptance of these changes.

The rank-update probe passes **593 cases**: 588 bitwise comparisons with actual
C 3.15 finite outputs and five guarded rejection checks, including 198 direct
packed cases. That frozen native run precedes the final ghost-only refinement;
the final r122 source also compiles and passes the integrated and assembled
solver suites above. The r121 minimum proofs close 24 row-boundary and 16
selection-frame checks, while retaining the existing imprecise-Sqrt warnings.
Their strict warning-free result remains false. The first `Flat_Row` attempt
has two open obligations; `Update_Flat` hits its 240-second watchdog without a
complete scoped report. The final ghost refinement and new separation lemma
have not been reproved. They remain engineering work, not a Silver exception
or a global Gold claim. The [packed-update evidence](evidence/20261009-hessian-reuse-r122/packed-updates.zip)
retains the native run, successful minima and failed proof attempts.

## Scalar site transmissions in the 3.15 candidate, 2026-10-09

The optional scalar-site overlay now connects ordinary site/refsite transmissions
to the shared smooth/constrained controller. It reconstructs world poses,
translates the body-COM Jacobians to the site points, handles welded ancestors,
and applies C's servo/PID rotational wrapping rules. The world-reference guard
matches C; its initially failing regression is preserved in the evidence.
Mixed translation/rotation gears do not receive pure-rotation wrapping.

Validation passes 66/66 smooth trajectories across 33 models and 64/64
constrained trajectories across 32 admitted models. The remaining static-world
model is explicitly checked for the constrained engine's pre-existing
`Nv >= 1` admission limit and returns `CAPACITY_EXCEEDED`; it passes in the
smooth adapter. The raw constrained comparison retains exit 1, and the wrapper
recognizes only that exact expected rejection, separately from successful
trajectories. SO3 regressions pass 34/34 on C 3.15 and 22/22 on production C 3.14.

The two geometry minima prove their ordered floating-point expressions and
bounds: `World_Coordinate` closes 15 checks and `Point_Column` closes 11, with
no open obligations or warnings. Their source/dependency identity is checked
across the proof and runtime snapshots. These are local functional proofs;
complete transmission/controller proofs and performance acceptance remain open.
The production pin stays 3.14, and the new overlay is opt-in through
`build_advanced.py --scalar-site`, adding `--constrained` for the contact adapter.
[Results and scope](evidence/20261009-scalar-site-r124/summary.json) and the
[verified archive](evidence/20261009-scalar-site-r124/scalar-site-r124.zip)
retain both positive and negative runs, exact sources, commands and manifests.

## Measured persistent-factor improvement, 2026-10-24

A fresh quiet comparison now measures the frozen r122 combined Hessian/packed
update changes against r120 and actual C 3.15, with the same six sample-1 models.
All final-state checks and before/after source, binary and reference hashes pass.
There are 24 alternating blocks, 16 trajectories of 100 full steps per block,
CPU 0, normal C SIMD and one excluded warm-up trajectory per block. Runtime
checks remain enabled in both measured Ada binaries. These binaries precede the
new 3.17 migration and subsequent ghost refinements.

| Full movement | r122 mean us/step | Mean duration change r122/r120 [95%] | Mean r122/C 3.15 |
|---|---:|---:|---:|
| membrane_Newton_3 | 12.419 | -0.64% [-3.71%, +2.69%] | 2.535 |
| free | 20.673 | -3.16% [-6.89%, +0.66%] | 3.266 |
| element_2_sphere | 13.784 | +2.84% [-0.70%, +6.63%] | 2.551 |
| element_mixed_pyramidal_3 | 30.916 | -6.87% [-8.63%, -5.04%] | 2.596 |
| element_elastic_cross_elliptic_6 | 72.025 | -24.10% [-25.61%, -22.38%] | 2.550 |
| element_elastic_self_bvh_pyramidal_3 | 59.503 | -3.16% [-6.47%, -0.27%] | 2.565 |

Mixed and elliptic improve in both mean and paired-median estimators, including
intervals corrected for the six mean comparisons. Elliptic also improves its
trajectory p95 by 21.59% [95%: 9.79%, 29.91%]. Membrane, free and sphere remain
unresolved. Self-BVH's pointwise mean interval is favorable, but its paired
median and multiple-comparison interval include parity: no robust improvement
is claimed there. The analysis resamples paired blocks 20,000 times, keeping
the 16 trajectories inside each block together; it does not average percentages
across different models. Complete mean, median, dispersion and tail estimates
are in the [statistical summary](evidence/20261024-hessian-reuse-timing-r122/summary.json).

Own jobs were idle and the observed WSL process window stayed quiet; arbitrary
native Windows background activity is not fully observable. The gap remains
2.54--3.27 times C's mean duration across these workloads. This is historical
C 3.15 evidence, not a timing result for the latest 3.17 reference, nor acceptance
of full-port parity. [Watch/integrity receipt](evidence/20261024-hessian-reuse-timing-r122/watch.json)
and [verified evidence archive](evidence/20261024-hessian-reuse-timing-r122/timing.zip)
retain exact sources, executables, input/output, driver and analysis.

## Packed proof minima and runtime diagnosis, 2026-10-24

The new proof decomposition closes 12 checks for `Flat_Column_Limit`, 37 for
`Flat_Lower_Separate`, and 137 for `Flat_Prefix_Store` (136 proof plus one flow).
The prefix lemma extends the exact ordered floating-point model after the two
actual cell stores, requiring their frames explicitly. These are ghost changes;
public preconditions and runtime arithmetic remain unchanged. Existing
imprecise-Sqrt warnings remain, so the strict warning-free gate is false.
The r131 caller composition has not been reproved; `Flat_Row`, whole
`Update_Flat` and the cache/factor-history model remain open engineering work.
[Results](evidence/20261024-packed-minima-r131/summary.json) and the
[complete archive](evidence/20261024-packed-minima-r131/proofs.zip) retain the
successful minima, rejected attempts, watchdogs and final unproved composition.
The earlier [r129 evidence](evidence/20261024-packed-minima-r129/proofs.zip)
is preserved separately.

Fresh instrumented r122 runs match C 3.15's exact Gram, Hessian-factor and rank
update invocation counts for all six fixtures. The two long profiles include
204,000 evaluations each; elliptic executes 7,428,000 rank updates. Counts
include preparatory forwards. Sampling concerns only the instrumented main
image, may exclude shared-library work, and is not a release wall-time split.
The first collector correctly rejected a relink that changed the ELF hash;
the renewed collector freezes one binary. [Diagnostic results](evidence/20261024-r122-profiles/results.json)
and [sources, counters and profiles](evidence/20261024-r122-profiles/profiles.zip)
preserve both attempts. This diagnosis identifies a separate duplicate FLEX
acceleration solve; its removal requires fresh numerical and timing acceptance.

## Measured single-solve follow-up, 2026-10-24

The r140 candidate accumulates all FLEX passives before one acceleration solve,
while retaining the separate damped Euler solve. It passes all renewed C 3.15
runtime gates in validation and release (78 state, 66 ordinary-force, 66 new
world-wrench and 246 constrained cases). The complete C 3.14 regression also
passes 78/54/54/234. World-wrench cases include changed loads at fixed pose,
repeated evaluation and invalid-shape recovery, with existing tolerances.
The final proof-only r142 refinement closes the private preparation contract
with its two minima; the [FLEX checkpoint](../flex-elasticity-integration/README.md#renewed-force-preparation-acceptance-2026-10-24)
states the exact scope, retained warnings and remaining dynamics obligations.

Fresh timing uses the same verified protocol and byte-identical MJB/input files:
24 alternating blocks, 16 trajectories of 100 full steps, CPU0, normal C SIMD,
excluded warm-up and paired 20,000-draw complete-block bootstrap. Both binaries
retain language runtime checks. The watch, integrity checks and final-state
comparisons all pass. No other own build/proof/profile/compression was active.
Native Windows activity is not fully observable, as in the earlier measurement.

| Workload | r140 mean us/step | Duration change vs r122 [95%] | Mean r140/C 3.15 |
| --- | ---: | ---: | ---: |
| membrane_Newton_3 | 11.326 | -4.33% [-7.47%, -0.96%] | 2.429 |
| free | 19.403 | -5.18% [-7.78%, -2.39%] | 3.094 |
| element_2_sphere | 12.849 | -0.81% [-4.33%, +3.15%] | 2.471 |
| element_mixed_pyramidal_3 | 31.206 | -3.44% [-6.66%, -0.13%] | 2.584 |
| element_elastic_cross_elliptic_6 | 79.737 | +0.23% [-3.08%, +4.49%] | 2.519 |
| element_elastic_self_bvh_pyramidal_3 | 53.007 | +0.37% [-3.00%, +4.63%] | 2.661 |

`free` improves in both mean and paired-median estimators and the Bonferroni
six-model mean interval. Membrane has pointwise favorable evidence, but its
corrected interval includes parity. Mixed's median and corrected interval also
include parity. Sphere's mean interval is unresolved despite its favorable
paired-median estimate. Elliptic and self-BVH remain unresolved: their small
positive point estimates do not establish regressions. No mean percentage is
combined across different models. Complete dispersion, trajectory-tail estimates
and intervals are in the [summary](evidence/20261024-single-solve-timing-r140/summary.json).
[Watch receipt](evidence/20261024-single-solve-timing-r140/watch.json) and the
[self-contained archive](evidence/20261024-single-solve-timing-r140/timing.zip)
retain source closures, binaries, C library, inputs/outputs, wrapper and analysis.
This isolates a historical C 3.15 control; it does not establish latest C 3.17
or full-port parity. The remaining mean gap is still 2.43--3.09 times C.

## Post-change diagnostic counts, 2026-10-24

One separately built and frozen `-pg` r140 binary passes six short count runs and
the two longer `free`/elliptic profiles, with unchanged source and binary hashes
and numerical endpoint checks. The old collector's relink failure is avoided:
this run builds exactly once and reuses that ELF for all eight processes.
Across all six short cases, Gram assembly, Hessian numeric factorization and
rank-update counts still match the validated C 3.15 endpoint-two counter runs.
The long comparisons derive C totals by exact repetition of the recorded
per-trajectory totals; they are not new 2000-trajectory C executions.

For each long model, the full process includes 200,000 steps plus 4,000
preparatory evaluations. Smooth `Solve_Compatible_Buffers` entries fall from
r122's 408,000 to **204,000**. The separate damped-Euler branch remains present;
these two models have zero joint damping. Constraint-solver entries, Gram calls
and Hessian factors remain 204,000, and elliptic rank updates remain 7,428,000.
The [results](evidence/20261024-single-solve-profiles-r140/results.json) and
[archive](evidence/20261024-single-solve-profiles-r140/profiles.zip) retain the
instrumented ELF, lineage, C receipts, inputs, collectors, gmon and output.
The full source closure is also in the paired release-timing archive above.

Remaining sampled main-image work includes solver entry/validation and buffer
preparation, point Jacobians, sparse Gram/factor/backsolve/update kernels and
symbolic filling. The free profile contains only 434 samples, elliptic 1,670;
shared-library time can be absent. Instrumentation and full-process preparation
change these shares. They identify diagnostic targets and do not allocate
percentages of release wall time or of the gap to C.

## Reproduction

With the project's GNAT/GNATprove toolchain and a Python environment containing
the actual `mujoco==3.15.0` wheel:

```sh
python experimental/alignment-3.15/tests/build_foundation.py \
  --out /var/tmp/foundation315-fresh --python /path/to/python315
python experimental/alignment-3.15/tests/prove_sizes.py \
  --foundation /var/tmp/foundation315-fresh --out /var/tmp/size5-fresh --part 5
python experimental/alignment-3.15/tests/build_movement.py \
  --foundation /var/tmp/foundation315-fresh --out /var/tmp/movement315-fresh \
  --python /path/to/python315
python experimental/alignment-3.15/tests/build_flex.py \
  --foundation /var/tmp/foundation315-fresh --out /var/tmp/flex315-fresh \
  --python /path/to/python315
python experimental/alignment-3.15/tests/prove_flex.py \
  --engine /var/tmp/flex315-fresh --out /var/tmp/compact315-fresh \
  --subprogram Compact
python experimental/alignment-3.15/tests/build_gram.py \
  --engine /var/tmp/flex315-fresh --out /var/tmp/gram315-fresh \
  --python /path/to/python315 --reference /path/to/mujoco315
```

Use unique output paths. Proof diagnosis proceeds by minimum, with guarded j1
execution. Historical 3.14 receipts retain their original version and scope.
