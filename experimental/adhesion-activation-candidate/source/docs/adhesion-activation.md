# Body adhesion and scalar activation integration — 2026-09-30

Reference: official stable MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`; latest release checked again on
2026-09-30 through the official GitHub release API.

This is an isolated implementation based on repository commit
`b6f47c98098d0e2fbecba674a91e58b1ba5e2189`. Work in the primary conversation
continued after this snapshot. Integrate the patch with a three-way review;
replacing the primary conversation's files wholesale is inappropriate.

## Implemented

`MJ.Activation` and the smooth pipeline support `integrator`, `filter`,
`filterexact`, activation limits, `actearly`, compact mixed stateful/stateless
activation indexing, owned activation state, reset, and Euler commit. Control
clamps precede derivative evaluation. Next activation is prepared once and
committed only after a successful physical step. Current force can still be
evaluated when an invalid future activation has `actearly=false`; Euler rejects
that future state. Disabled actuation freezes activation. The existing stateless
fast path remains. Tau flooring and exact-filter factors are prepared at Create,
not recomputed each timestep. Existing warnings/deallocation models are retained.

`MJ.Adhesion` implements the body transmission from `mjTRN_BODY` in
`engine_core_smooth.c`: rigid contacts involving either target body are selected;
flex contacts and exclusions 2/3 are skipped; active condim-1/elliptic contacts
select their normal row; pyramidal contacts select 2*(dim-1) rows weighted
0.5/(dim-1); gap contacts (exclude=1) contribute the normal projection of the
point-Jacobian difference. Active rows and gap contributions are accumulated
separately in reference order, then added and scaled by -1/contact_count.
The body transmission length is zero. `Apply_Force` projects a scalar force onto
arbitrary generalized coordinates.

The generic kernel consumes assembled constraint rows and projected gap
Jacobians. Their construction remains the contact/Jacobian assembler's
responsibility; no unimplemented general contact engine is silently enabled.
Limits: 1,024 contact descriptions and 10,240 constraint rows, finite Jacobian
entries within the existing Tier0 domain. Dense projection currently traverses
columns for proof modularity; general transmission performance is unmeasured.

`MJ.Adhesive_Slider` connects adhesion, scalar activation and force/control
limits to the existing one-slider, sphere/plane frictionless contact solver and
Euler integrator. It applies the actuator force before solving the contact,
including gap contacts which do not have an active constraint row. The one-row
Jacobian J=1 permits an exact scalar transmission specialization. Rejected
steps preserve height, velocity, time and owned activation. This API is an
integrated executable example, not a claim of full-model contact integration.

The generic body transmission and activation preparer are independently usable
for multiple DOFs. The unconstrained smooth pipeline still rejects body
transmissions: enabling them there without supplying contacts would lose forces.
The geometric/contact `adhesion` parameter is a separate MuJoCo feature and is
outside this body-actuator implementation. Muscles, PID/DC motors, plugins,
history/delay and non-Euler physical integration remain outside the imported
three-type scalar activation scope.

## Evidence and assurance

The accompanying report records fresh evidence against the exact saved sources.
Small subprograms are proved first; accepted complete-unit evidence must contain
all entities, no skipped proof/flow, no assumptions and no unproved messages.
Gold here concerns the floating-point algorithm and state integrity under its
contracts. Numerical comparisons to C are distinct from formal proof and from
real-arithmetic accuracy. Ghost lemmas establish value equality through
reductions/normalization, including floating point's signed-zero distinction;
there are no new assumed lemmas or trusted project bodies.

`Exact_Factor` retains an open runtime `exp_no_overflow` obligation at the
standard elementary-function boundary, even with a nonpositive argument in
[-40,0]. Its contract currently bounds the decay factor, rather than proving a
real-exponential accuracy theorem. This is explicitly unfinished verification;
it is not a blanket Silver exception for floating point. The three activation
update laws and their preparation contracts are proved separately. Global
creation/reset/phase/Euler ownership composition must not inherit a full Gold
claim from scoped proofs.

The scalar coupled evaluator additionally checks finite force and total applied
force against Tier0. C can continue outside these bounds. Numeric_Limit is the
prototype's deliberate policy; the failure-state preservation is tested and
specified. The generic force projector permits the wider existing Tier3 domain.

Performance reports include native optimized C with normal SIMD, alternating
order and raw samples. The specialized scalar contact comparison versus full
C mj_step is not general simulator parity. The 24-DOF smooth chains with one
actuator per joint retain a measured regression; those results are reported,
not hidden by faster actuator-heavy cases. Measurements ran on a shared host.
