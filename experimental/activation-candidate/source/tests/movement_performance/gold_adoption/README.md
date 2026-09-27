# Sequential Gold optimization adoption

The persistent work list is `plans/2026-09-26-gold-performance.md`.
Each runtime change requires its own proof scope, numerical checks and two
integrated timing sessions. No diagnostic guard removal is accepted as a proof.

Latest adoption: `evidence/scan-parity-adoption.zip/json` removes the remaining
whole-Simulation readiness rescans from the supported release Euler.Step: three
to zero, matching C for this category. All 88 required local proof scopes and
interface checks pass; the whole Euler unit closes 160 proof + 31 flow checks.
All 108 active-source hashes match the measured checked/release candidate.
Strict and Compatible each pass 624 scenarios/168,192 comparisons. Two quiet
integrated sessions improve all 33 cases, with paired CI95 below 1 in both
sessions and 17.8–41.7% lower time per step. C timing ratios remain workload
specific, about 0.72–1.70. Numerical and standalone API guards remain. See the
final entry for exact scopes and reproducibility.

`build.py` freezes the current active source as baseline and overlays only the
specified candidate source files for current/release and checked builds. It does
not edit the active simulator. Use the matching pinned C build, then the existing
`c_parity_six/compare.py` and `experimental/smooth/tools/compare_numerics.py`.
Do not run builds/proofs concurrently with timing.

The first code-generation trial (`Inline_Always(Multiply)`) is archived in
`evidence/inline-trial.zip`. Its 154 exact-arithmetic/safety proof checks and
both numerical policies pass, but the candidate was NOT adopted: integrated
results are mixed, with no established benefit on 24-DOF workloads and small
regressions on ancestor_branches_24. Sources, binaries, checked probe, two
sessions, numerical outputs, proof source and commands are included. This is
useful negative evidence, not completion of the code-generation work item.

The accepted pose change and rejected damping variants are documented in
`docs/gold-performance-adoption.md`. `pose-proofs.zip` and
`pose-validation.zip` support the accepted runtime source. Damping helper and
ghost-only variants have separate proof/performance archives; neither is active.

`MJ.Fused_RNE` is an integrated standalone prerequisite, not dispatched by Step.
Its `fused-rne-prerequisite.zip` archive contains exact source, proof evidence
and branch tests. `fused-rne-integration.md` records the pending API/cache work.
Re-run the meaningful standalone checked/release tests with:

```sh
python3 tests/movement_performance/gold_adoption/check_fused_rne.py \
  --out /var/tmp/fused-rne-check --toolchain-root TOOLCHAINS
```

No speedup is attributed to this unused helper. Formal and numerical claims
remain limited to their recorded scope; no pending phase contract justifies
removing an additional readiness scan.

Additional accepted proof-only change: `storage-static-proofs.zip` and
`storage-static-closure.json` prove the stronger Static storage postconditions.
`final-static-release.zip` rebuilds the current runtime: its .text, .rodata and
.data sections are byte-identical to the measured pose release. The full ELF
hash differs. `active-source-match.json` records current source hashes;
`pose-adoption-source-match.json` is explicitly historical.

Pending integration snapshots are named separately: `spatial-split-draft.zip`,
`compact-lifecycle-draft.zip`, `mass-publication-integration-draft.zip`.
`mass-publication-closed.zip` proves the standalone helper only. `crb-bound-proofs.zip`
and `crb-weight-proofs.zip` prove standalone ghost prerequisites and do not, by
themselves, justify deleting the active CRB rejection. Their successful scoped
proofs must not be counted as successful integration or speedups.

`crb-accumulation-draft.zip` adds the closed exact accumulation model and its
unfolding lemma, followed by the incomplete runtime loop (65/75 checks) and a
timed-out hiding experiment. The active CRB guard remains. The separate
`compact-reset-followup.zip` contains the exact snapshot-reveal lemma (13 proof
and 1 flow) and a timed-out caller attempt; it does not replace the earlier best
Reset diagnostic (43 checks, one open). None of these timeouts is a mathematical
limitation or a successful Gold integration.

`spatial-motion-followup.zip` preserves the newly closed direction projection
(4/4) and two bounded buffer-proof attempts. The latest Build_Buffers run has
94 checks and three open obligations; no Prepare proof or scan removal follows
from that partial result.

