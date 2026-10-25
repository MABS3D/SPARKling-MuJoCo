# Native dynamics derivatives

This workspace owns its smooth and constrained scratch simulations. It computes
transition matrices A/B, velocity derivatives of smooth/passive force, and inverse
force/mass derivatives. Transition state is the tangent vector `[dq,dv,da]`;
inverse derivative matrices use the C convention of input directions as rows.
The source model can be freed after creation, and output matrices are preserved
on reported failures. All simulation and contact work runs in native Ada.

## Local commit packaging

The following dated sections retain their original capture-time HEAD and local
status. They are now packaged with their scoped evidence; pending caller proofs,
full dynamics/model binding, version migration and C parity remain open.
Raw ZIPs are represented losslessly by a portable payload store; use the
[verification and restoration commands](../../docs/storage-and-evidence.md).
This packaging changes no checked Ada source, numerical result or performance
claim. No remote push is part of this local commit.

## Local Cross bounds diagnostics r467

The working Ada source remains r455. Neither private Cross variant is adopted.
The actual LTO/256-bit diagnostic profile still places the compatible solver
first (28.33% of chain24 sampled main-image self time), followed by other costs.
Cross executes about 300 calls per chain step and its release body contains
six intermediate subtype checks/twelve comparisons. Instrumented full-process
samples do not attribute that fraction of the Ada/C slowdown.

A private body replaces those redundant subtype restrictions by six proved
Static bounds while preserving all exact expressions and public domains.
Cross closes 86 checks; complete Smooth_Math closes 796 (738 proof, 58 flow),
with 10/66 diagnostics recorded separately. Both boundary profiles pass 5,972
cases/17,916 components bit-for-bit against pinned source-built C3.17, including
signed zero, subnormals, cancellation and maximum admitted operands.

Automatic LTO inlining then improves chain24 time by 7.4–8.5% but regresses
fixed tendons by 6.5–7.0% in two sessions. Keeping Cross separate recovers fixed
tendons but loses the multi-DOF benefit: chain24 first regresses, then remains
inconclusive, and branches24 remains inconclusive. Both variants are retained
as diagnostics. Full promotion gates were prepared but not run after these
performance decisions; no final-source whole-unit proof is claimed for the
No_Inline diagnostic variant. No suppression or reduced contract is adopted.

[Scoped/whole proofs, exact-bit tests and runtime correction, current profile,
C sources, disassembly and all four paired sessions](../alignment-3.17/evidence/20261025-cross-bounds-r467/README.md).
No commits, staging, pushes or remote writes. Three examined caller obligations
and wider functional dynamics, port/alignment and C-parity gaps remain open.

## Local release SIMD width r455

Release compilation now prefers 256-bit vectors for Solver_Kernels only, keeping
native O3, release LTO, FP contraction off and the row dispatch threshold 16.
Ordinary validation flags, checked Ada formulas/contracts and production pin
are unchanged. The actual Add_Long_Row machine code uses ymm arithmetic.
This measured native-target preference is not a portable speedup guarantee.

All private C3.17/C3.14 numerical gates and row/cache/CRB suites pass. The real
adopted GPR and shared builders are rebuilt/rechecked, including 14,905 row
cases per profile, 48 cache records/144 states, and 1,026 direct CRB cases per
profile. Existing scoped language proofs apply to the identical Ada sources;
three examined caller obligations and wider dynamics/port proofs remain open.

Two additional full default-build movement sessions retain 5.5–5.9% less ball
joint time and 8.2–8.5% less fixed-tendon time versus the same Ada/LTO sources
with native vector width. Chain24 medians improve 1.8–2.4%, but one 95% interval
crosses 1. All branches24 intervals cross 1, with median changes from -0.7% to
+1.4%; no benefit or regression is established there. Model-specific raw
samples, intervals, dispersion/tails and independent C comparisons remain
separate; no global average, universal speedup or C parity is claimed.

[Sources, private harness correction, compiler recipes, numerical gates,
disassembly and four timing sessions](../alignment-3.17/evidence/20261025-width256-r455/README.md).
No commits, staging, pushes or remote writes. HEAD remains 398c2dde.

## Local rejected SIMD threshold r450

