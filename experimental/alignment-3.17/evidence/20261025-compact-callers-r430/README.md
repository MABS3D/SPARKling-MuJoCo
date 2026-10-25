# Compact export, strict boundary and release LTO — 25 October 2026

Local work only, with no commits, staging or pushes. Production remains pinned
to C3.14; the C3.17 migration, whole-engine proof and performance parity are not
complete. The retained r349 solver arithmetic is unchanged.

## Functional work and exact proof scopes

Get_Mass_Matrix now composes its raw compact/dense output with the public
Mass_Entry view through a static ghost lemma. The lemma closes 15 checks
(14 proof, one flow); the real public procedure closes 19 (16 proof, three flow),
including exact row/column values, arbitrary valid output origins and the
existing failure-zero behavior. Each scope has eight inherited diagnostics,
recorded separately; obligations_closed=true, strict passed=false.

Lower_Entry and Value_At have conditional static bound contracts. Expansion
retains its full original public domain: unbounded inputs are not excluded.
When its source is Work_Array, Expand_Row and Expand additionally prove bounded
output, with no change to stored values, symmetry or evaluation order. The
smallest scopes close 20/4/18/73 checks; the complete Compact_Inertia unit closes
377 (351 proof, 26 flow). All six diagnostic types/messages/multiplicities match
the previous 367-check complete unit. Scope counts overlap and are not additive.

That bound is proved at the actual strict Solve call site. Its explicit second
Work_Array(Dense) runtime traversal is removed, while dense expansion remains
at the strict diagnostic boundary. Solve closes 125 checks including the new
static assertion, call preconditions, indices and non-aliasing; its overall
postcondition remains open. The separately proved Expose_Compact_Layout minimum
closes five checks, with 12 inherited diagnostics.

Four examined caller obligations remain: three in compact construction
(overall frame/readiness, tendon-plan relation after the borrowed mass write,
and readiness before publication), plus the Solve postcondition. This does not
count the wider unfinished Data/pipeline/physical-model binding or full
factorization functional specification. Build still publishes a boundedness
contract; its full source-to-row functional composition remains to be specified
and proved. These are proof engineering tasks, not mathematical Silver exceptions.

Broader framing/helper refactors were tested but not retained because they
increased open obligations. Their sources, exact reports and failed attempts
are preserved. A whole-unit run selected with an insufficient 600-second
aggregate cap was deliberately interrupted after 272.9 seconds; the historical
closed run took 648 seconds. The separate 900-second attempt closes all checks
in about 654 seconds, with the same 3-second/650-MiB per-obligation settings,
2500-MiB group limit, j1, no inlining and no assumptions/skips/new trusted bodies.
Existing reviewed deallocator implementations and warnings remain unchanged.

## Numerical and boundary checks

The final Ada library sources pass all ten ordinary two-reference gates in
validation and release: C3.17 raw mass (288 states/profile), original and
reordered derivatives (960 each/profile), and C3.14 raw mass (132 states/profile)
and derivatives (960/profile), with their existing boundary/malformed/output
checks. These are differential tests, not universal C equivalence proofs.

The cache observer now also checks the actual damped Euler velocity against
C mj_Euler, rather than only solve status and mass. It covers 12 models,
including chain/branch 24 DOF, ball/free and tendon cases: 48 profile/policy/model
records, 144 states. Maximum observed mass error is 3.47e-18 and velocity error
1.04e-14. Compatible and strict both pass; canonical mass stays unchanged, stale
reads are rejected, legacy dense storage remains untouched on the normal route,
and owned/source-model lifetime remains checked. This is a test-only child,
not a proof axiom or production dependency.

The isolated LTO build also passes all ten two-reference gates, 14,905 exact
row boundary/rejection/frame cases in each profile, and the 48-record Euler/cache
control. Ordinary validation and release are both tested; LTO validation is an
additional control. These results are separate from source-level proofs.

## Reproducible current C reference

Official C3.17 commit 800a109a4bdd02cb60404d565db4ae16fb04a53b is built offline
from isolated Git archives. Every dependency uses the exact official pin;
upstream source hashes, official dependency patches, generated dependency files,
compile commands, compiler/runtime/library hashes and ELF resolution are saved.
No historical source/cache checkout is modified. Normal AVX and hand-written
intrinsics remain on, as does upstream's default LTO. GCC16.1 uses
-O3 -DNDEBUG -march=native -ffp-contract=off; no fast/finite-only/trapping-math
changes are added. The resulting library reports 3017000 and its loaded path is
checked. Wheel comparisons remain separate, with their unknown library flags.

