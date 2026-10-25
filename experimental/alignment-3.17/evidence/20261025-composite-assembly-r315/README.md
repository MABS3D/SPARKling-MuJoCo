# Local CRB composite assembly r315, 25 October 2026

No commits or pushes. The official stable release was rechecked as 3.17.0,
commit `800a109a4bdd02cb60404d565db4ae16fb04a53b`; production remains 3.14.

Composite_Assembly is extracted from the existing Inertia_Phase and reused by
that hot path and the raw native shared-mass reader. Loading is component-exact.
Accumulation traverses bodies in descending order and skips the world parent,
with the same rounded parent additions as the reviewed C algorithm. Under its
unchanged input bounds (up to 4096 bodies, initial components bounded by 1e36),
weighted ghost budgets prove every intermediate is bounded by 1e40. Its exact
recursive floating-point model is proved, including the non-failure flag.
This justifies removing the reader's redundant per-parent bound check.

The complete common unit closes **479 checks: 450 proof and 29 flow**, with zero
open obligations, assumptions or skips. Twelve diagnostics remain: eight integer
operator-reassociation warnings in the extracted model/lemmas and four recursive
contract/numeric-variant warnings in the accumulation model and Composite_Weights.
No warning was suppressed. obligations_closed=true; strict passed=false.
The claim is exact behavior of this bounded rounded algorithm under its callee
contracts, not a real-arithmetic identity or a proof of all simulation physics.

Minimum scopes preceded the unit. Recorded successes include Model_Step 14,
Accumulation_Model 17, Load_Composite 24, widening 4, bound initialization 13,
accumulator 110, equality of bounds 4, equality of inertia sums 28 and model-step
update 43 checks. These are not added to the whole-unit count. Hiding spatial
bound predicates made the context manageable; separately proved ghost lemmas
supply widening and equality facts. No precondition was narrowed.

Earlier 600-second per-check/progressive unit attempts are retained. A single
CVC5 full-unit pass completed with 458 proved and 21 open checks, which was not
accepted. The final full unit uses CVC5/Z3/Alt-Ergo, three seconds/650 MiB per
prover, two workers under a 2500 MiB group cap and 600-second wall cap. It completes
in about 320 seconds with approximately 531 MiB peak group RSS. The two helper
minimum proofs exposed and resolved the actual difficult contexts.

The raw reader now has an exact single-cell assign/add/error-frame contract and
its acceptance flag is local. Its minimum closes 11 checks. A ghost readiness
bridge closes eight checks connecting body topology and spatial slabs to the
common component. However the complete Gather_Shared minimum still exceeds its
240-second aggregate cap. Its full row/tendon functional model and physical
pattern-to-simulation binding remain open. Shared-buffer derivative dynamics is
still explicitly unsupported. No whole Data.Native_Mass/workspace proof is claimed.

Both validation and release on final library sources pass:

- C3.17: 288 raw mass states with zero difference, 960 original derivative samples,
  and 960 reordered derivative samples per profile.
- C3.14: 132 raw states and 960 derivative samples per profile, at prior tolerances.
- Four malformed-model and five output-shape scenarios per profile/version.
- Five new composite boundaries: one body; maximum-size chain, star and forest
  using independent exact power-of-two subtree counts; and cancellation that
  distinguishes descending rounded order from reassociation.

All 329 Ada files of the final formal snapshot match the final C3.17 runtime
closure. Python benchmark-driver revisions are recorded separately. The reordered
oracle remains original C plus a checked Mq-column bijection; the earlier direct
C reordered-storage crash and duplicate-tendon compiler rejection are not hidden.
New 3.17 actuator-reflected armature remains unsupported by the simulation
admission guard, rather than silently treated as fully ported.

## Integrated movement evidence

The new native Ada/C harness supports different nq/nv dimensions (ball/free),
passive and applied forces, controls and body force/torque. Ten models and three
states each include tendons and 24-DOF chain/branches. Every timed result is checked
against C at atol/rtol 2e-10 and baseline/current Ada values must be exactly equal.
Reset, loading and I/O are outside timing. Six balanced orders over 24 blocks,
four samples and 100 evolving Euler steps are used, with two warmup trajectories.
CPU affinity is 12. Proofs and builds are idle during timed sessions. Raw inputs,
outputs, commands, medians/MAD, paired bootstrap intervals and trajectory-mean p95
are retained; p95 is not individual-step latency. Intervals are within-session,
without multiple-comparison correction. No arbitrary percentage is called noise.

Ada uses O3, native architecture, front-end inlining and ffp-contract=off. Language
checks stay enabled; gnatp and unsafe FP flags are absent. C calls native mj_step
from the official 3.17 wheel. Its library build flags are unknown: comparisons are
diagnostic and cannot certify final matched-build C parity. The shared raw reader
is not on this stepping path. This measures the common-accumulator integration,
not a speedup of the raw shared reader itself. Contacts/constraints, sensors,
rendering and activation-state models remain outside this timing workload.

Two initial sessions exposed a repeatable roughly 4% free-joint regression after
the extraction, despite exact Ada results. Assembly inspection shows substantial
address/padding differences with equal instruction counts in CRB and publication.
A same-final-source comparison of default versus 32-byte function/loop alignment
improves free-joint timings about 5% in both sessions; other model changes are
small or uncertain. Direct comparison of original baseline against refactoring
plus alignment includes one free_ball state slower in one session. **Global
release flags remain unchanged.** The aligned build is preserved as a candidate,
not declared universally superior or a completed regression fix.

The supported movement remains materially slower than C: roughly 1.4x on the
single hinge, 2x on free, and 3.9x on the 24-DOF chain in the recorded wheel
comparison. Zero/single/dense body-load variants retain the same deterministic
initial states and controls, but evolve different trajectories; their timing
difference is a workload counterfactual, not exclusive phase attribution. Much
of the 24-DOF chain gap remains even without external loads. No unweighted mean
of model speedups is used as an overall acceptance result.

The first paired-build measurement failed while locating fixture providers in
an alias-only build directory. The corrected runner resolves them from the
actual binary's source tree; the failed attempt remains. Current runner versions
also independently verify source manifests around timing. An independent archive
reread verifies manifests for every earlier measured build, as well as binaries
and C library hashes; earlier report field names alone are not treated as proof.

Remaining work includes complete shared-reader/workspace/physical-cache binding,
full stable engine/API migration and supported features, comparable native C
builds with documented flags, and representative integrated performance parity.
The global port goal remains open. This checkpoint is bounded functional progress,
not completion of MuJoCo or a mathematical Silver exception.

The ZIP includes snapshots, all retained failed attempts, raw numerical and timing
records, exact commands and the actual proof runners. Compiler/proof caches are
excluded; executables and libraries are hashed as untimed local omissions. The
verification rereads every ZIP member and preserves all previous inventory entries.