The private Count>=8 dispatch variant is not adopted. Its exact row contracts
close all 40 minimum checks and 156 whole-unit checks, and both profiles pass
14,905 row boundary cases. Two complete integrated sessions nevertheless show
3.2–4.1% higher chain24 time and 2.6–4.3% higher branches24 time. Small-model gains
do not establish compensation or C parity. The working threshold remains 16,
with release LTO unchanged. No formula/domain/check weakening is retained.

[Source, proof, row corpus, raw paired timings and rejection decision](../alignment-3.17/evidence/20261025-row-eight-r450/README.md).
No commits, staging or pushes. The three examined caller obligations and wider
port/proof/performance gaps remain as documented at r441/r430.

## Local tendon caller proof r441

The real compact-construction caller now proves its tendon accumulator
precondition after the borrowed mass write. The minimum closes 21 checks with
12 inherited diagnostics; two caller obligations remain, plus the unchanged
Solve postcondition. Three examined obligations are still open, and the wider
physical model/cache and full dynamics proofs remain unfinished.

Only a GNATprove expression-body annotation is retained. Input domains,
contracts, runtime formulas/checks, deallocators and release LTO are unchanged.
Private readiness/model diagnostics did not close additional obligations and
are not adopted. No new runtime speedup or whole-dynamics Gold is claimed.

[Sources, all diagnostic attempts, exact proof scope and source audit](../alignment-3.17/evidence/20261025-tendon-caller-r441/README.md).
No commits, staging or pushes. Performance and numeric evidence remain versioned
at r430; the proof-only change is recorded separately.

## Local compact export and release LTO r430

Release builds of this candidate now use -flto=1 in the compiler and linker,
with native O3 and FP contraction off. Shared movement/row/cache/compact-row
builders use the same flags; --no-lto preserves the diagnostic control. Ordinary
validation flags and the production C3.14 pin remain unchanged.

The static export lemma and public Get_Mass_Matrix close 15 and 19 checks.
Complete Compact_Inertia closes 377 (351 proof, 26 flow), with its same six
warnings recorded separately. The proved expansion bound removes the second
runtime domain traversal at the strict diagnostic boundary. Four examined
caller obligations remain, plus wider functional dynamics/model composition;
no whole-engine proof or C3.17 migration completion is claimed.

All ordinary and LTO C3.17/C3.14 numeric gates pass. Both row profiles pass 14,905
exact boundary cases; the Euler/cache control covers 48 records/144 states.
The real default GPR and builders are reconfirmed after adoption, including
1,026 compact constructor cases per profile with zero observed C difference.
Two additional default-build movement sessions show 8.1–9.4% less chain24 time
and 13.3–14.5% less branches24 time versus the same sources without LTO, with
exact Ada outputs. Against the pinned source-built C3.17 with known GCC16/AVX/LTO
flags, ratios remain roughly 2.32–2.38 and 1.66–1.69. Wheel comparisons remain
separate; no unweighted aggregate, full-port or C-parity claim is made.

[Local sources, all attempts, scoped/whole proofs, gates, eight timing sessions,
profiles, reference build and remaining scope](../alignment-3.17/evidence/20261025-compact-callers-r430/README.md).
No commits, staging or pushes. Historical sections below describe their own
snapshots; r430 supersedes the r411 strict-boundary scan/build-policy status.

## Local canonical compact mass r411

The nv>=3 CRB stepping route now constructs mass directly in persistent compact
ancestor rows, applies representable tendon terms there and loads the factor
without a dense gather. Public/native mass readers, inverse multiplication and
the constrained adapter select the canonical view. Small models and unsupported
tendon layouts retain the dense compatibility path; strict diagnostic solving
still expands and scans at its boundary.

Complete Compact_Tendon_Mass and Compact_Assembly units close 100 and 117
checks respectively, with diagnostics recorded separately. The publication
minimum closes 20 warning-free checks. These are scoped results: five caller
obligations remain, and the physical model/cache binding, complete factorization
and whole dynamics proof are unfinished. Build currently specifies boundedness;
its full source-to-row functional composition still needs a stronger contract.

