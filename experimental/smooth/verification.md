# Verification scope and acceptance criteria

The target is SPARK Gold for useful functional properties, on top of runtime
safety. A failed or unfinished proof is **pending**, not Silver coverage. No
mathematical Silver-only exception is approved for this directory.

## Contracts in the current subset

| Component | Functional obligations |
| --- | --- |
| Vector arithmetic, dot, cross | Exact specified floating-point expressions and evaluation order, plus finite arithmetic bounds |
| Matrix/vector application | Exact three-term row or column reduction |
| Quaternion product and rotation | Scalar-first Hamilton expressions and specified rotation entries |
| Axis-angle | Composition with the supplied Ada runtime `Sin`/`Cos` contracts |
| Normalize | Successful result satisfies the approximate-unit predicate; rejected input is unchanged; exact specified scaling and scaled-norm composition |
| Flat vector access | Selected components are copied exactly; writes preserve every other component |
| Create/free | Owned snapshot, initialized ready state on success, empty on ordinary failed creation, already-created state preserved, free is idempotent |
| Reset | Reference positions, zero velocities/time/inputs, invalidated derived results |
| Set state/control/applied force | Exact requested values, preservation of other inputs/state, invalidation and atomic rejection |
| Getters | State round-trip, output dimensions and freshness, defined zero outputs on failure |
| Kinematics/mass/forces/actuation | State/input preservation, successful cache validity and exact assembled mass symmetry; independent functional models of the full recursions remain pending |
| Forward | Preservation of state/time/inputs, with pose and acceleration available on success |
| Euler | One timestep on success, input preservation, invalidated caches, exact preservation of state/time on returned failure |

The public `Valid_State` precondition accepts default/freed simulations and
successfully created simulations. A half-allocated object after `Storage_Error`
is outside normal API use and can still be passed to `Free`. This does not
restrict supported physical configurations or successful lifecycle operations.

`Is_Ready` includes dimensions/layout, state ranges, parent/joint indexing,
normalized configuration orientations/axes, and conditional actuator limits.
These are executable contracts; writing them does not establish their proofs.
`Unevaluated_Use_Of_Old (Allow)` permits safe, total value queries to be captured
at entry even when their use in a postcondition is conditional. It does not
disable a check, assume a property, or hide a body from GNATprove.
`At_Reset_State` states reset's value requirements directly for each buffer.
This is equivalent to the reference-position/zero-state image requirement;
it avoids an unnecessary concatenation model inside the lifecycle proof.

## Recorded evidence (2026-09-23)

The full `MJ.Smooth_Math` unit completed GNATprove with **645 proof checks and
57 flow checks, zero unproved checks and zero analysis errors**. This includes
its functional expression contracts, array frame properties and normalization
accept/reject behavior. The immutable run is named
`smooth-math-complete-check`; retain its `manifest.json`, `results.json` and
raw logs when reviewing or reproducing the result. Its complete-unit scope is
stronger than the earlier per-subprogram screening runs.

Focused proofs have also closed `Reset` and its exact `At_Reset_State`
predicate, state setters/getter, input setters, buffer clearing and explicit
release, on the recorded per-run snapshots. These are useful lifecycle
properties. They remain modular results: creation, the remaining getters,
derived caches and the dynamics bodies still need their own closure and a
complete integration run.

This result does **not** establish Gold for `MJ.Data` or its dynamics children.
Their remaining obligations are proof-engineering work, not documented
mathematical exceptions qualifying for Silver. In particular, complete
configuration/lifetime preservation, recursive dynamics bounds and functional
models of assembly/factorization remain pending. No whole-subset assurance
level is assigned while these obligations are open.

The remaining closure work must retain useful functional specifications:

1. Finish creation, allocation and cache invariants, preserving the owned model
   configuration across every phase. Complete-unit `MJ.Data` analysis exceeded
   the bounded job's 2 GB resource limit; this is an incomplete analysis.
2. Specify and prove pose/Jacobian recursions over the ordered body tree,
   including intermediate bounds and each helper precondition.
3. Specify mass, gravity, velocity bias and passive/actuator force assembly as
   rounded computations, and prove their loops and phase transitions.
4. Complete LDL/triangular-solve invariants and the solver's rejection behavior;
   separately establish useful residual or error bounds under explicit
   conditioning assumptions. Current conditioning thresholds are policy.
