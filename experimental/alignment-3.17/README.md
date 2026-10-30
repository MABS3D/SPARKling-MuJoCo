# Coordinated MuJoCo 3.17 foundation candidate

Official reference: [3.17.0, 22 October 2026](https://github.com/google-deepmind/mujoco/releases/tag/3.17.0),
commit `800a109a4bdd02cb60404d565db4ae16fb04a53b`.
The production pin remains 3.14; the separate 3.15 candidate and its evidence
remain reproducible. This candidate does not establish engine migration, full
functional Gold, or integrated C performance parity.

The generator recognizes the exact 3.14, 3.15 and 3.17 schemas. The 3.17 model
adds `nefmCvert`, `efmC_perm` and `tex_contenttypeadr`; `mjNEQDATA` is 12.
Its MJB fixed block contains three flags, including `flg_adhesion`, whereas the
older two ABIs contain two. Readers, size calculations, allocation/release,
reference clauses and the test serializer are generated together. The loader
publishes the serialized adhesion flag only when that ABI contains it.
`Without_Flex` also clears the new ordering size, and the 3D elasticity stride
stays 24 in both 3.15 and 3.17.

`Read_Flags` has a local contract specifying the exact decoded bytes; the scoped
proof evidence is recorded below. `Read_Fixed` composition, the full generated
readers and the caller proofs remain open on the candidate sources. Adding a
contract alone is not a successful proof.

The foundation runner has three explicit phases. Preparation copies and hashes
sources from the pinned checkout. Generation compiles/runs the real header
dumps, regenerates the Ada closure, applies the required 3.17 validation overlay
and compiles corpus images with the actual official wheel. The current builder
also applies the structural overlay and verifies its real admission cases. Verification runs
all ten existing Ada suites, exact ABI comparisons, generation reproducibility
and the existing Python tests. Each phase retains commands, logs and hashes;
a failed command stops that phase. No corpus input or failed case is silently
removed to establish acceptance. Both build profiles retain runtime checks.

```sh
python3 experimental/alignment-3.17/tests/build_foundation.py --phase prepare --out /var/tmp/align317-new --reference-root /path/to/official-3.17-checkout
python3 experimental/alignment-3.17/tests/build_foundation.py --phase generate --out /var/tmp/align317-new --python /path/to/mujoco317-venv/bin/python
python3 experimental/alignment-3.17/tests/build_foundation.py --phase verify --out /var/tmp/align317-new --python /path/to/mujoco317-venv/bin/python --mode validation
python3 experimental/alignment-3.17/tests/build_foundation.py --phase verify --out /var/tmp/align317-new --python /path/to/mujoco317-venv/bin/python --mode release
```

The ABI fixtures distinguish the actual new behavior: an adhesive geom with
the third flag set, automatic/explicit welds with 12 data values, a 1D elastic
rod with a nonempty sparse metric ordering, embedded and by-reference textures,
and an ordinary model. The probe compares decoded arrays bitwise and checks
byte roundtrips. Two deliberately forged old headers must be rejected.
Three additional scenarios corrupt the owned model after raw decoding and
exercise `Validate`: permutation entries below -1 or at `nv`, and an external
texture without a path. They are identified separately from C-produced images.
The permutation mutations use a nonflex model so the existing unsupported-flex
guard cannot mask the field being tested. This is test setup, not a change to
the public admission domain.

The validation overlay adds current texture and permutation semantics. Sparse
validation and the remaining 3.16/3.17 engine changes must be audited and covered
before production adoption. Latest-stable alignment includes the actual
producers, integration paths, resources and public APIs; accepting the new ABI
alone does not complete that work.

## Initial validation checkpoint, 24 October 2026

Frozen foundation r3 passes all ten Ada suites, all 72 existing Python tests,
generation reproduction and 12 ABI scenarios, with the source closure unchanged.
All 100 official/fixture corpus images decode raw; validated loading agrees with
49 accepted models, 36 expected unsupported-flex rejections and 15 expected
unsupported-plugin rejections. These are foundation results, not 100 supported
physics simulations.

The `Read_Flags` minimum closes 14 proof and four flow checks on 3.17 and ten
proof and four flow checks on 3.14, without open obligations or warnings. The
contracts specify the exact flag bytes and the legacy absent-adhesion result.
Complete fixed-block, loader and engine Gold remain open. The first proof-driver
attempt rejected a successful prover report because it recognized only the body
location; the renewed driver also verifies the unique matching specification
location. Both attempts are retained.

The first complete ABI comparison retained five failures caused by test output
joining negative integers to their field labels. Explicit separators corrected
the transport; the new immutable run passes every case without changing engine
code, guards, data or tolerances. Earlier fixture preparation also retained two
rejected designs: actuator adhesion does not set the geom/pair adhesion flag,
and an ordinary 2D flex does not allocate the new sparse ordering. The final
cases use an adhesive geom and a 1D elastic rod, following the real C producers.

Checked/release runtime regression and additional scoped proofs are separate
acceptance steps. The initial validation snapshot does not promote the
production pin or establish integrated performance.

## Reference-table audit and known C regression

The first generator regex silently omitted `flex_vertedgeadr`, whose target is
`nflexedge*2`. The replacement parses every complete X row or rejects the table;
its regression test compares the ordered row names with an independent count
from the actual C macro and covers the multiplied target explicitly. The
pinned sources contain 96 reference rows in 3.14, 95 in 3.15, and 98 in 3.17.
The first 3.17 candidate represented 97. An audit initially assuming 99 was
rejected and retained; the source, rather than that assumption, determines the
required count. Multiplied target/count/address arithmetic is emitted in Int64.
The additional reference and its callers require fresh validation evidence.

The 3.17 C validator also rejects a fixed tendon containing two terms on the
same joint when `nv=1`: `ten_J_rownnz` is 2, although its nonstrict column list
`[0,0]` is valid. The identical XML compiles, saves, reloads and runs on C 3.15.
Controls with a merged term or a second DOF pass on C 3.17, isolating its new
`rownnz <= nv` check. The port retains duplicate-capable nonstrict tendon CSR;
this confirmed upstream regression is not reproduced by narrowing Ada's domain.
The local evidence records the unmodified wheel hashes, XML, command outcomes
and controls. No upstream PR has been published for this investigation.

C 3.17 adds other sparse/ancestry admission checks that still require an audit
against the port. The current ABI candidate therefore does not claim whole
validation equivalence or completed latest-stable engine alignment.

## Complete parser checkpoint r5, 24 October 2026

The renewed immutable candidate passes both validation and release: ten Ada
suites, 77 Python tests, 12 ABI scenarios, eight direct boundary cases of the
wide reference target, and deterministic regeneration in each profile. All
98 actual C reference rows are represented. The corpus remains 100 raw models
with the 49/36/15 admitted/flex-rejected/plugin-rejected split above.
The r4 negative boundary probe incorrectly expected Integer'Last to fit below
2*Max_Size, although Max_Size is 2**27-1. Its failure is retained. Only those
expectations changed for r5; the generated runtime predicate was preserved.

Production 3.14 passes its ten Ada suites in validation and release, plus the
72 existing Python tests in validation. The final production Ada source and
corrected project equal that regression snapshot; the five added parser tests
pass separately and in the full 3.17 runs. The already proved Read_Flags body,
contract, constants, byte reader, types and relevant declarations are byte
identical between r3 and r5; the dependency audit records this limited reuse.
The new reference predicate and complete validator do not inherit that flag
proof. All negative attempts and exact source objects are retained in the
verified evidence archive. Complete engine alignment, whole-loader Gold and
integrated performance acceptance remain open.

## Publication evidence, 24 October 2026

The [upstream source audit](evidence/20261024-upstream-source-audit/report.md)
compares the pinned 3.15 and 3.17 implementations; its
[archive](evidence/20261024-upstream-source-audit/source-audit.zip) retains the
source files, exact diffs, tag receipts and schema audit. The separate
[fixed-tendon reproducer](evidence/20261024-fixed-tendon-c-regression/reproducer.zip)
contains the unchanged C-wheel regression, controls and an unsubmitted proposed
patch. Publishing this repository does not submit an upstream pull request.

The [foundation r5 public evidence](evidence/20261024-foundation-r5/README.md)
retains deduplicated source snapshots, commands, logs, reports, XML and small MJBs,
with verified hashes. Its manifest explicitly lists omitted large generated MJBs
and executable payloads; the complete original archive is preserved locally.

## Structural kernel checkpoint, 24 October 2026

The isolated `MJ.Model_Structures` unit closes 315 complete-unit checks after
29 minimal scopes; four recursion and two operator-reassociation warnings
remain explicit (six total). Functional
contracts cover CSR rejection/first bad row, ordered subsets, row equality and
ancestor/mass-row relations. Validation and release each pass 1230 cases: 1222
against the exact C3.17 sparse-validation helper, seven owned-shape cases and
one documented duplicate-tendon correction.

Proof diagnosis corrected a wide-length comparison in Shape without narrowing
its public domain. All final proof and runtime kernel sources are identical.
[Evidence and retained negative attempts](evidence/20261024-structural-kernels-r150/README.md)
identify the scope precisely. This kernel closure does not promote the
production pin. See [the remaining composition work](VALIDATION-STRUCTURES.md).

## Historical local admission checkpoint r158, 24 October 2026

The isolated complete source-library overlay compiles in both profiles.
`MJ.Model_Admission` closes 88 whole-unit checks after minimum-scope diagnosis;
two recursion warnings and two operator-reassociation warnings remain visible
(`obligations_closed=true`, strict `passed=false`). Its success contracts compose the FLEX/B/D predicates under
the separately proved kernel contracts and stated preconditions. Small ghost
layout lemmas and opaque predicate composition reduce proof context without
narrowing the public domain. Ghost lemmas add no runtime checks; assertion-enabled
builds still evaluate the executable contracts.

Validation and release each pass 43 real C-produced MJB scenarios: 33 FLEX
helper cases, seven B/D cases and three mesh cases. The unchanged official C3.17
validator supplies the reference verdicts. Exact typed diagnostics are checked
in Ada, including complete validation for B/D and mesh. Full FLEX admission
still returns `Unsupported_Flex`; its new helper tests do not remove that limit.
[Local source, proof, runtime and failure evidence](evidence/20261024-model-admission-r158/README.md)
retains the final candidate and preceding attempts. Complete-validator caller
proofs, renewed full foundation/corpus and historical gates with this overlay,
engine migration and integrated performance parity remain open. These changes
have not been committed or pushed.

## Historical integrated foundation checkpoint r176, 24 October 2026

The structural overlay is now part of the complete candidate builder.
Its final library/project closure equals proof snapshot r174 byte for byte
(46 files). Model_Admission closes 116 whole-unit checks, with two recursion
and two operator-reassociation warnings visible. The mesh core/wrapper close
36/6 checks; the affected Diagnose_Sparse, Diagnose_Assets, Compute_Caps,
Diagnose and Validate contracts close 54/67/38/14/7 checks respectively, under
their stated preconditions and callee contracts. The receipts audit reused
unchanged subprograms separately from a fresh whole-unit claim.

Both validation and release pass ten Ada suites, all 100 corpus inputs, twelve
ABI scenarios, eight direct wide-reference cases, deterministic regeneration,
77 Python tests and 49 real C-produced structural scenarios. Corpus loading
still admits 49 models and explicitly rejects 36 FLEX/15 plugin models; this
is not evidence of 100 supported simulations. Structural scenarios cover
populated FLEX patterns, B/D consistency, map bounds and mesh zero-count cases.

[Local proof, complete gate and failure evidence](evidence/20261024-caller-foundation-r176/README.md)
retain exact sources, commands, oracle, reports and explicit regenerable
omissions. The bounded count contracts do not yet specify exact counts;
capacity sufficiency, complete generated/validator Gold, C row-span domain,
FLEX/plugins/engine migration and integrated performance parity remain open.
All changes remain local, without new commits or pushes.

## Native sparse row-domain checkpoint r186, 24 October 2026

Native M/B/D/tendon admission now follows the actual C3.17 row-span algorithm.
Rows need not be stored in order or use every slot; shared/prefix spans and
unused storage are accepted. Six real MJBs that C accepted but the previous
Ada validator rejected now have explicit regression coverage. The legacy compact
CSR_OK utility remains for older callers, independently of native admission.

The new native adapters specify the exact mapper/kernel diagnostic result,
including the first bad row and width/address/column field. Their four minima
close twelve checks each. Removing the redundant parent/child row scans and
D/B span guards retains proved preconditions (15/18 checks). Model_Admission
closes 166 whole-unit checks; its existing two recursion/two reassociation
warnings stay visible. The renewed sparse/diagnostic/public caller scopes close
42/14/7 checks. No assumptions, proof skips or new trusted bodies were added.

Both profiles pass the full ten Ada suites, 77 Python tests, 100 corpus inputs,
twelve ABI cases, eight wide-bound cases, deterministic regeneration and 69
admission regressions. Updated native diagnostic expectations agree with C;
the same version-aware test passes on the unchanged historical 3.14 library.
Four C disjoint-storage controls preserve 32 steps exactly; shared spans are
admission-only controls. None of this is a movement performance comparison.

[Local source, complete gate, historical and consumer evidence](evidence/20261024-row-domain-r186/README.md)
record the remaining explicit compact-M restriction in the derivative adapter.
Full consumer/engine migration, FLEX/plugins, global Gold and integrated C3.17
performance parity remain open. Production stays on 3.14 and no changes have
been committed or pushed.

## Native mass / derivative checkpoint r195, 24 October 2026

The derivative adapter's earlier compact-row restriction is removed for disjoint
M spans. It preserves actual storage addresses and reuses the already published
mass. Shared spans have a C-ordered raw-image reader, while their full dynamics
remains explicitly unsupported by workspace creation. Full reader/workspace Gold
is still open; the three elementary storage kernels close 47 checks with no
warnings, assumptions or skips after minimum-subprogram proofs.

Both profiles pass 288 raw mass states (zero difference) and 960 derivative
samples on C 3.17, plus 960 samples with reordered storage against the original
C model and a verified Mq column permutation. Direct C evaluation of the
reordered Newton/sparse case crashes; its isolated reproducer is retained.
Both profiles also pass the original C 3.14 derivative corpus and raw mass
controls. These gates establish neither complete engine migration nor integrated
performance parity. The 45 foundation library files remain byte-equal to r186;
the derivative candidate has its own GPR project.

[Local r195 evidence and remaining scope](evidence/20261024-native-mass-r195/README.md)
retain the failed attempts, reference limitations and exact oracle definitions.
All changes remain local and uncommitted; production stays on 3.14.

## Owned native-pattern contracts r224, 24 October 2026

The new Native_Mass_Patterns unit closes 149 checks with exact metadata copying,
interval overlap and disjoint mass-image contracts. No assumptions, skips or
warnings were introduced in this unit. Constructors reject unallocated or
inconsistently sized model tables before invoking Is_Valid; the already validated
path reuses its caller's validation. Both the constructor bridge and complete
reader/workspace composition remain separate objectives: two model-to-pattern
obligations are still open, with the inherited structural warnings retained.

[Local r224 proof and runtime evidence](evidence/20261024-native-patterns-r224/README.md)
records the exact gate scope and failed attempts. This does not establish whole
3.17 migration, global Gold or C performance parity. No commits or pushes were
made; production remains on 3.14.

## Native-model constructor closure r245, 24 October 2026

The r224 model-to-pattern obligations now close through pointwise row and table
layout lemmas. The complete Native_Mass_Models unit closes 114 checks, specifying
constructor status and exact owned row metadata. Its four existing structural
warnings remain visible (two reassociation, two recursion/variant); there are no
open obligations, skips or assumptions. The factored independent pattern unit
closes 151 checks without warnings. These scope-specific counts are not added
to minimum-scope counts or treated as a whole-engine result.

[Local source, complete proof and regression evidence](evidence/20261024-native-model-closure-r245/README.md)
record the aggregate time limit, earlier failed attempts and exact dependencies.
Full reader/workspace composition, simulation binding, shared numeric-buffer
dynamics, full stable-version migration and integrated C performance parity
remain unfinished. No commits or pushes were made; production stays on 3.14.

## Local public native-mass reader r278

The derivative candidate now publishes and proves its disjoint current-mass
projection at the public Evaluate boundary: 30 checks (27 proof, three flow),
including caller preconditions, exact values, unused-slot zeros and size/error
behavior. The shared CRB branch is isolated with its numeric operation order
preserved; its complete proof remains open. Six helper scopes are independently
closed on the same frozen source. All seven scopes retain two inherited
structural recursion/variant warnings, so obligations_closed is true while
strict passed is false. This is not a whole Data.Native_Mass or workspace proof.

Both validation and release reconfirm 288 raw C3.17 mass states, 960 original
and 960 reordered derivative samples; C3.14 reconfirms 132 raw states and 960
samples. Each version/profile also passes four malformed-model and five output
shape scenarios. The 45 foundation library files remain byte-identical to r186.
Physical cache/model binding, shared-buffer dynamics, complete stable migration
and integrated C performance parity remain pending. No commit or push was made.

[Local source, all attempts, scoped proofs, gates and exact remaining scope](evidence/20261024-native-reader-disjoint-r278/README.md)

## Local shared CRB component r315

Composite_Assembly is reused by Inertia_Phase and the raw shared-mass reader.
Its exact ordered floating-point model and bounds close **479 checks (450 proof,
29 flow)** for the complete unit. Twelve operator/recursion/variant diagnostics
remain; obligations_closed=true and strict passed=false. No new trusted bodies,
assumptions or skips support this claim. The 329 Ada files of the final formal
snapshot match the final C3.17 runtime closure.

Both validation and release reconfirm the full C3.17/3.14 numerical suites, with
new 4096-body boundary and cancellation cases. Full shared-reader/workspace proof,
physical model/cache binding and stable engine/API migration remain open.

The new paired smooth-movement harness includes ball/free, tendons, applied forces
and body wrenches. It retains exact Ada-state comparison, C tolerances, all samples
and dispersion. Default-code regression on free, alignment experiments, mixed-model
outliers, and the remaining roughly 2x free / 3.9x chain gap to the C3.17 wheel are
recorded rather than accepted as completed parity. Wheel C flags are unknown;
matched-build performance acceptance remains pending. Global release flags are
unchanged and no commit or push was made.

[Local sources, complete proof, attempts, gates, timings and remaining scope](evidence/20261025-composite-assembly-r315/README.md)

## Local movement row-update investigation r324

[The r324 checkpoint](evidence/20261025-row-update-r324/README.md) records current
full-process solver sampling, two functionally proved row-update candidates,
strict boundary cases, C3.17/C3.14 numeric gates for the direct variant, and two
integrated timing sessions per candidate. Both candidates remain experimental:
chain gains coexist with repeatable small-model regressions. The active solver
was restored to its pre-experiment bytes; all prior migration work is preserved.
No commits, pushes, compiler-flag promotion, global Gold or C-parity claim.

## Local integer-bit row update r329

[The r329 checkpoint](evidence/20261025-bit-row-r329/README.md) retains the exact
row update with integer-bit rejection and closed minimum/whole-unit obligations,
including complete C3.17/C3.14 numerical gates. Integrated chain movement improves
about 9–10%, while tendon regressions remain explicit pending work. There is no
new SIMD in the updated loop and no final C performance acceptance.
[The separate r334 slice-view experiment](evidence/20261025-view-row-r334/README.md)
is not adopted: its two invariants remain open and its measured regressions are
retained. No commits, pushes, global compiler-flag changes or full-port claim.

## Local SIMD row and solver-caller closure r353

[The r353 checkpoint](evidence/20261025-vector-row-r353/README.md) contains actual
SIMD row code, its exact contract proofs, and the separately closed 86-obligation
solver-caller scope. The retained helper passes both-version numerical gates and
paired movement sessions, with residual small-model regressions explicit. Compiler
width preferences are not adopted; global flags remain unchanged. No commit or
push, whole-dynamics Gold, complete migration or C performance parity is claimed.

## Local four-value experiment r365

[The r365 checkpoint](evidence/20261025-four-row-r365/README.md) preserves the
unadopted four-value prototype, three closed helper minima, open full-row
invariants, strict numerical corpus and six integrated/control timing sessions.
The retained r349 kernel is unchanged; explicit warmup/filter controls improve
the diagnostic benchmark. No commit, push or performance-parity claim.

## Local direct compact CRB rows r380

[The r380 checkpoint](evidence/20261025-compact-row-r380/README.md) adds direct
C-style compact row construction and closes the complete Compact_Inertia unit:
367 obligations, with six existing warnings reported separately. Proved pure
lemmas close the earlier projection/expansion invariants. The row constructors
are not yet on the stepping path; canonical storage/cache, tendon/solver/inverse
and reader integration remain open. No commit, push or performance-parity claim.

## Local canonical compact mass r411

[The r411 checkpoint](evidence/20261025-canonical-mass-r411/README.md) connects
direct compact CRB construction, ordered tendon additions, cache publication,
solver loading, inverse multiplication and native/public/constrained readers on
the actual nv>=3 stepping path. Compatibility fallbacks and the strict diagnostic
boundary remain explicit. Complete new units close 100 and 117 obligations;
publication closes 20 without warnings. Five composed caller obligations and
broader functional model/dynamics proofs remain open.

Final-source C3.17/C3.14 gates pass in validation and release. Four integrated
sessions show consistent multi-DOF improvement, with the hinge sign change and
all earlier regressions retained. Chain24 remains roughly 3.2 times the C wheel
time; matched-build parity is unfinished. All 87 prior evidence entries are
preserved. No commits, staging or pushes; production remains pinned to 3.14.

## Local compact export and release LTO r430

[The r430 checkpoint](evidence/20261025-compact-callers-r430/README.md) closes the
public dense-output relation, strengthens exact expansion with a proved bound
and removes the strict boundary's second runtime traversal. Complete compact
inertia closes 377 checks with unchanged diagnostics; four examined caller
obligations and broader dynamics/model proofs remain open.

Both references pass ordinary and LTO numeric gates; default builders are
reconfirmed after release-only LTO adoption. Actual default integrated movement
improves about 8–9% on chain24 and 13–15% on branches24 versus non-LTO Ada, with
exact states. A pinned offline GCC16/AVX/LTO C3.17 build removes the wheel's
unknown-build ambiguity for those separate measurements; C remains substantially
faster. Eight new paired sessions and failed hypotheses remain auditable.
Full engine/API migration, functional proof composition and performance parity
are unfinished. Production remains C3.14; no commits, staging or pushes.

## Local tendon caller proof r441

[The r441 checkpoint](evidence/20261025-tendon-caller-r441/README.md) closes the
actual compact tendon accumulation precondition through an existing proved
layout predicate kept abstract across disjoint writes. The caller closes 21
checks with unchanged diagnostics; two of its obligations and the Solve post
remain open. Rejected private diagnostics and the corrected source-scope audit
are retained. This is proof-context progress, with no runtime formula/domain,
build policy or performance-acceptance change. No commits, staging or pushes.

## Local rejected SIMD threshold r450

[The r450 checkpoint](evidence/20261025-row-eight-r450/README.md) preserves the
functionally proved eight-value dispatch experiment and its complete numeric
row corpus. Integrated chain/branch regressions in two balanced sessions prevent
adoption; the working threshold remains 16 with LTO. No new full-port, whole
proof or C-parity claim, and no commits, staging or pushes.

## Local release-only kernel width r455

The derivative candidate now prefers 256-bit SIMD for Solver_Kernels in release,
with unchanged checked Ada source/contracts, threshold 16 and validation profile.
Two-reference numerical gates, exact row cases, cache/Euler and direct compact
constructors pass; actual default GPR/builders and two full movement sessions
are independently reconfirmed. Ball and fixed-tendon gains persist, chain24 has
one inconclusive interval, and branches24 remains inconclusive. This is native
target evidence, not full C3.17 migration, dynamics Gold or performance parity.
Three examined caller obligations and wider port/proof gaps remain open.

[Durable evidence, all raw timings, scope and preparation-script correction](evidence/20261025-width256-r455/README.md).
All 107 previous inventory entries are preserved;112 are now verified. No
commits, staging, pushes or remote writes; HEAD remains 398c2dde.

## Local Cross bound diagnostics r467

The actual LTO/256-bit build is profiled and two private Cross code-generation
variants are evaluated. Replacing six redundant runtime subtype restrictions
by proved Static facts closes all 86 Cross checks and all 796 Smooth_Math
checks, with diagnostics kept separate. Both exact-bit profiles pass 5,972
C-reference cases. Automatic inlining improves chain24 but regresses fixed
tendons; No_Inline recovers fixed tendons while losing the multi-DOF benefit.
Neither is adopted, so working Ada remains r455 and C parity remains pending.
The archived full two-reference promotion script is explicitly unexecuted.

[Proof scope, raw samples/intervals, exact-bit/runtime correction and sources](evidence/20261025-cross-bounds-r467/README.md).
All 112 preceding inventory entries are preserved; 117 are verified now. No
commits, staging, pushes or remote writes; HEAD remains 398c2dde.

## Local commit packaging and exact archive storage

The checked code and historical checkpoints above are grouped with a lossless
store for the twenty new ZIP bundles. Original ZIP bytes and all 117 inventory
hashes are preserved; payload files are at most 32 MiB and are verified offline.
Historical sections retain the HEAD and local-only status recorded at capture
time. Their scoped proof results and pending dynamics/performance limitations
are unchanged by packaging. No remote push accompanies this local commit.

[Storage audit, exact verification/restoration and append workflow](../../docs/storage-and-evidence.md).

## Generic row diagnostics after the published checkpoint

Three private row variants close their scoped functional proof obligations and
pass numerical checks, but integrated movement measurements show regressions.
None is adopted; the active kernel remains r455. A new dedicated corpus covers
Add_Row and Scale_Row directly, including every rejected SIMD lane, signed-zero
bits and maximum origins: 137,754 cases per profile on the retained baseline
and each private variant. The prior disjoint-row corpus remains separate.

[Proof scope, rejected variants, raw measurements and regression corpus](evidence/20261025-row-reductions-r480/README.md).
The complete port, dynamics proofs and C performance parity remain pending.

## Vector Scale_Row and replica uncertainty

Scale_Row now uses a separate 256-bit SIMD multiplication routine and integer
rejection flags, preserving its full domain and exact functional contracts.
The minimum/unit scopes close 19/156 checks; C3.17/C3.14 and boundary suites pass.
The normal shared-builder binaries match the private experiment exactly.

Replication contradicts the initial 8% single-joint gain: exact-SHA copies show
substantial timing differences. A new multiple-copy comparison with randomized
creation and replica/block uncertainty confirms about 1.9–2.1% less chain24 time.
Many other cases remain inconclusive; observed regressions are preserved too.
The chain still takes about 2.3 times C's time. Dummy inverse filling remains.

[Proofs, numerical checks, timing qualification and complete data](evidence/20261025-vector-scale-r503/README.md).
No complete-port, whole dynamics Gold or overall performance-parity claim.

## Direct reduction work in progress

The local-accumulator-only prototype closes its 173-check minimum but leaves the
successful-path machine code unchanged. A direct-product/addition prototype
produces a four-lane YMM block and passes an extended 36,079-case corpus in both
profiles, including exact rejection counts. Its changed-loop proof is still
unfinished; it is not adopted and has no integrated performance claim.

[Source, proof/timeout scope, assembly and retained regression corpus](evidence/20261025-direct-dot-r525/README.md).
The verified r503 vector Scale_Row remains the working implementation.


## Closed direct-block minimum and integrated timing qualification

The direct-block minimum now closes 197 checks and the refactored ghost
small-row lemma closes 53. Seven inherited model diagnostics remain separate.
The first whole-unit attempt reaches its watchdog without a completed report;
full dynamics Gold remains pending. All 13 two-reference numerical groups and
the 36,079-case reduction corpus per profile pass.

Thirty three-copy and fifteen six-copy movement scenarios do not confirm a
multi-DOF improvement. The repeated chain still takes about 2.35-2.40 times C's
time. Hinge gains and workload-specific uncertainty/regressions are retained;
the direct runtime is not adopted. A further fused compiler-boundary trial is
private and its immutable inputs are preserved separately from active jobs.

[Closed scopes, unresolved whole proof, exact raw measurements and sources](evidence/20261025-direct-dot-contracts-r556/README.md).
The active runtime remains the published vector Scale_Row implementation.


## Adopted reduction proof closure and qualified native sampling

The actual reduction unit closes all 837 checks (748 proof, 89 flow) separately
on the exact production C3.14 and candidate C3.17 closures, with 20 existing
warnings separate. The full original runtime contracts/domains are preserved;
the tail model additionally proves its per-tail bound. Four exact reduction
corpora and all 30 actual movement endpoints pass. The normal compiled program
changes only eight exception source-line immediates, with unchanged data and
successful-path instructions. This is proof progress, not a runtime speedup.

A calibrated independent CPU-timer sampler replaces invalid gprofng measurements.
On chain24 state0, the largest flat Ada sample shares are compatible factor/solve
(about 26%), acceleration preparation (16%) and compact mass construction (10%);
the dot product is about 5%. Raw instruction PCs identify scalar short-row
updates in the factorization. The resulting threshold-eight trial is documented
in the following checkpoint.

[Completed proof/code/numeric bindings, qualified profiles and scope](evidence/20261025-reduction-closure-r605/README.md).
Whole dynamics Gold, full port and overall C parity remain pending.

## Adopted threshold-eight row updates

The existing disjoint-row vector backend now starts at eight elements instead
of sixteen. Both reference closures close all 156 kernel-unit checks, retaining
five existing diagnostics each. The 14,905-case disjoint corpus per profile and
all 13 broader numerical groups pass. Fresh working-source snapshots match the
verified builds exactly; public contracts, arithmetic and domains are unchanged.

The full 30-case movement run and independent chain24 repeat use six identical
binary copies per role. Chain24 time falls by about 1.2-1.8%, with all six state/run
confidence intervals below parity. Other workload intervals include no change;
individual results and uncertainty remain available. Chain24 still takes about
2.3 times normal native C3.17, so this does not establish overall C parity.
The first timing attempt is explicitly disqualified because an earlier own Git
scan was still active. Accepted runs have no overlapping own heavy jobs.

The compiled text differs in exactly one byte: the dispatch threshold immediate.
Read-only and writable data match. The C3.14 proof-launcher helper-path error and
its correction are retained without rerunning completed numerical work.

A further private Cross candidate closes 86 minimum and 796 whole-unit checks,
with its existing diagnostics separate, and passes 5,972 bitwise C cases per
profile. Its compiled movement comparison is prepared; integrated performance
and broader integration acceptance remain pending. The working Cross is unchanged.

[Verified source bindings, proofs, raw timings and private Cross inputs](evidence/20261025-row-threshold-r620/README.md).
These changes remain local after commit `6e98c9bc4`; no new push is performed.

## Private Cross: replicated movement improvement

The minimum and complete C3.17 math proof close 86/796 checks, with existing
diagnostics separate. All 5,972 bitwise C cases pass in each profile. A nine-case
six-copy movement run and a complete 30-case six-copy run confirm improvements
on chain24 and branches24. The full-run time ratios against the threshold-eight
baseline are about 0.913-0.919 and 0.947-0.954 respectively. Chain24 remains about
2.09-2.10 times normal native C3.17; branches24 about 1.59 times C.

The initial full attempt is retained as incomplete: it was explicitly interrupted
when the host volume reached about 65 MiB free. Accepted timing restarted only
after cleanup, with unchanged executable hashes and no overlapping heavy task
work. Sources, proof receipts and exact stored bytes remain intact; only backed
generated caches and ignored raw ZIP duplicates were removed.

The working Cross is unchanged. Two-reference validation/release integration and
the independent complete C3.14 math proof are running in r625. This is performance
evidence for a private candidate, not adoption, full dynamics Gold or overall C
parity. The missing standalone Cross symbol reflects inlining, not absent work.

[Full raw timing, source/proof dependencies and qualified scope](evidence/20261026-cross-performance-r630/README.md).
[Exact cleanup and retained bytes](evidence/20261026-exact-zip-cleanup-r629/README.md).

## Adopted Cross after complete integration

The actual working Cross now matches the r630 candidate. Complete math-unit
proofs close 796 checks independently on production C3.14 and candidate C3.17,
with 66 existing diagnostics each. All 13 numerical groups pass, and fresh actual
source manifests match both verified builds exactly. Six intermediate subtype
checks become proved Static bounds; arithmetic, original public domain and full
postconditions remain unchanged. No new assumption, suppression, trusted body,
forced inline or deallocator change is introduced.

The confirmed chain24/branches24 improvements remain workload-specific; normal
C3.17 is still about 2.1/1.59 times faster respectively. Earlier kernel/reduction
proofs keep their unchanged called contracts and are not rerun. Full dynamics
Gold, coordinated production migration, full port and overall C parity remain open.

A subsequent checked spatial-load slice candidate closes both 12-check minima
and its entire 84-check unit without warnings. Its exact component/frame contracts
are retained. Both profiles also pass 4,360 exact-bit boundary cases, including
nonzero and near-NaturalLast origins. The normal movement build is ready and a
six-copy multi-DOF comparison has completed in r639. Chain24 and branches24
confidence intervals include no change, so this storage candidate remains
private; working storage is unchanged.

[Actual source bindings, two-reference proof/integration and private storage inputs](evidence/20261026-cross-adoption-r632/README.md).
The earlier local-only statements above describe those checkpoints at creation.
The user has now requested publication of the adopted changes and their evidence.

## Expanded row boundaries and current diagnostic profile

The actual adopted runtime passes 59,621 disjoint-row cases in each validation
and release profile, including origins and lengths around 65,535/65,536 and
origins near Natural'Last. Large validation snapshots require a 64 MiB stack
in the test child only; the original stack failure and same-binary diagnosis
are preserved. The executed runner and frozen source closure have explicit
hash bindings. Public runtime domains and contracts are unchanged.

A fresh qualified chain24 profile identifies acceleration preparation,
factor/solve, row updates and compact mass as remaining diagnostic priorities.
Flat sample shares do not establish causal savings. Private row-index variants
and storage slices are not adopted or presented as completed optimizations.

[Boundary corpus, source bindings, raw profile and storage comparison](evidence/20261026-row-boundaries-and-profile/README.md).
Full port, whole dynamics Gold, coordinated production migration and C parity
remain unfinished.

## Private compact-row proof closure and timing rejection

A compact-metadata row prototype closes its 89-check helper minimum and
44-check dispatcher. Its entire kernel unit closes 249 checks on the C3.17
closure, with the five inherited diagnostics separate. Full original contracts,
rounded arithmetic, rejection/frame properties and generic fallback remain.
Both profiles pass 59,621 boundary cases. No production owner is changed.

The nine-scenario six-copy movement comparison nevertheless shows a 7-8%
chain24 regression, so this prototype is rejected. Its smaller SIMD helper
uses scalar execution for lengths 8..15. A second dispatch variant retains the
current backend for those lengths. The marked regression disappears, but all
nine confidence intervals include no change: no accepted speedup or adoption.
The second dispatcher is proved; a fresh whole-unit/C3.14 integration proof is
not claimed for it. Earlier completed proof scopes remain explicitly distinct.

Instruction windows from the accepted runtime's existing profile point to
geometry and projection checks within external-force accumulation for the next
investigation. These flat sample shares are not causal savings. The current
compatible solve path has no dummy dense inverse construction.

[Frozen variants, 249-check proof, full boundary corpora and both raw movement comparisons](evidence/20261026-compact-row-r722/README.md).
At that checkpoint the runtime still matched `ef66b666a`; the subsequent
external-load adoption below changes two files. Full port, whole dynamics Gold,
coordinated migration and C parity remain unfinished.

## Adopted explicit scalar domains for external loads

The working external-force Contribution uses base Real scalars and equivalent
explicit original input/output range contracts. Its exact ordered formula and
the caller's final numeric rejection remain. Declarations change; fresh full
callee and caller proofs close 58 and 42 checks independently on C3.14 and
C3.17, without warnings. Fresh actual source manifests exactly match the
verified builds/proof inputs. All 13 numerical groups and 6,680 exact bit cases
per profile pass. There is no assumption, suppression or new trusted body.

Nine targeted cases, an independent three-state chain24 repeat and all 30
supported movement scenarios use six identical binary replicas per role with
normal native C3.17 SIMD/LTO. Chain24 takes about 1.4-2.1% less time in all nine
state/run estimates, each with its interval below one. Other workload uncertainty
remains explicit; no slowdown is statistically confirmed, and many intervals
include no change. No unweighted aggregate or every-case speedup is claimed.

These measurements include body-applied external loads; they do not establish
a benefit when Contribution is not called. Full-run chain24 remains about
2.07-2.08 times C's time. The old row prototypes above remain unadopted; only
the two external-force math files change the runtime in this checkpoint.

[Actual bindings, both complete unit proofs, all numerical groups and raw timing](evidence/20261026-external-domain-r750/README.md).
The adopted external-load code and these evidence checkpoints are published at
the user's request. Statements of local-only status inside frozen receipts
describe their creation time. Private solver-row experiments remain separate.
Full port, whole dynamics Gold, coordinated production migration and C parity
remain unfinished.

## Adopted checked zero-origin row windows

The packed-row update now uses ordinary checked single-array parameter sliding
to a zero-origin view. Full generic origins/counts, ordered floating arithmetic,
numeric rejection and untouched frame remain. Equivalent explicit scalar ranges
also cover the complete coefficient chain, including the solver's local value.
No unchecked pointer, copy, suppression or assumption is introduced.

Fresh actual C3.14/C3.17 source closures each close 222 checks of the complete
kernel and 86 checks of the direct Solve_Compatible_Buffers minimum. The latter
does not prove the entire inertia-phase unit or global factorization relation.
Four kernel and twelve caller inherited warnings remain. The old fifth kernel
warning disappears with its rewritten index expression; the exact diagnostic
delta and an original gate's obsolete warning-count failure are preserved.
All 14 numerical groups, 6,140 scalar bit cases and 59,621 row cases per profile
pass. Actual working manifests exactly match the verified sources.

Nine targeted scenarios, an independent three-state repeat and all 30 supported
movement scenarios use six identical replicas per role and normal native C3.17
SIMD/LTO. All nine chain24 state/run estimates take about 1.7-2.6% less time
than the adopted external-load baseline, each interval below one. No slowdown
is statistically confirmed; many other intervals include no change. Full-run
chain24 remains about 2.01-2.04 times C's time. Applied body loads are present;
there is no independently measured body-load-free or aggregate parity claim.
The final timed helper retains YMM arithmetic and removes widened vector indices.

[Exact source bindings, both proof scopes, all corpora and raw timing](evidence/20261026-row-window-r790/README.md).
This adoption is included in the publication requested on 2026-10-26. Frozen
receipts retain their original local-only status at creation time. Full port,
whole dynamics Gold, coordinated production migration and overall C parity
remain unfinished.

A fresh qualified profile of the actual adopted binary places packed factor/solve
(17.02%), acceleration preparation (16.70%) and long-row updates (11.38%) first.
These are flat sample shares for chain24 state0, including setup/output and
sampling overhead; they do not identify causal savings or replace acceptance
timing. [Complete raw profile and collection scope](evidence/20261026-row-window-profile-r792/README.md).

## Private predicate experiment and parent-data proof debt

A private symmetric range predicate proves its exact equivalence to the old
interval test in three minimum checks. Fresh C3.17 caller minima (12 and 86),
the application minimum (30) and complete external-load unit (42) close. Its
nine-scenario comparison is promising, with uncertainty in some cases; an
independent repeat, full 30 scenarios, boundaries and both-reference gates remain
pending. This predicate is not adopted.

A full parent Data audit on the C3.17 closure reproduces three flow errors in
both the adopted baseline and predicate candidate: two initialization reports
for Arms and one mutable-owner rename in Initialize. They are unfinished proof
engineering, not a Silver mathematical exception or a completed parent-unit proof.
Separate constructor repairs remain private and are diagnosed at their minima.
The original 2.5 GB Initialize attempt exhausted its memory cap without a proof.

[Exact baseline controls, private inputs, proof scopes and raw timing](evidence/20261026-predicate-and-data-audit-r808/README.md).

## Private constructor proof decomposition

The manifold-topology builder now has a private array-based prototype with exact
armature, fixed/simple inertia, parent/body/joint and effective-parent maps. Its
86 semantic proof/flow checks close. Source/configuration arrays are read-only;
only the two owned caches are mutable. Empty array lengths are supported without
requiring a canonical null upper bound. Whole subtree-mass equivalence remains
outside this claim.

Private activation setup closes 93 checks for one actuator, including exact copied
muscle fields, base-field preservation, scalar counter/flag behavior and rejected
entry preservation. Its traversal closes 31 checks; its mapping predicate closes
49. Layout and supported-kind ghost lemmas close 5 and 18 checks. Inherited
diagnostics remain separate from proof closure. Counts exclude informational
compiler unrolling messages, which inflated some earlier raw counters.

A fresh baseline control reproduces an open Model_Status postcondition. A proved
geometry-layout bridge now exports a conjunct of the existing full-layout check;
Model_Status closes 19 checks. Creation-input decomposition is also proved.
Existing activation/mocap capacity facts are propagated to private callers;
no new public model filter or runtime validation scan is introduced. Complete
Initialize and whole Data verification remain pending.

Both the adopted baseline and a private C3.17 constructor candidate pass 432
activation scenarios plus 1,152 combined joint/muscle/tendon/body-load scenarios
under validation flags. Existing tolerances are unchanged. The exact tested
snapshot is distinct from later proof-only changes; current-source, release and
C3.14 qualification remain required before adoption. This is not performance
evidence or coordinated production migration.

[Frozen repairs, failed attempts, explicit proof scopes and numerical controls](evidence/20261026-constructor-proof-r860/README.md).
Constructor changes remain private. That checkpoint records the row-window
baseline; the subsequent solver adoption is described below. Full port, whole
dynamics Gold and overall C parity remain open.


## Adopted equivalent solver row-domain predicate

All four existing solver-row rejection reductions now use an abs-based test
proved exactly equivalent to the previous symmetric interval membership. Full
admitted domains, ordered floating arithmetic, rejection behavior and frames
remain. Integer reductions and existing compiler policies are retained; the
final version adds no forced-inlining directive. Constructor prototypes and the
separate parent-Data predicate experiment are not included in this adoption.

Fresh actual C3.14/C3.17 closures each close 225 complete-kernel checks and 86
checks of the direct Solve_Compatible_Buffers minimum. Four kernel and twelve
caller inherited warnings match their baselines. This does not establish the
whole inertia-phase unit or the global factorization theorem. All 14 numerical
groups pass, including 6,140 exact native-C scalar bit cases and 59,621 row cases
per validation/release profile. Actual source manifests match verified inputs.

Targeted nine-scenario, independent nine-scenario repeat and full 30-scenario supported movement scenarios use six
identical replicas per role and normal native C3.17 SIMD/LTO. All chain24
state/run intervals support about 4.3-5.0% less time than published c10895298.
The full run takes about 4.6-4.7% less on chain24, 5.0-5.5% less on free_ball and
2.3-2.9% less on branches24. No slowdown is statistically confirmed; two full-run
intervals include no change. There is no aggregate percentage-speedup claim.
Chain24 still takes about 1.93-1.94 times C, free_ball 1.64-1.66 and branches24 1.54.
Applied body loads are present; body-load-free timing is not established.

[Exact sources, both-reference proofs, numerical corpora and raw timing](evidence/20261026-row-domain-r894/README.md).
This adoption follows c10895298. Full port, whole dynamics Gold,
coordinated production migration and overall C parity remain unfinished.


A subsequent private constructor minimum closes 91 semantic checks with seven
obligations still open. Body-frame initialization and preservation are proved;
reference/coefficient reads and contract checks remain explicit. Prepared length
comparisons use Int64 to avoid implicit Natural conversions without changing
admitted inputs. This constructor remains unadopted; the prepared source has no
fresh proof or numerical qualification yet.
[Exact completed report and prepared source](evidence/20261026-constructor-followup-r908/README.md).


## Private constructor closure and inconclusive force-sum experiment

A body-span leaf closes 36 checks on C3.17 and C3.14, proving the exact ordered
first-rejection prefix map and preservation of every other body field. A static
creation-input bridge closes two; Model_Status then closes 21 on each reference.
The latest examined constructor minimum still has two open obligations: remapper
precondition and parent postcondition. These are minimum scopes, not whole Data
or Initialize verification, and inherited diagnostics remain explicit.

Both actual baseline and constructor935/940 pass 432 activation plus 1,152
joint/muscle/tendon/body-load scenarios per validation/release profile and per
reference (C3.17/C3.14). Later static variants remain separate and require fresh
exact-source qualification before adoption. The private whole-Data flow audit
has no unresolved diagnostics versus three in the actual baseline, with the same
five reviewed spec-only deallocators and unchanged warning multiset. This flow
result does not establish runtime safety or functional Gold of the full unit.

A private Total_Force change removes implicit subtype checks through equivalent
explicit input/output contracts. The function and direct caller close 11/28
checks; both roles/profiles match 6,540 exact native-C operation-sequence bit
cases. Two independent nine-scenario, six-replica movement runs do not confirm a
reproducible integrated gain, so the change is not adopted. Static instruction
reductions alone do not justify a performance claim. Both whole math proof
controls time out at 600 seconds without a complete report; broader unexecuted
gate recipes are not verification evidence.

[Frozen sources, successful and failed attempts, both-reference numerical controls,
raw timing and exact scope](evidence/20261026-constructor-and-force-r967/README.md).
The runtime remains row-domain893. Constructor changes stay private. Full port,
whole dynamics Gold, coordinated migration and overall C parity remain open.


## Private manifold minimum closure and caller recovery

Copy_Manifold_Joints now closes all97 semantic checks on the exact private
C3.17 and C3.14 closures. The previously unresolved remapper precondition and
parent postcondition close with increased prover resources on unchanged source.
The C3.14 wrapper closes8 and Model_Status21 on that same closure. Inherited
warnings remain explicit; these minima are not whole Data/Initialize proof.
The selected Initialize prefix1659..1680 then proves the manifold-call
precondition and body-pointer safety, retaining one Fluid_Phase.Initialize
precondition timeout. Counts of selected proof checks and unit flow information
are recorded separately.

Several minimal Data flow repairs pass both-reference/both-profile activation432
and integration1152 numerical scenarios but remain unadopted after movement
controls. Copied-record971 has repeated hinge regressions; aligned985 has no
demonstrated benefit; cold1010 passes hinge triage but regresses other full-run
workloads. Direct-owned-element1023 removes the invalid mutable rename without
a temporary record; its first full30 run finds roughly1.1-1.3% hinge slowdown,
while its independent repeat is inconclusive. Wider intervals do not demonstrate
a win. No overall percentage-speedup or C-parity claim follows.

The later1049 initialization candidate omits the explicit zero initializer
and expresses partial initialization through an Initialized invariant/assertion.
FLOW and C3.14/C3.17 numerical controls pass, but the frozen recovery checkpoint
explicitly leaves the required initialization and consuming-read proofs pending:
those initial runs were interrupted without final reports. Their partial Why3
sessions are preserved. New proof work must close those properties before any
adoption; FLOW alone does not suffice. No runtime source is adopted here.

[First closed manifold minimum, rejected variants and exact raw controls](evidence/20261026-flowfix-and-manifold-r1035/README.md).
[Same-source C3.14 closure, selected caller diagnosis and interrupted-proof recovery](evidence/20261026-manifold-caller-recovery-r1062/README.md).
Full port, whole dynamics Gold, coordinated migration and overall C parity
remain unfinished; the runtime remains the published893 solver implementation.


Subsequent actual Build_Manifold_Topology minima1061/1064 on1049 close the five
initialization properties on both references: initialized-prefix invariant
initialization/preservation, final whole-array assertion and initialization at
both actual consuming calls. The whole minimum remains unproved: configuration
buffer index checks at964/972 and the subtree-mass precondition at967 remain.
The array-initialization precision warning for the mass loop and inherited
warnings stay explicit. The scoped review is preserved in1069; it does not turn
these three open obligations into a whole-unit success or authorize a broader
functional claim. Constructor1049 is still private and not performance-qualified.

The force-window1076 experiment closes the sequence model, constrained loop,
wrapper and buffer minima on both references, with numerical controls passing.
Its targeted nine-case movement comparison finds no demonstrated reproducible
multi-DOF gain, so it remains unadopted. The checkpoint preserves failed attempts,
exact source bindings, proof reports and raw measurements separately.
[Scoped initialization closure and force-window results](evidence/20261026-force-windows-and-init-r1102/README.md).

The later private1109 force-slice candidate closes scalar11, sequence20 and
buffer65 semantic checks per reference, plus whole inertia FLOW. Its actual
Fill_Total buffer call Pre is proved, while three broader frame/configuration/
readiness obligations remain open. Numerical controls pass on both references
and profiles; targeted nine-case movement finds no demonstrated reproducible
integrated gain, so this candidate is also unadopted. A refreshed chain24 PC
profile is descriptive and includes setup/output costs, not exact phase times.
[Exact force-slice proof scopes, raw timing and refreshed profile](evidence/20261026-force-slices-profile-r1131/README.md).

The private1127 Jacobian candidate proves that Angular bounds and slide-branch
Linear bounds follow from the original direction Pre; the computed hinge Linear
check remains. Both references close Column15, whole Jacobians115 and whole
External_Loads42 independently, with two explicit unchanged-spec integer warnings.
Both-profile numerical controls and6576 native-C boundary-bit cases pass. The
targeted nine-case run and independent three-state chain24 repeat do not establish
a reproducible integrated gain, so the candidate stays unadopted. Full topology
functional refinement and complete dynamics Gold remain separate open work.
[Exact Jacobian proof scopes, failed attempts and both movement runs](evidence/20261026-jacobian-bound-elision-r1149/README.md).

## Latest local runtime: proved spatial Dot product bounds, 26 October 2026

The1171 adoption changes only Spatial_Kernels.Dot intermediate products to base
Real constants, retaining their former subtype limits as proved Static facts.
Original API/Pre/Post, complete admitted domains and the C mji_dot6 FP tree remain.
Both references close the full spatial math459 and compact inertia377 obligations,
plus the Dot39, Projected9 and Assemble_Row37 minima independently. Six inherited
compact warnings remain explicit. Counts are not additive. All13 broader numeric
groups, both-profile activation/integration suites and6720 native-C bit cases per
role/profile pass. No new inline policy, assumption or suppression is introduced.

Targeted9, independent chain3 and full30 supported movement scenarios use six
replicas and normal native C3.17. All nine chain24 state/run intervals are below
parity with the previous runtime: about1.4-2.2% less time. Full-run chain24 still
takes about1.90-1.91 times C's time. Other models retain their uncertainty; no
aggregate speedup or absence-of-regressions guarantee follows from wide intervals.
Fresh actual C14/C17 manifests exactly match all verified inputs. The893 solver
stays in place; Jacobian and force-slice experiments remain unadopted. Complete
port, dynamics Gold, migration and overall C parity are still open.
[Exact adoption, all proof budgets, numerical controls and raw timings](evidence/20261026-spatial-dot-adoption-r1172/README.md).

The subsequent private1173 component-contract candidate closes full math388 on
both references and passes6864 native-C inertia-vector bit cases per role/profile.
Its initial movement gains on free_ball/chain24 accompany hinge regressions, so
it is unadopted. An ordinary No_Inline(Fill) control retains multi-DOF gains but
does not establish elimination of the hinge slowdown. Its C17 Fill51 proof and
source bridge are explicit; no fresh whole-unit source equality is inferred from
an unchanged mathematical subunit. Neither control has a repeat or full30 run.
[Mixed performance, exact proof scopes and corrected symbol-count diagnostic](evidence/20261026-inertia-component-controls-r1210/README.md).

## Latest local runtime: Direct inertia products in compact mass and RNE, 27 October 2026

The1294 adoption adds a Direct child with the exact parent Multiply as its
functional model. Former scalar subtype bounds become proved Static facts. The
existing compact row caller uses it, and RNE uses it for both inertia products in
actual C3.17 mj_rne order. Parent math specifications/bodies, complete admitted
input domains, rejection checks and zeros, dense small-model mass route and the
existing Nv<3 selection remain. No new size threshold, forced inline, assumption
or suppression is added. Only four runtime owners change.

Both references close Multiply35, whole Direct122, whole Compact501 and final
Try_Body_Force30/whole RNE163. Separate congruence minima15/78/16 explain the RNE
composition; counts are not additive. Six inherited compact warnings are reviewed
against matching rules, columns and source statements. A900s compact attempt is
preserved as incomplete; incremental continuation on identical sources validates
cached tasks and produces the complete501-check report. The unrelated final RNE
body delta preserves all eight/eighteen source inputs of Direct/Compact dependency
closures, explicitly recorded for proof reuse. This does not claim equal full
project manifests across that delta. Fresh actual C14/C17 snapshots match final
1274 completely, with entry-order normalization after every digest is checked.

Both full13-group numerical qualifications, activation432/integration1152 per
reference/profile, and native exact-bit controls6864 inertia-vector/6794 RNE body
cases per role/profile pass. Both RNE rejection branches remain covered. C's test
wrapper mirrors the Ada rejection policy for comparison; C itself has no such
rejection. Numerical cases do not establish universal C equivalence or ideal-real
accuracy, and these unit proofs do not close whole dynamics/state/memory Gold.

Four six-replica runs retain all raw supported movement timings: compact target9,
RNE target9, combined full30 and an independent combined target9. Compact alone
has no demonstrated reproducible gain; RNE's chain target improves0.9-2.0% with
all three intervals below1. Combined full-run chain medians improve1.4-1.9% but
intervals include1. The independent repeat improves chain2.5-2.8% and free_ball
3.2-3.6%, every interval below1. Other models retain their uncertainty; no average
of percentages or absence-of-regressions guarantee is inferred. Median chain
still takes1.85-1.88 times C and free_ball1.53-1.56; hinge remains about2.2-3.3%
slower than C. Full port, migration, dynamics Gold and overall C parity remain open.

[Earlier private controls, failed obligations and host-interrupted attempts](evidence/20261027-inertia-projection-controls-r1295/README.md).
[Actual adoption, exact proof scopes/source bridges and all raw comparisons](evidence/20261027-compact-rne-adoption-r1296/README.md).

## Latest local runtime: proved Add_Row operand bounds, 27 October 2026

The1319 adoption changes only Solver_Kernels.Add_Row from actual1294. The runtime
checked Add_Product call becomes the identical base-Real expression; former input
and result subtype limits remain proved Static facts. Public API/Pre/Post, all
admitted origins/null shapes, FP order, complete-row rejection and the existing
integer reduction/compiler workaround remain. No threshold, forced inline,
assumption, suppression or unchecked view is added.

Both references close Add_Row37, complete solver kernels231 and the actual solver
CALLER MINIMUM86; C17 Add_Prefix_Row14 also closes. Four/twelve inherited warnings
match prior diagnostics and identical statements. Counts are not additive, and the
caller scope does not prove global factorization equations or the full inertia
phase. All14 numerical groups, both-profile/reference activation432/integration1152,
66306 checked/release row cases per profile and7374 native exact-bit row cases per
baseline/candidate/profile pass. Fresh actual C14/C17 source contents match all
qualified inputs. Prior Direct122/Compact501/RNE163 proof reuse has explicit
unchanged eight/eighteen/twelve-source dependency closures; full project manifests
across the unrelated solver-body delta are not mislabeled identical.

Target9, independent repeat9 and full30 use six replicas and normal native C3.17.
All nine chain24 state/run intervals are below1:1.6-1.8% lower targeted/repeat time,
1.3-1.5% lower full-run time. Full30 shows ball1.6-1.8% slower with intervals above1;
a dedicated ball/spatial_ball followup6 has ball medians near unchanged and wide
intervals including1. Both results are retained; no absence-of-regressions guarantee
or percentage average follows. Full-run chain still takes about1.82 times C and
ball remains about1.24-1.26 times C. Complete port/migration, full dynamics Gold,
global factorization functional correctness and overall C parity remain open.

[Current PC profile, exact endpoint checks and opcode evidence](evidence/20261027-current-pc-profile-r1314/README.md).
[Actual row adoption, all proof/numeric scopes and regression followup](evidence/20261027-row-input-bound-adoption-r1321/README.md).

## Row reduction rejected; vectorized sliding remains private

The1323 modular rejection-OR control closes both-reference Add_Row37, complete
kernel231 and solver caller MINIMUM86, with all14 numerical groups passing. Its
six-replica target9 movement comparison nevertheless makes hinge about3% slower
and free_ball3.0-3.5% slower, with all six intervals above1. Chain establishes no
compensating gain. The control is rejected; runtime remains commit389ecb827.

A separate ordinary checked parameter-sliding helper preserves the public full
array domains and original inline policy. Its1348 executable generates vector
adds where baseline has none, and the1354 full-slice successor passes7374 native
exact-bit cases per standard profile. The1348 nested scalar minimum closes30, but
the original-origin acceptance/component bridge remains open. Available failed
flow/build controls and unproved assertions are retained; neither SIMD codegen
nor a post proved under unproved assertions establishes functional completion or
speedup. Full-unit successor proofs and movement qualification remain pending.
[Exact controls, regression decision and open origin-bridge proof scopes](evidence/20261027-row-reduction-and-sliding-controls-r1360/README.md).

## Checked sliding proved; movement adoption deferred

The1384 successor closes the original-origin bridge with a Static ghost expected
row and a separately proved array-domain congruence lemma. Both references close
public wrapper11, private sliding caller28, work lemma16 and the complete kernel282;
the actual inertia solver caller MINIMUM86 closes too. Counts are not additive,
and global factorization/state/dynamics proofs remain open. All14 numerical groups,
both-reference/profile integration,66306 row cases/profile and7374 exact native
row-bit cases per candidate profile pass. Original public domains, FP order,
rejection/frame behavior and existing inline policy remain.

Final code generation contains vector adds, but six-replica target9 measurements
show hinge4.3-4.6% slower with intervals above1. Free_ball median gains0.9-1.3% have
intervals including1; chain gains0.2-0.6% have two intervals below1 and one including1.
This does not establish sufficient integrated benefit to adopt the regression.
Runtime therefore remains389ecb827; no repeat/full30 acceptance or percentage
average is claimed. A future row-envelope theorem remains open, and the checked
local-view renaming probe is not writable Ada. Neither is trusted or adopted.
[Complete proof scopes, raw mixed timings and retained unsuccessful controls](evidence/20261027-proved-sliding-controls-r1420/README.md).

## Non-nested row compiler controls: no runtime adoption

Ordinary inline hints alone retain the row call. A non-nested flat helper with
ordinary checked subtype conversions in inout actuals and a proved equal-bound
shape guard eliminates that call while retaining native caller SIMD. All final
origin/acceptance assertions close: both references prove caller31, wrapper11,
complete kernels284 and inertia solver CALLER MINIMUM86, with reviewed inherited
warnings. All14 numerical groups, both-reference/profile integration,66306 row
cases/profile and7374 native exact-bit cases/profile pass. Public domains, ordered
FP arithmetic, complete-row rejection and existing forced-inline policy remain.

Six-replica target9 nevertheless shows hinge2.6-2.9% slower with intervals above1;
free_ball slowdown medians1.0-2.3% have intervals including1. Chain gains0.6-1.0%
have two intervals below1 and one including1. The control is not adopted; no
repeat/full30 acceptance, percentage average or causal call/width/layout cost
claim follows. Actual runtime remains389ecb827. Whole dynamics/state Gold, global
factorization equations, full port/latest migration and C parity remain open.
[Compiler decisions, exact current-source proof scopes and all mixed timings](evidence/20261027-flat-row-compiler-controls-r1478/README.md).

## External-load domain predicate: proved control, not adopted

The isolated1464 candidate proves the final absolute-value comparison equivalent
to the original range predicate, retaining its genuine rejection and all input
domains. Both references close scalar13 and whole External_Loads43 without
warnings. Both-reference/profile activation and integration plus all12 numerical
groups pass; higher whole-state/dynamics proofs remain separate and open.

Target9, independent repeat9, full30 and a dedicated hinge/free followup6 retain
six identical executable replicas each and normal native C3.17 SIMD/LTO. Chain
gains about0.8-1.3percent, with one repeat interval including1. Full30 hinge slows
0.9-1.0percent and its followup2.8-3.1percent, all intervals above1. The full-run
free slowdown is not reproduced in its followup; both results are retained.
No sufficient compensating integrated benefit is established, so this predicate
is not adopted. Static comparison counts do not establish causal time savings.
The chain still takes about1.80 times C's time in this full run. Overall parity,
full port/latest migration and global dynamics/factorization Gold remain open.
[Exact source, complete proofs, all54 timing records and rejection decision](evidence/20261027-external-domain-control-r1480/README.md).

## Rounded row envelope: math unit closed; runtime integration pending

The1491 ghost-only successor decomposes the actual rounded update into product
and sum envelopes. Both exact-reference complete Solver_Kernels reports close279
checks, with the four inherited warnings matched to the published source
statements. Original runtime row bodies remain byte-identical. Product monotonicity
uses the existing verified SPARK Long_Float library instance: exact source,
matching valid vendor Why3 session and supplied Coq proof are retained. This is an
explicit previously verified mathematical dependency, not a freshly proved local
vendor body or a fresh Coq replay. Counts are scoped and not additive.

The separate certified packed-row prototype still has incomplete loop proofs;
its successful posts under unresolved preconditions and timed-out successors do
not establish closure. Producing and preserving runtime row certificates,
proving consuming callers and measuring the resulting full movement remain work.
No original rejection path or public input domain is removed, and no performance
gain, whole dynamics/factorization Gold, full port or C parity is claimed.
[Both-reference279 reports, vendor proof boundary and retained open prototypes](evidence/20261027-row-envelope-math-r1504/README.md).

## Private certified row and fused copy/max units closed

Final1524 separates the certified packed update into a new child unit, leaving
all existing runtime owners unchanged. Its complete units close124 checks on
both references without warnings: ordered FP values, full frame, Work domain
and propagated rounded row bound under proven input certificates. A separate
copy/max child closes26 on each reference: exact copying and exact max-abs in
one traversal, including distinct origins and null rows. The existing verified
Long_Float mathematical dependency remains explicit; no fresh Coq replay claim.

Both standalone C17 profiles pass all7374 native exact-bit cases:5448 certified,
1807 original fallback and119 empty, with sentinel/source frames and copied max
bits checked. The original8MiB large checked-test stack failure is retained;
the same binary/corpus/oracle passes with64MiB test stack. No production stack
change, full-C14 numerical integration or universal C-equivalence claim follows.

Release/LTO diagnostics show the new certified loop is still scalar, while the
existing long-row fallback has SIMD. The later zero-origin window is a separate
unfinished successor. Caller certificate production/propagation, full integration
proofs/numerical gates and replicated movement timings remain required before
runtime adoption. No gain, C parity or whole dynamics/full-port completion is
claimed from these private modules.
[Complete124/26 scopes, exact bits, stack control and scalar codegen](evidence/20261027-certified-rows-and-max-bounds-r1531/README.md).


## Certified SIMD rows and private solver integration checkpoint

The certified packed-row child closes169 checks on both references, with fresh
7374 native exact-bit cases per profile. The private integrated solver passes
all30 fixed100-step endpoint cases and both-reference/profile activation and
integration. The complete row-bounds child closes264 checks on the recorded C17
run, retaining its documented warnings. Proof counts describe separate scopes.

The loader's functional prefix proof remains open; subsequent frame work and the
12-group gate are outside this checkpoint. Integrated performance qualification,
runtime adoption and whole dynamics/factorization Gold remain pending. Production
runtime is unchanged. The archive preserves frozen sources, binaries, successful
proofs and unsuccessful controls with their exact scopes.
[Certified SIMD and private solver wiring evidence](evidence/20261027-certified-simd-and-solver-wiring-r1624/README.md).


## Certified loader and both-reference child units closed; actual caller pending

The1639 private checkpoint closes the exact ordered-FP compact loader66 on both
references using a transparent row model and proved frame/join helpers. Complete
certified children close169 without warnings; complete row-bounds children close264
with documented warnings. The factor-row adapter38, compatible-buffer solver98
and packed-layout minimum25 close too; counts describe separate scopes.

Both-reference/profile activation/integration, all12 numerical groups,7374 native
exact-bit rows/profile,66306 original rejection/frame cases/profile and all30
actual integrated endpoints pass. Qualification has not passed: the actual Solve
scope exposes SPARK E0007 on a variable-input local array constraint. Corrected
1652+ constant/framing successors and their open caller proofs are outside this
checkpoint. Production remains unchanged; no replicated timing, adoption, whole
inertia/dynamics/state Gold, global factorization, full port or C parity claim.
[Exact sources, scoped proofs, numerical results and failed controls](evidence/20261027-certified-loader-and-units-r1659/README.md).


## Certified callers and replicated diagnostic regressions

The1675 composition and size-exposure helpers close7 and2 checks on both reference
closures. Actual Solve closes148 checks on each but retains three configuration/
state frame obligations; this is not whole-caller or dynamics closure. Fresh
source-bound numerical runs and all30 final endpoints pass, with explicit audits
for unchanged lower proof scopes and Static ghost-only source differences.

The six-replica target9 and independent repeat9 diagnostics show the private
certificate prototype slower than published Ada, including about6.9-7.1percent
on chain24 in the repeat. An isolated certified-child256-width control and an
independent proved common-index copy control still show chain slowdowns of about
4.8-5.2percent and4.6-5.1percent respectively. Neither is adopted; no causal cost
percentage follows from comparing separate runs. All raw measurements, uncertainty,
failed proofs and exact source/binary bindings are retained. Full state/dynamics
Gold, full port/latest migration and C parity remain open.
[Caller scopes, whole284 copy proofs, all diagnostic measurements and profiles](evidence/20261028-certified-callers-and-diagnostic-controls-r1715/README.md).

## Reproducible baseline and further state proof controls

Rebuilding checkpoint 1319 with the current strict build recipe produces the
same executable byte for byte, including its text section. All 30 fresh movement
endpoints still match the published Ada baseline exactly and the original native
C oracle within its unchanged tolerance. No additional timing comparison of
those identical executables is needed. This checks build reproducibility for
that source; it does not exclude compiler or code layout effects between
different programs.

A new static state-view lemma closes 5 checks on each reference. The normal
caller experiment closes 153 checks but retains the same three configuration
and state obligations. Short diagnostic controls and the cancelled preparation
attempt are retained with their actual source bindings. Earlier separated-solver
and outlined-helper controls also remain slower and unadopted. Production code,
whole dynamics proof status and the pending C parity requirement are unchanged.
[Exact rebuild, proof scopes, numerical checks and diagnostic controls](evidence/20261028-baseline-rebuild-and-state-proof-controls-r1747/README.md).

## Four-lane copy proved; integrated measurements reject adoption

The private packed-copy successor uses four independent maximum accumulators
under unchanged contracts. Its minimum closes 77 checks and both complete
Row_Bounds units close 341, with explicit initialization-precision warnings.
Fresh bit checks pass 12,336 scenarios per standard profile/reference closure;
activation/integration and all 30 actual movement endpoints pass too.

Six-replica full-30 diagnostic timing does not justify adopting it: free_ball
is 8.15–8.77 percent slower than published Ada, chain_24 is 6.24–6.90 percent
slower, and branches_24 is 5.48–5.65 percent slower, with per-state intervals
above parity. Lower medians on some smaller models have intervals including
parity. Raw measurements and unsuccessful proof controls are preserved. The
production code stays unchanged, and the actual caller's three state and
configuration obligations, full-port work and C parity remain open.
[Four-lane sources, complete proofs, numerical checks and raw full-30 results](evidence/20261028-four-lane-copy-proof-and-full30-r1764/README.md).


## Static bounds adopted in four smooth math kernels

Apply, Apply_Transpose, Multiply and Rotation now retain their original local
bounds as proved Static assertions instead of performing 63 redundant subtype
checks at runtime. All public contracts, required inputs, arithmetic expressions
and evaluation order are unchanged. Both reference closures close the changed
Apply68, Apply_Transpose68 and Multiply116 scopes; Rotation157 is reused only
after checking its exact body, types and dependent contracts. Existing warnings
remain visible. Full Smooth_Math attempts reach their240-second watchdog without
a fresh complete report, so whole-unit Gold remains open.

Fresh numerical checks pass both standard profiles/reference closures and all30
movement endpoints. The three-operation bit corpus passes31,776 admitted cases
per build in eight profile/reference/role builds; Rotation has its separate14,927
case corpus. Full30 six-replica integrated diagnostics improve chain_24 by
3.65–3.88 percent, branches_24 by5.29–5.65 percent and free_ball by2.38–2.91
percent versus previous Ada, with per-state95-percent intervals below parity.
Other lower medians whose intervals include parity remain inconclusive. Native
C is still faster: about1.77x and1.40x Ada/C time on chain_24 and branches_24.
The final combined change is adopted locally; no full-port parity is claimed.

The same checkpoint preserves complete private Pose_Bounds146 proofs on both
references and Pose_Rounding34 on3.17. These do not close the global pose producer
or remove the Jacobian/external-force scans. Those pose prototypes are unadopted.
Whole state/dynamics/factorization Gold, latest ABI migration, remaining feature
coverage and C parity remain unfinished.
[Exact sources, proof scope, numerical tests and raw integrated measurements](evidence/20261028-static-math-and-pose-bounds-r1859/README.md).


## Static bounds adopted in dynamics primitives

The next local change removes 29 redundant temporary subtype checks in ten
Smooth_Dynamics bodies. Two private helper return bounds become equivalent
proved explicit postconditions; all public signatures, return subtypes,
contracts and required domains remain unchanged. Each of the ten scopes closes
on both reference closures with zero warnings. Both complete-unit attempts time
out at 240 seconds without fresh complete reports, so whole-unit closure and
whole state/dynamics/factorization Gold remain open.

Eight standard profile/reference/role builds pass 34,304 exact-input-bit cases.
Both-reference/profile activation and supported integration suites and all 30
movement endpoints pass. Six-replica full-30 timing compares against the already
adopted 1838 math change: incremental time reductions are 0.91–1.26 percent on
chain_24, 1.74–2.09 percent on branches_24 and 5.32–6.19 percent on free, with all
per-state intervals below previous Ada. Ball and free_ball remain inconclusive.
Direct Ada/C time ratios remain about 1.75, 1.38 and 1.21 respectively; full-port
parity is not achieved. This incremental change is adopted locally.

Fresh flat CPU sampling identifies Solve_Acceleration, the compatible solver
and Add_Long_Row as candidate hot functions. Many timer overruns limit precision;
fractions are not exact phase costs or causal slowdown percentages. All 10,000
profiled endpoints per role equal the corresponding uninstrumented output.
Disassembly places the two hottest current PCs in the final numerical range
check of an external-force contribution; the enclosing function also includes
other inlined work. Inspect projection guards and compact-row paths against C
before selecting another primitive optimization. No force scan is removed by
this profiling work. Full feature coverage and coordinated latest ABI migration
also remain unfinished.
[Exact sources, scoped proofs, numerical tests, raw timing and profile evidence](evidence/20261028-static-dynamics-primitives-r1893/README.md).

## Private external-force bounds and pose producer proofs

The bounded external-force leaves now have closed local functional/safety
proofs and exact-bit unit comparisons on both reference closures. The private
pose chain closes all113 Build_One_Body obligations on each reference, including
position/center growth and joint-anchor propagation. Existing warnings remain
visible. These prototypes are not adopted: whole-tree/manifold propagation,
mocap/state lifecycle and the actual caller preconditions remain open. No new
production scan is removed and no new performance result is claimed.
[Exact sources, successful scopes, unsuccessful attempts and leaf bit tests](evidence/20261028-external-force-bounds-and-pose-producers-r2037/README.md).

## Private scalar pose tree closure and manifold leaves

The scalar Build_Bodies path closes all110 obligations on both reference
closures, including absolute position/center/anchor bounds and preservation of
previous body budgets. Store_Body_Pose32 and the Ghost anchor loop34 also close
on both references. Mocap facts are explicit Static caller obligations; full
manifold traversal, state lifecycle and external-force cache publication remain
open. This does not close whole simulation dynamics or adopt the fast leaves.

Fresh whole Pose_Bounds203, Pose_Rounding48 and the67-check Pose_Frames snapshot
close on both references; the later free-position helper closes13 per reference
separately. Existing warnings remain visible. Both standard profiles/references
pass activation432 and integration1152 scenarios each. All30 integrated100-step
movement endpoints equal adopted1860 Ada exactly and satisfy the unchanged C
oracle. These are numerical checks, with no new timing or production adoption.
[Exact source snapshots, successful scopes, failed controls, numerical tests and C/vendor provenance](evidence/20261028-pose-tree-budgets-and-manifold-leaves-r2100/README.md).

## Tight rotation bounds and expanded-group metadata

The independent private Rotation_Bounds unit closes all166 obligations on both
reference closures, proving every original rotation component within1.00001
under Unit_Quaternion. Rounding-error and standard big-number model boundaries
remain explicit, with all19 warnings visible. Complete reports resume the exact
unchanged proof context after initial watchdogs; partial sessions are retained.
No circular strengthening of the original Rotation contract is introduced.

MJ.Data.Group_Layout is adopted locally as Ghost Static code: whole69 closes on
both references, and it compiles in the actual validation project. Native DOF
widths, uniform expanded metadata and the next group start are specified and
proved. This adds no runtime scan or state field. Private free/ball stores close
48/30 checks on each reference. Factory preservation and complete manifold
traversal remain open; runtime force guards remain and numerical code is unchanged.

An isolated positive/negative control confirms Static type-invariant behavior.
The unadopted mocap prototype closes63 setter checks, including invariant and
configuration-frame preservation, while State_Values preservation and the full
state lifecycle remain open. Failed variants and alternate norm attempts retain
their actual outcomes. No new performance or complete-port claim follows.
[Exact proofs, source snapshots, adopted Ghost module and cleanup receipts](evidence/20261028-tight-rotation-bounds-and-group-layout-r2198/README.md).

## Mocap frames with nonzero actuator state

The expanded mocap suite adds integrator/filter/filterexact models with nonzero
activation, control and generalized applied force. All368 cases pass in each
of eight frozen reference/profile/role runs (2944 total), and92 corresponding
baseline/candidate output files are byte-identical. The existing fixtures,
16 samples,100 steps and2e-10 C tolerances are retained. These are numerical
checks, with no new timing or complete-port parity claim.

The private setter state-frame prototype closes80 obligations with activation
preservation open. Separate activation/input postcondition diagnostics each
close3 checks under their intermediate cut assertions; they do not prove all
setter checks. Full revised setters still hit600-second watchdogs. Existing
Free/allocator/equality/query helper scopes and all failed attempts retain
their precise results. The mocap invariant remains private and its complete
constructor/reset/public-operation lifecycle is open.
[Exact scoped proofs, diagnostic limits and baseline/candidate/C trajectories](evidence/20261028-mocap-frames-and-actuated-trajectories-r2253/README.md).

## Proved mocap map and recovered state-proof work

The actual private mapping validator now has an exact Boolean specification:
valid ID range, uniqueness of nonnegative IDs and coverage of every slot. The
complete validator closes45 checks per reference and its coverage lemma12 per
reference. All added proof work is Static; fresh validation objects emit no
Ghost helper/spec or prefix-proof scans. Constructor mapping still uses one
seen-array pass and the existing final coverage check.

Final actual source passes1472 new C comparisons (368 per reference/profile),
with all92 output files identical to the adopted baseline. These checks retain
16 samples,100-step trajectories and2e-10 tolerances. Code size is372 bytes
versus382 for the prior validation mapping, with no timing claim.

The private3.17 raw-reference proof chain now includes validity projection4,
one-body projection6, owned-reference loop26 and caller wrapper10, with their
separate callee scopes retained. Constructor/reset/state lifecycle integration
and the mocap invariant remain unfinished. Interrupted I/O attempts, failed
annotations, syntax errors and quantifier variants retain their actual status.
[Exact sources, fresh proofs, recovered partial attempts, C provenance and final numerical/codegen evidence](evidence/20261030-mocap-mapping-gold-and-io-recovery-r2380/README.md).

## Mocap reset loop and state-buffer frame

The independent private reset-copy loop closes52 checks on each reference,
including exact raw pose values and typed bounds under its explicit inputs.
The actual Clear_State receives only Static value/nullity/index-range frame
contracts and two Ghost queries: its original Pre/Post and four assignments
are retained, with50 checks closed on both references. No runtime scan or
field is introduced.

Actual and private-lifecycle candidates each pass1472 fresh C comparisons;
all184 output files equal baseline, with16 samples,100 steps and2e-10
tolerances unchanged. Validation emits no Ghost state-image functions.
Full Reset proofs still reach600-second watchdogs; the new helper call's
seven checks close only in an explicitly limited diagnostic. Whole constructor
flow reports an actuator borrow and Arms initialization gap, preserved as open.
The private invariant is not adopted.

A one-ball-joint/three-DOF fixture exposes why full Matches_Body becomes too
strong after DOF expansion. Raw-reference proofs now require only the raw
quaternion copy relation, closing28 and wrapper12 per reference. The broader
postconditions remain unchanged.
[Exact sources, successful scopes, failed attempts, caller/flow diagnostics and numerical evidence](evidence/20261030-reset-mocap-loop-and-state-frame-r2470/README.md).

The separate3.17 Arms initialization diagnostic now proves loop-invariant
initialization/preservation and the final Initialized assertion, without an
extra zeroing pass. An earlier filter generated0 proof checks and is retained
as mis-scoped evidence. These are selected-line initialization results only;
whole-builder runtime/functional proof and production adoption remain open.
[Exact diagnostic scopes and stored source context](evidence/20261030-topology-initialization-diagnostics-r2477/README.md).

## Activation borrow removed and validator contracts closed

The actual constructor configures each actuator through an in-place helper,
then handles cleanup after the element borrow ends. The helper preserves the
original checks/copy order and avoids a whole-record copy. Fresh final scopes
close153 checks per reference for its successful output/frame properties,10
for supported-dynamics projection,3 for geometry-layout projection and13 for
Model_Status. The last projection also closes the validator postcondition that
remained open in the previous baseline. Added contracts and lemmas are Static;
no runtime scan or new trusted body is introduced.

The expanded suite adds muscle and mixed-mode fixtures, passing432 cases per
reference/profile at16 samples,100 steps and unchanged2e-10 C tolerances.
All108 final output files equal the earlier baseline byte-for-byte. Actual
whole-unit flow no longer reports the actuator borrow, retaining only the two
known Arms initialization messages. A selected constructor call closes8 checks
under its intermediate facts; the broader activation-region proof reaches its
240-second watchdog. Whole Initialize/Reset/state proof, private invariant
adoption and integrated performance parity remain open. Existing warnings,
failed contract placements, compiler failures and the stack retry are retained.
[Exact sources, scoped proofs, baseline comparison and adoption receipts](evidence/20261030-activation-borrow-and-validation-proofs-r2545/README.md).

## Proved manifold cache construction and Arms initialization

The actual manifold path now uses a fused DOF preparation pass, a raw-array
cache builder and a thin model/owned-state wrapper. Their complete scopes close
56,67 and49 reported checks per reference, including exact metadata copies,
success/rejection, frame properties and initialized armature reads. Mechanical
comparison preserves the original traversals/check-copy order. Length-based
internal shapes handle empty arrays without narrowing public inputs. No extra
zeroing pass, runtime validation scan, assumption or trusted body is added.

Both actual MJ.Data flow runs now have no open messages; this closes the prior
Arms flow gap, with separate proofs of initialization in the producer and both
consumers. Flow-only results do not establish whole-unit safety or Gold. The
new16-DOF mixed tree has free/ball/hinge joints, general/simple DOFs and nonzero
armatures. Final source passes464 cases per reference/profile with the same
samples, steps and2e-10 tolerances; all116 outputs equal expanded baseline.

Monolithic/hidden-predicate attempts and the earlier selected Initialize call
retain their240-second watchdog results. Whole factory/Reset/state/dynamics
proofs, private mocap invariant adoption, full features/ABI alignment and
integrated C performance parity remain open. Existing warnings/deallocators
are retained. No new performance measurement is claimed.
[Exact source, six scoped proofs, both flow runs, failed attempts and native C comparisons](evidence/20261030-manifold-topology-and-arms-initialization-r2588/README.md).

## Proved actuator remapping with an explicit caller-frame gap

Remap_Actuators now receives only its owned actuator array and dimension values,
so it cannot mutate the rest of Simulation through its interface. Complete
final scopes close35 checks per reference for one element,77 for array
composition and37 for the model adapter. The acceptance/record model definitions
close9/14, and validated joint-kind projection and Model_Status each close14.
These are scoped safety/functional properties under explicit inputs/callees,
with existing warnings retained. Static models/lemmas are absent from native
objects; no new record copy, input restriction or runtime scan is introduced.

Parent-frame ball and body-transmission fixtures expand the suite to528 cases
per reference/profile. Both baselines and final source pass; all132 final
outputs equal baseline at the unchanged samples/steps/2e-10 tolerances. The body
case has no active contact and does not validate contact-coupled body actuation.
Both whole MJ.Data flow analyses have no open messages. The selected topology
call in Initialize closes7 checks with Body_Config nonnull still open: body
configuration preservation and activation-loop frames remain proof work.

Failed shapes/prefix attempts,240-second watchdogs and the final600-second
runs retain their actual outcomes. Complete constructors/Reset/state/dynamics,
private mocap invariant, full feature/ABI alignment and integrated performance
parity remain unfinished. No new timing claim is made.
[Exact scopes, sources, native C cases, caller diagnosis and adoption receipts](evidence/20261030-actuator-remapping-and-caller-frame-r2649/README.md).