Final-source validation and release pass the complete C3.17/C3.14 numerical
gates. Four integrated timing sessions retain roughly 4.7–6.9% less chain24 time
and 3.2–4.7% less branches24 time than the previous Ada path. Hinge changes sign
between session pairs; both results and binary/source audits are retained.
Chain24 still takes about 3.2 times the C wheel time. Wheel compiler flags remain
unknown, so matched-build C acceptance is pending. No aggregate compensation or
full performance parity is claimed.

[Local sources, proof attempts, route checks, final gates and all timing sessions](../alignment-3.17/evidence/20261025-canonical-mass-r411/README.md).
No commits, staging or pushes. Earlier sections below describe their historical
snapshots; r411 supersedes the r380 integration status.

## Local direct compact CRB rows r380

The new Assemble_Row/Assemble_Into_Row constructors follow C3.17 mj_crb directly:
one composite-inertia product, descending ancestor projections, diagonal armature,
and a fixed-diagonal shortcut. They do not use a dense intermediate. Public domains
and exact rounded expressions remain unchanged; rejected scratch stays bounded,
and the shared-slab wrapper preserves every cell outside its row.

The constructor minima close 37 and 42 checks. Two existing invariant gaps are
now closed through proved pure composition lemmas (15/29 checks), with Expand and
Project_Row minima closing 66 and 70. The complete Compact_Inertia unit closes
367 obligations (341 proof, 26 flow); six existing reassociation/initialization
warnings remain. obligations_closed=true and strict passed=false. These scoped
counts are not additive or a proof of complete dynamics/model binding.

Both validation and release pass 1,026 row cases, with 100,236 C-reference values
compared per profile and maximum observed absolute difference 0.0. These are
numerical tests, separate from the functional proofs.

The constructors are not yet called by the simulation. Canonical compact cache
publication, tendon mass couplings, compatible/strict solve inputs, inverse
multiplication and native/public readers still need coordinated integration.
The stepping path still builds dense mass and packs it. No new integrated
performance gain or C parity is claimed.

[Local sources, all proof attempts, complete-unit result and C row checks](../alignment-3.17/evidence/20261025-compact-row-r380/README.md).
No commits or pushes.

## Local four-value experiment r365

The C-style four-value prototype is not adopted. Its arithmetic, rejection lemma
and block minima close 17, 8 and 39 checks, but the complete row retains four
open invariants even with a targeted 10-second prover budget. Longer integrated
measurements retain roughly 1–3% chain regressions. The active Ada kernel remains
byte-identical to r349. Exact arithmetic, checks and public domains are preserved.

The movement runner now accepts explicit warmups and a diagnostic model subset;
its default suite is unchanged, and subset inputs match the complete suite.
[Local sources, all attempts, proofs, numerical cases and six timing sessions](../alignment-3.17/evidence/20261025-four-row-r365/README.md).
No commit, push, whole-dynamics Gold or C performance parity is claimed.

## Local SIMD row and caller closure r353

The current kernel keeps the previous short scalar row and delegates Count>=16
to a separately compiled long-row helper. Widened source-index arithmetic enables
actual SIMD while retaining the final index conversion and array checks. The
public input domain, exact rounded expression, rejection and full frame remain
unchanged. No machine-width attribute, global flag change or suppression is kept.

Long-helper and wrapper minima close 38 and 40 checks. Whole Solver_Kernels closes
156 (139 proof/17 flow), with six recorded integer-expression warnings including
duplicated private row expressions. Separately, the real Solve_Compatible_Buffers
minimum closes 86 (80 proof/6 flow), including its row-call preconditions and
current output/diagnostic contract. Ten inherited recursive-model warnings remain
for that scope. These counts are not additive or a whole dynamics proof; the
complete factorization model and global physical composition remain open.

All 14,905 row cases pass in validation/release. Full C3.17/C3.14 mass, derivative
and boundary gates also pass on the exact retained sources. Two integrated
sessions show about 0.7–2.7% less chain time relative to the retained r326 bit
baseline, with small tendon improvements and some uncertain intervals. Hinge
still has about 0.9–1.9% higher central timings; ball and other regressions remain
in the reports. No unweighted aggregate or final C-parity claim is made.

Detailed compiler reports explain why widening helped and document the C
four-double kernel versus the compiler's larger groups. Native unpartitioned
SIMD and local vector-width preferences remain experiments; the 128-bit variant
has repeatable small-model regressions and is not adopted. The retained long
helper has actual vector arithmetic without those attributes.