Two source-built-C sessions reuse the identical non-LTO Ada executables from
the wheel comparison. The C-reference change therefore is not an Ada speedup.
Chain24 is about 2.53–2.58 times source-built C, and branches24 1.97–2.00 times;
the corresponding wheel gap remains roughly 3.2/2.4 times. Exact records,
intervals and all samples are preserved rather than combined into an average.

## Integrated LTO experiment and default policy

Two further sessions compare the same Ada library sources with and without
-flto=1, against the same source-built C reference. Compiler and linker retain
native O3 and FP contraction off, with language checks retained. All Ada
trajectory outputs remain exactly equal, and both agree with the independent
C-wheel numerical oracle under the existing 2e-10 tolerance.

Chain24 takes about 8.0–9.1% less time and branches24 about 13.2–15.7% less;
small affine chains and fixed tendons improve roughly 14–15%, hinge about 5–6%.
Free/free+ball cases and their wider intervals remain in the raw reports. No
unweighted faster-case count, percentage mean or universal compensation claim
is used. Current/source-built-C ratios remain about 2.32–2.33 for chain24 and
1.69–1.72 for branches24. This is meaningful improvement, not C parity.

Each comparison has two complete 30-scenario sessions, 24 balanced process
blocks, eight measured trajectories, 32 warmups and 100 evolving steps; CPU12
inside WSL2, setup/reset/I/O outside timing. No own heavy job overlaps timings.
The ordinary no-LTO hinge comparison changes sign between the wheel and
source-built-reference session pairs despite unchanged Ada binaries. All pairs
are retained; a causal gain from the strict scan removal is not inferred on the
compatible timing path, and no arbitrary noise tolerance is assigned.

Release LTO is now the default for the derivative candidate GPR and shared
movement/row/cache/compact-constructor builders. The ordinary O1/gnata/gnato/gnatVa
validation profile stays unchanged. Compiler/linker flags are centralized and
--no-lto remains an explicit movement-build control. No unsafe FP or suppressed
language checks are introduced; production's C3.14 pin is unchanged.

The adopted snapshot has identical Ada source bytes to the proved r429 snapshot;
only six Python builder/checker files and the GPR differ. Its real default GPR
reconfirms the three C3.17 release gates. The default row and Euler/cache builders
pass both profiles, and compact constructors pass all 1,026 cases/100,236 values
per profile with zero observed C difference. The default movement builder's
.text differs from the isolated prototype, so two additional complete paired
sessions were run rather than inferring binary equivalence. Actual default
chain24 time falls 8.1–9.4%, branches24 13.3–14.5%, and hinge 8.7–8.9% versus the
unchanged non-LTO control. Per-model differences from the prototype are retained;
no extra arithmetic change or universal causal explanation is asserted. Current
source-built-C ratios are 2.32–2.38 for chain24 and 1.66–1.69 for branches24.
The updated profiling linker template also produces gmon data under LTO and
checks exact Ada/C numerical outputs. Its 300-sample control is too short for
fine phase ranking.

## Profile and explicit remaining scope

The new gprof control checks exact Ada outputs and C tolerance for chain24,
branches24 and free before using samples. It covers the full instrumented
process, including setup/reset/I/O; it is not release phase timing or a direct
attribution of the C gap. Chain solve_compatible_buffers has 25.44% self time
(1.31 of 5.15 sampled seconds); separate long-row self time is about 3.1%.
External-load Jacobian/projection work is also visible. Free has only 25 samples
and is too coarse for a reliable small-cost ranking. Metadata query calls are
already inlined in the release solver: machine-code inspection finds three
remaining ancestor query call sites overall, none in Inertia_Phase. Adding
inline directives to those getters is not justified by a presumed solver call
cost. Release ghost export/layout helpers have no emitted helper symbols.

A polynomial damping boundary control disproves a suspected silent omission:
zero coefficients agree with C; nonzero coefficients explicitly return
Unsupported_Feature. Polynomial forces remain an unsupported port feature,
not an admitted case demonstrated wrong here. The initial failed hypothesis
and its corrected control are both retained, with the executable version
identified. This movement suite does not exercise activation-state models, contacts/
constraints, sensors or rendering. Their separate implementations and remaining
gaps, together with newer-version behavior, still require the full-port audit;
no gate here proves those complete.

The archive retains source versions, failed/refused variants, scoped and whole
reports, exact drivers, both reference suites, actual-route tests, eight new timing
sessions, profile/assembly audit and the pinned source-built C. Compiler/prover
objects and external toolchains are excluded. All members are hashed and reread;
all 92 prior evidence-file hashes are preserved.