`mass-publication-followup.zip` records the read-only producer wrapper (4/4),
the improved integration wrapper (6/7), and the subsequent timed-out opaque
symmetry attempt. Publish preconditions now pass in that modular wrapper;
the remaining diagnostic concerns symmetry, but its combined postcondition
and complete frame are not declared closed. Producer dependencies remain
unfinished. The earlier integration draft is retained separately.

`evidence/SHA256SUMS` covers every evidence file in this directory. Archives
retain successful and unsuccessful attempts with separate source snapshots;
verify checksums before reusing a proof receipt. The active source manifest is
the authority for which candidate is actually integrated.

The September 27 solver-buffer candidate is **not active**. Its four scoped
proofs close 104 proof and 20 flow checks, including exact row/store helpers
and the wrapper's state/configuration/cache frame. The buffer solver's own
contract covers safety, bounds and sticky diagnostics, not a complete
functional model of the linear solve. `solver-buffer-closure.json` records
the exact scope and dependency continuity; `solver-buffer-proofs.zip` includes
all scoped attempts and immutable source inputs. `solver-buffer-validation.zip`
contains frozen builds, checked numerical results for both policies, error
injection probes with checked and production release flags, exact replays,
and two quiet integrated timing sessions. Build the injected probe using
`ancestor_storage/check_failures.py`; each archived .gpr records its exact flags.
The release case uses the same FLAGS as this directory's build.py and LTO linker
flags. Replay its inputs with `ancestor_storage/replay.py`.
The candidate was retained only as a proof prerequisite because the six-slider
workload regressed in both sessions; see `solver-buffer-performance-summary.json`.
`solver-buffer-bit-equality.json` checks the serialized final binary64 values.
`solver-source-review.zip` contains a reproducible algorithm-level comparison
after expanding the exact helpers; it is not a binary-equivalence proof.
`solver-inline-trial.zip` tests the same candidate with only one additional
Inline_Always pragma. Both checked-policy replays and release fault injection
pass, but two quiet sessions show worse medians throughout (63/66 CI95 above1).
This second form is also NOT adopted; its separate summary is
`solver-inline-performance-summary.json`.

`crb-step-composition-evidence.zip` adds four closed exact-step lemmas (72 checks)
and the distinct incomplete full-loop result (69/77). The old controlled model
is preserved; the active CRB numeric guard is unchanged.
`crb-initialization-checkpoint.zip` adds a closed initialization projection lemma
(4 proof +1 flow) and a targeted caller attempt (1/2: precondition closed, initial
model equality still open). It does not establish a new complete-loop result.

`mass-publication-split-followup.zip` preserves the closed ready-branch wrapper
(6/6), fresh equality helper (22/22), and the still-open outer wrapper (4/5).
`configuration-image-followup.zip` is a separate exact ghost-model refactoring
(64/64, including total equivalence with empty states). It did not close the
outer frame and is not adopted globally. Neither archive establishes the
original mass producer or authorizes removing scans.

`spatial-motion-composer-evidence.zip` closes the exact write/body helpers
(20/70/62 proof checks) and Build_Buffers (66 proof +4 flow, safety/bounds scope).
It retains the earlier centers proof, storage dependency receipts, an independent
source review and the unfinished Prepare wrapper (100s timeout, no checks
emitted). Final numerical validation is624 scenarios/168,192 comparisons in
Compatible; the runner's14 Strict policy cases are listed separately and must
not be described as a full Strict run. The source remains an isolated candidate;
no additional scan removal or speedup is attributed to it.

`spatial-prepare-closure.zip` supersedes the preceding Prepare timeout for its
new, isolated source snapshot. Prepare_Buffers closes 34 proof +3 flow and the
unchanged-public-contract Prepare wrapper closes 8 proof +20 flow. The complete
MJ.Data.Spatial run closes **391 proof +55 flow**, including those local checks;
do not add the counts again. The successful run adds Z3 to a whole-unit run on
identical sources using its valid proof cache; both commands/results and the
earlier timeout are retained. `spatial-prepare-closure.json` states exact scope,
source continuity and the remaining global functional-model gap. Both Strict
and Compatible now pass 624 scenarios/168,192 comparisons each on the same checked
probe. The additional exact-inertia-model experiment is separate and unfinished.
No runtime source is adopted or scan removed; integrated timing is still pending.