[Local r353 sources, scoped/whole proofs, full gates, raw timings and rejected variants](../alignment-3.17/evidence/20261025-vector-row-r353/README.md).
All work remains local, with no commits or pushes. Complete migration, functional
dynamics composition, full-port scope and matched-build C parity remain open.

## Local integer-bit row update r329

The working solver now uses an unsigned integer OR to record rejected entries
in its disjoint packed-row update. Exact arithmetic/frame/rejection contracts
and the public input domain are unchanged. No language checks are suppressed.
The Flag_Rejection minimum closes two checks, the row minimum closes 39, and
whole Solver_Kernels closes 117 (102 proof/15 flow). Four integer-expression
reassociation warnings remain recorded: obligations closed, strict pass false.
This proves the rounded row algorithm, not the complete simulation.

Both validation and release pass all 14,905 row boundary cases. Complete C3.17
and C3.14 raw mass/derivative/boundary gates pass on the same final Ada sources;
C3.17 reordered derivative cases also pass. Two separate integrated sessions
cover 30 scenarios each, with exact baseline/current Ada results and the existing
C tolerance. Chain24 takes about 9–10% less time and free+ball about 2.5–6% less.
Spatial-tendon movement remains about 2% slower, and fixed-tendon medians are
1.2–6.2% higher with wider, mixed intervals. These regressions remain work to do;
there is no unweighted aggregate improvement or final C-parity claim. The C wheel
library's compiler flags remain unknown. Global flags are unchanged.

Release assembly still has a scalar updated loop: source-level bit operations
have not supplied extra SIMD. The separate compiler report identifies an unsupported vector type for the
indexed Ada array load in this loop, alongside index/overflow exception paths;
other loops in the same solver are vectorized with 64-byte vectors. This is an
observed compiler diagnostic, not a claim that all checks are the sole cause.
The slice-view experiment passes the numerical corpus but adds no SIMD, has
chain/branch regressions and leaves two invariants open; it is not adopted.

[Local r329 proof, complete gates, timings, assembly and compiler report](../alignment-3.17/evidence/20261025-bit-row-r329/README.md).
[Unadopted view experiment and its open proofs](../alignment-3.17/evidence/20261025-view-row-r334/README.md).
All work remains local, with no commits or pushes. The full port, stable-release
migration and performance acceptance against C remain open.

## Local row-update investigation r324

The current full-movement profile identifies compatible factor/solve as the
largest sampled cost on the 24-DOF chain (403/1011 main-image samples). Its
inlined disjoint row update accounts for 251 samples. Branches have 100/494 samples
in the solver; the free-joint profile has only 44 samples and is too coarse for
small-cost rankings. These instrumented full-process samples include setup/I/O
and are diagnostic, not an attribution of the C performance gap.

Two exact row-update variants were proved and measured locally. Direct arithmetic
closes 39 minimum checks and 115 whole-unit checks; retaining the original helper
for rows shorter than 8 closes 46 and 122 respectively. Whole units retain five
integer-expression reassociation warnings (obligations closed, strict pass false).
Both pass 14,905 row cases in validation/release, and every timed Ada trajectory
is exactly equal to baseline. The direct variant additionally passes the full
C3.17/C3.14 numerical gates in both profiles.

Neither variant is promoted: the direct version improves the chain about 9% but
repeatedly regresses small models, including ball/free about 10%. The long-row
version improves the chain 3–4%, with smaller but repeatable 1–2% losses on several
small-model cases. The active solver body was restored byte-for-byte; earlier
project work is preserved. Compiler flags remain unchanged. The profile/check
runners and both frozen candidates remain available. The next investigation is
the checked rejection reduction inside the row loop, under the same exact
rejection and frame contracts and with individual SIMD-lane failure tests.

[Local r324 sources, proofs, raw profile, paired sessions, regressions and decision](../alignment-3.17/evidence/20261025-row-update-r324/README.md).
No commits or pushes. Full-port completion and C parity remain open.

## Local common composite assembly r315

The common CRB loading/accumulation unit now closes **479 checks (450 proof,
29 flow)**. It proves the exact descending rounded accumulation, world-parent
skip, intermediate bounds and successful completion under its original bounded
input domain. It is reused by Inertia_Phase and the raw shared mass reader,
removing that reader's redundant per-parent bound test. Twelve extracted-model
and weight-helper warnings remain recorded; obligations_closed=true and strict
passed=false. No assumptions, skips or stronger input restrictions were added.

