# Phase closure: two redundant scans removed

2026-09-25. This change builds on the pose-tree verification milestone. The
frozen baseline includes that working-tree milestone; it is not the older Git
HEAD. The MuJoCo oracle and timed C reference are 3.14.0.

## Accepted runtime changes

`MJ.Data.Inertia_Phase.Assemble` now requires `Is_Ready` and replaces its
runtime `Phase_Ready` rejection branch with a proved Static assertion. Its two
callers establish the stronger precondition:

- `MJ.Data.Inertia.Assemble` explicitly checks `Is_Ready` at the public boundary.
- `Pipeline.Evaluate_Ready` calls `Update_Poses`, whose complete subprogram
  proof has been rerun successfully, and returns immediately on failure.

The readiness equivalence of `Phase_Ready` was also reverified. Both callsite
preconditions and the removed branch's condition are proved. The remaining
body of mass assembly is unchanged, including stale-result and numeric-limit
paths. This proof justifies removing its entry guard; it does not establish
mass assembly's postconditions or justify removing the following force guard.
No new assumption, suppression, or trusted body was introduced.


`MJ.Data.Actuation_Phase` is split into the guarded entry and `Compute_Ready`.
The original functional and frame contracts are preserved. Static snapshots
make preservation of configuration, position and velocity explicit to the
prover; `Inline_Always` keeps the helper inline in optimized builds.

`Inertia_Phase.Solve_Acceleration` also requires `Is_Ready`. Its public wrapper
checks this directly, while the internal pipeline exits on failed actuation
and otherwise uses the proved successful-readiness postcondition. Its entry
scan is replaced with a proved Static assertion. All freshness checks,
force-domain checks, factorization policy and Euler checks remain.

This is a modular refinement under the existing stable-layout/configuration
contracts. The full mass and force bodies preceding actuation still have open
proofs. The removed scan checked only mutable inputs/caches, so it did not
establish those stable facts either. This change does not claim a complete
proof from simulation creation through every step.

The public full check remains. Instrumentation on 11 integrated movement
models, 400 measured steps per model, confirms one full check and **three**
mutable phase checks per step (previously five). Instrumented and normal
release state/time outputs are exactly equal. Instrumentation timings are not
used as performance measurements.

## Formal scope

| Evidence | Result | Scope |
| --- | --- | --- |
| `accepted-pose-caller` | 133 proof checks, zero open | Complete `Update_Poses`; prerequisites also recorded in the preceding tree milestone |
| `accepted-phase-ready` | 1 proof check, zero open | Mutable/full readiness equivalence under stable readiness |
| `accepted-entry-callers` | 8 proof checks, zero open | Four callers and both removed guard conditions; selected lines only |
| `accepted-actuation-final` | 81 proof checks, zero open | Whole actuation phase: successful forces and preservation of configuration/state/inputs |
| `actuation-kernels-complete` | 173 proof checks, zero open | Whole `MJ.Smooth_Actuation`, including force-law and ordered reduction contracts |
| `actuation-leaves` | 37 proof checks, zero open | Transmission, control clamp, affine force, projection, Euler scalar and equality helper |
| `euler-baseline` / `Stage_Euler` | 31 proof checks, zero open | Staged semi-implicit update and failure behavior |
| `mass-solver-kernels` / `Damping_Present` | 9 proof checks, zero open | Exact existential damping predicate |

Rows identify separate proof scopes; retries and overlapping earlier results
are not additional proved obligations. Flow counts emitted for whole units
by selected-line runs must not be summed as independent evidence. Full proof
reports retain every pending result rather than counting timeouts as passes.

The accepted code still has these open areas:

- Euler `Integrate`: preservation of readiness, configuration and inputs;
  the staged numerical kernel is proved separately.
- Ancestor factor loading: state/frame preservation obligations remain.
- Spatial preparation, recursive forces and CRB assembly: bounded individual
  subprogram attempts hit the wall timeout; these require smaller helpers and
  explicit loop/frame invariants. They have not been marked proved.
- Full force, mass and solve composition, including all fallback paths, remains
  outside the complete proof scope.

These are unfinished proof-engineering obligations, not mathematical
exceptions allowing a Silver-only completion claim. Earlier unsuccessful actuation/Euler experiments are archived separately;
only the final actuation split is included in the accepted code. Euler
experiments were not integrated.

## Numerical checks

Checked executable `c7263a55374aff4c4083c877faa4621495e695fec93044e1f08c23e79fd8cdb2`:
624 scenarios and 168,192 comparisons in each of Strict and Compatible mode,
26 models, zero failures, tolerance `atol=rtol=2e-10`. The reports also retain
seven normalization edges and 14 policy tests (the policy-test block runs in
Strict mode in both invocations). Numeric-limit/fallback and rejection behavior
are retained. These are differential tests, not universal equivalence proofs.

## Integrated performance

Two independent sessions, 24 randomized blocks per session, 11 models and
three initial states each: 4,752 timed processes and 1,900,800 measured steps.
Each measured process integrates four 100-step trajectories; input/output and
model preparation are outside the timed region. No proof or build ran during
these sessions.

The final-state outputs are exactly equal between current and prior Ada in all
recorded cases. Every one of the 33 within-session paired 95% bootstrap intervals
for current/prior time is below one in both sessions (66/66 intervals).
These are per-case intervals, not multiplicity-adjusted simultaneous intervals.
Model ranges below span the medians of three initial states in both sessions.
All cases improve; none reaches C parity. These are improvements in complete
supported movement workloads, not an average of isolated kernel improvements.

| Model | Total time saved vs prior Ada | Current / C |
| --- | ---: | ---: |
| `hinge_motor` | 18.0–19.2% | 1.12–1.13× |
| `branched_multijoint` | 12.1–14.4% | 1.53–1.55× |
| `chain_12` | 9.5–10.6% | 1.95–2.00× |
| `crb_no_damping` | 12.4–14.5% | 1.95–1.98× |
| `crb_chain_24` | 7.8–9.5% | 2.00–2.01× |
| `ancestor_star_24` | 11.6–12.3% | 2.56–2.63× |
| `ancestor_forest_24` | 10.0–11.1% | 2.30–2.36× |
| `ancestor_branches_24` | 9.2–10.5% | 2.29–2.32× |
| `simple_hinges_6` | 15.6–16.2% | 2.51–2.56× |
| `simple_sliders_6` | 17.5–18.5% | 1.54–1.56× |
| `simple_mixed_8` | 14.0–15.5% | 1.64–1.66× |

Maximum absolute Ada/C discrepancy in the timed workloads:
`3.8913317013111737e-14`. Raw timing samples, dispersion/tails,
confidence intervals, source/compiler/hardware metadata and all fixture inputs
are in the recorded session archives. No workload-frequency distribution was
assumed to turn the table into a universal average speedup.


## Evidence and reproduction

`tests/phase_closure/evidence` stores the proof reports/logs, source objects
indexed by SHA-256, build manifest, checked numerical reports and guard counts.
`proof-index.json` includes unsuccessful experiments with explicit statuses;
only the scopes in the table above are accepted proof results. The prior
[tree evidence](tree-invariants.md) supplies the unchanged proved callees of
`Update_Poses`.

The proof runner's exact commands and budgets are in each `results.json`.
Always start with a minimal subprogram or selected line and use `--steps 0`;
use a whole-unit run to close an intended unit after the fragments pass.
Reproduction of the build, integrated measurements and guard counts is in the
[benchmark README](../tests/movement_performance/phase_closure/README.md).