`crb-model-continuation.zip/json` closes the selected model-initialization
obligation and records a new complete Accumulate_Composite attempt: **79/83 proof,
3/3 flow**. Its ghost witness is the canonical recursive model state; original
model formulas and exact-step lemma are unchanged. Four obligations remain:
step-sum bound, weighted-bound preservation, model-equality preservation, and
final equality. Later composition attempts timed out; the working candidate is
restored to the exact 79/83 source. The nine proof records of the line-scoped
initialization receipt are not a whole-loop count; its file-wide flow also
retains an unused-assignment warning. Additional local equality/projection
lemmas and the 13-check scalar-sum lemma are recorded separately from the
unfinished composition. No active CRB guard or readiness scan is removed.

`crb-accumulation-closure.zip/json` supersedes the 79/83 accumulation checkpoint:
the complete Accumulate_Composite subprogram now closes **99 proof +3 flow**,
including all invariant initialization/preservation, helper-call preconditions
and the original exact final model postcondition. Eight new, separately proved
ghost lemmas close 163 proof +8 flow. Preconditions, postcondition, original
checked model and normalized executable statements are unchanged. Reused
dependency receipts and matching source bodies/contracts are included; no
Assume or new suppression is introduced. The intermediate 97/100 result and
timeout are retained separately. `closed-source` is the successful candidate;
`metadata/from-79of83.patch` applies to that previous isolated candidate, not
directly to the active simulator.

Both policies pass 624 scenarios/168,192 comparisons on the final checked probe,
including the additional CRB and 24-DOF fixtures. Earlier 360-scenario runs are
explicitly smaller preliminary checks. This theorem covers composite inertia
accumulation under its unchanged input bounds, not full mass assembly or whole
dynamics. The active mass producer/callers and integrated performance still
require validation before runtime adoption; all 100 active-source hashes match,
and the active CRB numeric guard and three internal readiness scans remain.

`crb-callers-closure.zip/json` connects the closed spatial preparation and
composite accumulation to Load_Composite, Zero_CRB_Mass, Fill_CRB_Mass and
Try_Assemble_CRB: 78 proof +8 flow, no open checks. It retains the incomplete
outer assembly/pipeline attempts separately. The following checkpoint
supersedes those incomplete composition results for its new isolated source.

`mass-frame-closure.zip/json` closes the current full contract of
Inertia_Phase.Assemble and the composition of Evaluate_Ready, including public
state preservation. It separates and proves CRB, dense, Jacobian and mass
publication helpers, with unchanged public preconditions. The private
Ensure_Jacobians contract gains proved Static mass-preservation guarantees.
The 21 accepted scopes total **459 proof +69 flow, zero open**; this includes
existing kernel dependencies rechecked, not 459 new functional theorems.
The whole Mass_Publication count already includes Mark_Ready. Earlier unchanged
CRB/spatial proofs and the final four-caller integration rerun are not added to
that total. Each successful body/contract is matched to the final candidate;
the fresh final caller run uses exactly the numerical build's source hashes.

Strict and Compatible each pass **624 scenarios/168,192 comparisons** with
atol=rtol=2e-10, including the additional CRB, branch and fallback fixtures.
`candidate-source/` is the complete candidate; `metadata/REPRODUCE.md` describes
the 67 proof reports and reconstruction of immutable snapshots from 158
deduplicated source objects. Failed, timed-out and superseded trials remain
separate and do not count as passed proofs. All reports, numerical results,
checked probe, source review and per-file checksums are archived. The local
resume point is `/var/tmp/sparkling-mass-frame-20260927/source`.

This closes the current safety, bounds, symmetry, publication and state-frame
contracts under the called contracts. The full ordered mass-construction model
and the other dynamics bodies remain separate work. Source review preserves
phase order and dense floating-point order under the proved storage/index
contracts; helper boundaries, flag rewrites and candidate lifetime changed.
It is not binary or timing equivalence. The C reference remains MuJoCo 3.14.0.
No new Assume, suppression or deallocator/warning changes were introduced.
The candidate is **not active**: all 100 active-source hashes still match,
the CRB guard and three internal Phase_Ready scans remain, and two quiet
integrated timing sessions are still required before adoption. No new speedup
is claimed. Resume from the remaining model/dynamics/adoption work, not the
now-closed assembly and pipeline composition checks.