Validation and release pass the full C3.17 and C3.14 mass/derivative gates,
including maximum 4096-body chain/star/forest tests with independent closed-form
expectations and a cancellation test that detects reassociation. The complete
shared reader still reaches its aggregate proof limit: full row/tendon behavior
and physical pattern/cache binding remain open. No whole workspace Gold claim.

The new full-movement harness supports separate nq/nv, ball/free, tendons,
controls, applied forces and body wrenches. Two-session paired evidence includes
30 scenarios per session and exact Ada trajectory equality. The initial default
build showed a repeatable free-joint regression around 4%. Same-source 32-byte
alignment improves that case about 5%, but direct original/candidate comparisons
include mixed-model uncertainty and one slower free_ball state in one session.
Global release flags remain unchanged; the aligned build is an experiment.
Supported smooth movement remains materially slower than C. The official C3.17
wheel's unknown build flags also leave matched-build performance acceptance open.

[Local r315 proof, all numerical/timing records, failures, decisions and scope](../alignment-3.17/evidence/20261025-composite-assembly-r315/README.md)
are independently hashed and reread. All work remains local, with no commits or
pushes. Complete stable migration, shared dynamics and integrated C parity remain
part of the active port goal.

## Local public mass-reader contract r278

The public Evaluate wrapper now closes **30 checks (27 proof, three flow)**.
For a disjoint pattern it specifies the exact projection of the current mass
cache, zero unused slots, and Success versus Invalid_Size with a zero failure
output. Its original readiness/current-cache preconditions are unchanged. The
shared CRB branch is now a separate private subprogram; its full functional
proof remains open. The normal path no longer enters its composite-buffer
allocation. No movement speedup or C performance parity is claimed.

The six helper scopes close separately on the same final source: Capture 6,
Capture_Validated 8, layout lemma 2, pattern lemma 3, Gather_Current 19 and
Gather_Disjoint 19 checks. These are not added together as a whole-unit proof.
Each scope retains the two inherited structural recursion/variant warnings:
obligations_closed=true, strict passed=false. No warnings or obligations were
suppressed. Minimum source/hash checks and numerical gates are recorded in the
[local r278 checkpoint](../alignment-3.17/evidence/20261024-native-reader-disjoint-r278/README.md).

Validation and release each pass C3.17's 288 raw mass states, 960 original and
960 reordered derivative samples; historical C3.14 passes 132 raw states and
960 derivative samples. Four malformed-model and five reader-shape scenarios
also pass per version/profile. Shape tests include source-model release before
use. The reordered C oracle and known direct C crash retain their prior limits.

Pattern-to-simulation physical binding, proof of the cache producer, shared
implementation/workspace composition, full 3.17 migration and integrated C
performance parity remain open. All changes and evidence remain local, without
new commits or pushes.

## Local native-model constructor closure r245

The two earlier model-to-pattern obligations are closed. Separately proved
single-row and table-layout lemmas now connect the full validator contracts to
the owned pattern without stronger input restrictions or new executable scans.
Native_Mass_Models closes its complete 114 checks (96 proof, 18 flow), including
exact constructor status and copied metadata. The full report retains four
reviewed Model_Structures warnings: two reassociation and two recursion/variant
warnings; obligations_closed is true, strict passed remains false.

The equivalent factored pattern predicate closes 151 checks (126 proof, 25 flow)
without warnings. Minimum scopes run before both complete units. The model unit
needs about 294 seconds total; its aggregate watchdog is 600 seconds while prover
attempts remain limited to three seconds and the group to 2500 MiB.

[Local r245 sources, whole-unit proof, gates and remaining scope](../alignment-3.17/evidence/20261024-native-model-closure-r245/README.md)
supersede the open constructor obligations recorded below. This closes the owned
model-copy contract under its validator dependencies; full Data.Native_Mass and
workspace composition, shared-buffer dynamics, full stable-version migration and
integrated C performance parity remain open. Everything stays local/uncommitted.

## Local owned-pattern proof checkpoint r224