5. Complete the composed forward/Euler contracts, including the update formulas
   and every failure path, then rerun complete-unit/integration analysis.

None of these pending items is recorded as a Silver mathematical exception.

The separate C-oracle suite currently covers 480 scenarios and 45,120 scalar
comparisons, seven normalization edge cases and twelve status/policy cases.
It also exercises empty arrays, nonzero array lower bounds and short arrays
ending at `Natural'Last`. These tests do not turn an unfinished formal proof
into a pass or prove equivalence for every permitted model.

## Mathematical and runtime boundaries

- Floating-point formula equality is separate from exact real arithmetic.
  No associativity, exact rotation orthogonality or exact unit norm is assumed.
- `Unit_Vector` and `Unit_Quaternion` use the implemented rounded norm-squared
  test with tolerance `64 * Real'Model_Epsilon`. Successful normalization checks
  this predicate at runtime. A proof of that checked implication is narrower
  than an a-priori approximation/error analysis for every accepted input.
- `Sin`, `Cos` and `Sqrt` use the supplied Ada runtime contracts. Exact identities
  such as `sin(x)**2 + cos(x)**2 = 1` are not valid binary64 specifications.
  Useful error bounds and conditioning-sensitive residual properties still
  require proof work; floating point itself is not an excuse to stop at Silver.
- The dense LDL condition estimate and acceptance threshold are policy, not a
  certified bound on acceleration error. The tests cover uniform small scale,
  rank deficiency and two ill-conditioned configurations; they do not cover all
  allowed matrices or establish universal C equivalence.
- Typed Ada inputs and successful allocation are part of the boundary. Raw
  foreign memory validation and `Storage_Error` cleanup remain outside the
  ordinary status contract and are explicitly pending lifetime work.
- GNATprove assumes called contracts during modular proof. A passing caller
  fragment cannot establish whole-program safety while a callee or precondition
  obligation remains unproved. Full unit/integration results must accompany a
  complete-subset claim.

## Reproduction

Run with a Python environment containing `mujoco==3.14.0` and NumPy:

```sh
python experimental/smooth/tools/compare_numerics.py \
  --report-dir /tmp/smooth-numerics-new --samples 32 \
  --toolchain-root /path/to/native/toolchains
```

The report directory must be new. It records the C library hash, Ada source
snapshot, compiler command and flags, executable hash, fixture inputs, raw probe
outputs and comparison results. A successful report must have `status: passed`,
nonzero comparisons, no failures, and completed policy tests. The checked build
uses `-gnata -gnato -gnatVa`; it is not a performance benchmark.

Start proofs at the smallest failing subprogram, then check whole units:

```sh
python experimental/smooth/tools/prove_fragments.py \
  --whole-unit mj-smooth_math --report-dir /tmp/smooth-math-proof-new \
  --toolchain-root /path/to/native/toolchains \
  --provers altergo,cvc5 --level 2 --steps 0 --prover-seconds 5 \
  --jobs 2 --wall-seconds 240 --prepare-seconds 240 --total-seconds 250
```

Retain source hashes and raw `.spark` diagnostics. Count safety, assertions,
functional contracts and flow separately. No generated checks, a timeout or a
partially completed sweep is never a proof pass. A remaining diagnostic must be
closed or explicitly listed as pending; it cannot be reclassified as a
mathematical limitation merely because increasing prover effort did not help.

## State invariant investigation (2026-09-24)

The private `Ready_Flag` query proves equivalence to `Is_Ready` under the existing
`Valid_State` precondition (one proof check, two flow checks, no open checks).
It does not establish validity or replace active runtime guards. Seven repeated
readiness scans were isolated in a full-step performance experiment; promotion
still requires closure of state preservation across the dynamics phases.

The best recorded `Euler.Integrate` diagnostic on the final source proves
54 of 55 checks and all ten flow checks. Input preservation remains open;
configuration preservation closes with progressive splitting. Added ghost
assertions preserve the original contracts and runtime behavior. These are
subprogram results, not complete-unit or whole-pipeline Gold. See the
[state/performance report](../../docs/state-invariants-performance.md) for exact
snapshots, incomplete attempts and measured scope. Empty check selections now
return a nonzero exit status in the proof runner and cannot be treated as passes.