`force-entry-scan-adoption.zip/json` supersedes the preceding non-adoption
status. Forces_Phase.Compute now requires Is_Ready at its private boundary;
both callers prove that precondition. The selected replacement assertion and
its precondition close 2 proof checks, with 13 file-level flow checks. Five
complete caller subprogram checks close 50 proof +10 flow. These are not a
whole force-unit proof. The rest of the mass-frame candidate is byte-identical
and reuses its recorded proof scopes. Nesting temporary-buffer publication
under the producer branch resolves the previous initialization diagnostic
without runtime initialization, assumptions or suppressions. Public contracts,
existing reviewed warnings and deallocators are unchanged.

`check_force_boundary.py` builds checked or release probes from the recorded
candidate, including explicit checks of empty/stale states and corrupted
inputs/caches/configuration. Each build passes 26 scenarios/7,008 comparisons
under each policy. Corrupted data violates Valid_State: checked builds reject
it at the public precondition, while release builds return Not_Allocated via
the preserved explicit guard. The first test draft incorrectly expected a
return in checked mode; its failure is retained separately from the corrected
test. The normal checked probe passes 624 scenarios/168,192 comparisons per
policy. Instrumentation confirms one public and two private scans per step on
11 models, with identical release outputs; its timings are never benchmarked.

`force-entry-scan-performance.json` records two independent integrated sessions
with 11 models, three scenarios each, 24 alternating blocks, four 100-step
trajectories per block, CPU 12, baseline/current/normal SIMD C. Every case has
a paired ratio CI95 below 1 in both sessions; intervals are per case and not
adjusted for multiple comparisons. Raw dispersion and trajectory-average tail
timings are retained. There is no global mean or summed speedup. Numeric final
Ada outputs match with maximum absolute difference zero. The C reference is
still MuJoCo 3.14.0; performance parity is not yet reached.

Adoption also brings in the proved CRB accumulation guard replacement and the
previous mass/spatial refactoring, so do not attribute all gains to one scan.
The old 100-file manifest is preserved as
`pre-force-entry-scan-active-source-match.json`; the current manifest covers
106 files and identifies the measured release binary. Full ordered mass and
dynamics models remain pending, and mass assembly still materializes the dense
matrix before compact factor gathering. Resume from the force-body readiness
guarantee needed before actuation, then acceleration/solve before Euler.


`scan-parity-adoption.zip/json` supersedes the preceding two-private-scan status.
The supported release Euler.Step now executes zero whole-Simulation readiness
rescans (previously one Is_Ready plus two Phase_Ready). This matches the absence
of equivalent global model/cache rescans in C, not every numerical or API check.
The public Valid_State precondition is unchanged. Boundary.Ready proves that
Allocated is sufficient under it; private actuation and Euler solve callers
establish Is_Ready without rescanning.

All 88 required local scopes have complete receipts and matching interfaces;
the final whole Euler unit closes160 proof + 31 flow with zero open checks.
The archive preserves failed attempts separately, exact body/interface audits,
immutable proof snapshots, and the unchanged earlier mass/CRB dependencies.
No new assumptions, suppressions or trusted bodies are introduced. Full physical
dynamics and the complete ordered mass-construction model are separate work.

The frozen checked/release candidate shares 108 source hashes with the adopted
runtime. Both policies pass 624 scenarios/168,192 comparisons. Four checked/release
Step/Forces boundary probes each pass 26 scenarios/7,008 comparisons per policy.
Predicate-level instrumentation counts 0+ 0 on 11 models × 400 steps, with identical
release outputs; its positive baseline control counts 1+ 2. Corrupt Step inputs
outside Valid_State are checked only with runtime contracts enabled; release
callers must satisfy the unchanged public precondition. The private stale-mass
implicit-damping case returns Stale_Results and is explicitly covered.

Two quiet integrated sessions (33 cases, 24 alternating blocks, four 100-step
trajectories per block,CPU 12) show 17.8–41.7% less time than the preceding Ada
runtime. Every paired CI95 is below1 in both sessions; intervals are per case,
without multiplicity correction. There is no average of percentages. The C
ratios still vary by workload, about 0.72–1.70. Inputs remain fixed during each
trajectory, with setup/reset/I/O outside timing. Recorded p95 values describe
trajectory-average step cost, not individual-step tail latency.

The106-file baseline manifest is retained as
`pre-scan-parity-active-source-match.json`; `active-source-match.json` records
the 108 adopted files. `scan-parity-performance.json` retains per-case intervals,
absolute times, tails and numerical differences. Dense mass construction before
compact gathering remains; zero readiness scans alone does not imply C timing
parity. See the final section of docs/gold-performance-adoption.md for the table.