Native_Mass_Patterns now models the owned row metadata separately from the
simulation. Exact overlap detection, full descriptor/column copying and the
composed disjoint gather close 149 checks (126 proof, 23 flow), after minimum
scopes, with no warnings, skips or assumptions. The shared flag is specified
exactly; touching intervals stay disjoint and unused output slots remain zero.

The public model and workspace boundaries check table layout before invoking
Is_Valid. An already validated workspace uses Capture_Validated, removing the
reader's previous second whole-model validation. The model bridge is separate
from the pure pattern proof: two Reveal_Source obligations remain open, and
Capture/Evaluate/workspace composition is not claimed Gold. These are proof
engineering tasks, not mathematical Silver exceptions. The maximum-sized Seen
array is replaced by row-pair interval checks; no creation-speed claim is made.

[Local sources, all regression gates, failed proofs and remaining obligations](../alignment-3.17/evidence/20261024-native-patterns-r224/README.md)
are kept independently of the historical r195 evidence. Everything remains local
and uncommitted; full 3.17 migration and integrated performance parity stay open.

## Local 3.17 native-storage migration, 24 October 2026

The local candidate uses the verified 3.17 foundation and accepts disjoint M
rows in their actual storage order. It owns row addresses and gathers the
already computed mass without repeating CRB on this normal path. Shared raw M
images follow C's assignment/accumulation/tendon order, but shared numeric-buffer
dynamics remains unsupported: workspace creation returns Unsupported_Feature.

Three new storage kernels close 47 whole-unit checks (40 proof, seven flow),
after minimal scopes, with no warnings, assumptions or skips. Full reader and
workspace composition proofs remain pending. Both validation and release pass
960/960 derivative samples with normal storage and 960/960 with reordered rows;
the latter use the original C model plus a checked bijection of Mq columns.
The raw 3.17 mass comparison passes 288 states per profile with zero numerical
difference. The unchanged historical 3.14 domain passes 960 derivative samples
and 132 mass states per profile, including the original duplicate-tendon fixture.

A direct C oracle crashes on reordered Newton/sparse elliptic contact storage;
an isolated C-only reproducer and source analysis are retained. C 3.17 also
rejects its own nv=2 duplicate-tendon fixture, so a third independent DOF keeps
that coverage while the original compiler rejection is recorded separately.
These controls establish neither complete 3.17 migration nor movement performance
parity. No new commits, pushes, upstream PRs or timing claims were made.

[Complete local sources, contracts, gates, limitations and reproduction](../alignment-3.17/evidence/20261024-native-mass-r195/README.md)
are kept separately from the historical evidence below.

The C 3.14.0 comparison now includes 80 model configurations and 12 samples each:
smooth manifolds, fluid, tendons, activations, solver methods, dense/sparse
elliptic cones and 55 adhesion configurations. The final ablation snapshot
`/var/tmp/sparkling-services-derivatives-axis-20261003` passes 960/960 with the
original finite-difference tolerances. The subsequent production closure
`/var/tmp/sparkling-services-inverse-derivatives-production-20261003` also passes
960/960 after both common patches were applied. Source and binary hashes are
saved in `evidence/recovery-20261003`.

Three defects were isolated without widening tolerances:

- Constraint reference velocity must use C's dense/sparse reduction order.
- Quaternion perturbation normalizes the input before the multiplication and
  keeps the resulting quaternion without a second normalization.
- Joint axes and anchors use C's quaternion-vector rotation. Matrix rotation
  has different floating-point rounding despite algebraic equivalence.

Seven executable arithmetic/storage kernels and their whole unit pass 82 proof
checks plus 14 flow checks. Their contracts cover ordered differences, control
stencil selection, matrix writes and preservation of other entries. `Within`
is a Boolean expression definition with only two flow checks; these are not
counted as arithmetic proofs. These results neither prove real derivative
accuracy nor the full workspace/contact/integration composition.

Remaining scope includes sensor Jacobians C/D and DsDq/DsDv/DsDa, history and all
producer combinations, inverse-discrete correction, integrators beyond the
currently admitted Euler workspace, public C ABI and integrated performance.
The official C finite-difference entry points reject sleep, RK4 and no-slip;
those restrictions are not evidence that the corresponding engine features have
been ported. Complete success/frame and composition proofs remain pending.
