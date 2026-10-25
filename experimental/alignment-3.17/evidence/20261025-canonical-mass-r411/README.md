# Canonical compact mass on the real smooth path r411 — 25 October 2026

Local work only: no commits or pushes. The retained r349 row solver is unchanged.
This checkpoint connects the r380 constructors to the simulation, native mass
reader, inverse multiplication and constrained mass adapter. Production remains
pinned to C3.14; the coordinated C3.17 candidate is not declared fully migrated.

## Behavior and C structure

For the existing nv>=3 CRB route, assembly writes directly into persistent compact
ancestor rows. No dense mass candidate, symmetric dense writes, dense publication
copy or dense-to-factor gather is performed on that successful route. Factor
loading is a contiguous copy followed by the unchanged diagonal damping order.
The old dense allocation is retained for compatibility, not populated by this
normal route. Get_Mass_Matrix expands only when a caller asks for dense output;
Mass_Entry, native disjoint gather and inverse multiplication read the canonical
view. The constrained adapter now also reads Mass_Entry rather than stale dense
storage. Source selection is part of cache state and readiness; reset/free cover
the new owned storage. Existing reviewed deallocator implementations are unchanged.

The small nv<3 algorithm is retained to preserve existing rounded results. A
captured tendon plan whose terms cannot be represented in the ancestor pattern
falls back to the prior dense path rather than dropping terms. Strict diagnostic
solving expands at its explicit boundary and retains one domain scan pending
formal composition of the expanded bound. These are explicit remaining scopes,
not claims that every allocation/scan or dense path has disappeared.

The inspected C3.17 mj_crb/mj_factorM/mj_factorI uses direct compact construction,
a contiguous factor copy and reverse L'DL row updates. The inertia factor loop
is not the separate blocked symbolic constraint factorization. A direct C/Ada
control with a fixed tendon across independent roots confirms that C itself
adds armature only in its reduced M pattern; no new full J'J cross-branch terms
are invented. The audit and actual official C sources/pin are retained.

## Proof scopes

Compact_Tendon_Mass closes all 100 checks (89 proof, 11 flow): semantic slot lookup,
exact ordered additions/frame, exact recursive accumulation and rejection of an
unrepresentable term. Five diagnostics (three inherited row expressions and two
recursive-model diagnostics) remain separate from closed obligations.

Compact_Assembly closes all 117 checks (104 proof, 13 flow), including exact
Row_Value relations and untouched earlier rows in Fill. Seven inherited/template
diagnostics remain. Build's present published contract is boundedness/composition
with the proved composite and Fill callees; a full source-slab-to-physical-model
functional contract remains to be strengthened. Do not label that wider property
as proved from the Fill contract alone.

The real Mark_Compact_Ready minimum closes 20 checks without warnings. Diagnostic
attempts first isolate the symmetry assertion; a proved two-check layout lemma
exposes the same DOF/pattern size, then canonical symmetry closes. No assumptions,
new trusted implementation bodies, proof skips, input-domain narrowing, unsafe FP
or suppressed Ada checks are introduced. The observer is a test-only child and
is not an implementation dependency or proof axiom.

Caller minima are recorded verbatim in summary.json. Allocation closes 28
checks; compact factor loading closes 18 for bounds/safety (its present contract
does not specify the full damping result); inverse Coefficient closes 19;
Gather_Current closes 53 including its exact functional/frame relation. Five
obligations remain in composed callers: one dense-output relation, three in the
compact construction/publication path and one overall Solve postcondition.
The Solve minimum proves its calls, bounds and non-aliasing after E0007 is fixed;
it is not a closed complete dynamics proof.
Any remaining caller obligations are unfinished proof engineering, not Silver
research exceptions. Counts are scoped and are not additive. Full pipeline,
physical model/cache binding and complete factorization functional proof remain
open, together with the broader port/current-release scope.

## Numerical and actual-route checks

Final-source validation and release pass the complete C3.17 and C3.14 raw mass,
derivative/inverse/constrained/boundary suites. C3.17 also passes reordered-layout
derivative gates; the existing independent original-C/permutation control for the
reference Hessian limitation remains explicit in those reports. No direct C
success on the known crashing mutated-model case is inferred.

The test-only child observes actual compact selection for nv>=3, untouched legacy
dense storage, unchanged published compact mass across compatible and strict
solves, dense API values, stale-output rejection, reset and source-model/owned
storage lifetime. Forty mode/model/policy records cover 120 states, with maximum
absolute C mass difference about 3.47e-18. Both validation and strict release pass.
Static proof statements in the publisher and a local constant for the strict
branch array bound plus Int64 comparisons in inverse preconditions differ
between that observer's snapshot and the final
runtime/movement closure. The constant fixes GNATprove E0007 without changing the
bound value; the Int64 comparison avoids a precondition-evaluation range check
without excluding valid inputs; both closures and the failed generation are preserved separately.

## Integrated timings and limits

Two complete sessions cover 30 scenarios each, with 24 balanced process blocks,
eight measured trajectories, 32 warmups and 100 evolving steps per trajectory.
Ada baseline/current endpoints remain exactly equal; C agreement uses the existing
2e-10 tolerance. Inputs/reset/I/O are outside timing. No other own heavy job ran
while timing. CPU affinity is 12 inside WSL2. C's normal SIMD wheel is used; its
library compiler flags remain unknown, so matched-build final C acceptance is open.

The final session ranges are recorded by model in summary.json; all raw
samples, block medians and intervals are preserved. The earlier two sessions
are also retained. The multi-DOF improvement has the same direction in both
pairs: across all four sessions chain24 takes roughly 4.7–6.9% less time and
branches24 about 3.2–4.7% less. The sizes of several smaller-model ratios vary.

Hinge takes 0.77–1.29% more time in the first pair and roughly 1.1–1.5% less in
the final pair. The baseline ELF and .text hashes are identical across the two
builds; no baseline sources differ. Final current sources differ only in the
strict-branch array-bound constant and safe inverse precondition comparisons,
which do not change the hinge algorithm. This does not establish a causal hinge
speedup or eliminate its earlier regression. Between-session effects remain
unresolved; no arbitrary noise allowance is assigned. Both current ELFs and
their actual .text sections/source differences are archived. Timing ratios use
block medians; absolute flattened-sample medians and intervals remain separate.
These ranges are not an unweighted aggregate or proof of compensation.

Chain movement still costs about 3.18–3.25 times the C wheel time; branches about
2.42–2.47 times, with exact per-case records retained. Scope is supported smooth Euler movement with external loads,
not complete MuJoCo. Contacts, activation-state models, sensors and rendering
are outside this timing suite even where separate numerical fixtures exercise
other supported behavior. No complete port or C performance parity is claimed.

## Artifacts

The ZIP preserves all source attempts, initial backup, failed compilation and
proof attempts, scoped/whole reports, exact drivers/commands, actual route tests,
final two-reference gates, both paired builds, raw timing/state outputs and pins.
Object/prover-task caches, external toolchain binaries and the external C shared
library are excluded; their versions/hashes/flags remain. All archive members
are hashed and reread; all 87 prior evidence-file hashes are preserved.
