# External body forces and torques

The experimental hinge/slide pipeline accepts world-frame forces and torques
at body centres of mass through `MJ.External_Forces.Wrench_Array`:

```ada
Loads : MJ.External_Forces.Wrench_Array (0 .. Body_Count (D) - 1);
-- All components default to zero; force is in N, torque in N m.
Loads (Body_Id).Force (2) := 10.0;
MJ.Data.Forward.Evaluate (D, Result, Loads);
MJ.Data.Euler.Step (D, Result, Loads);
```

These are **per-call inputs**. Pass the same array at every step to maintain a
load; omitting it means no body loads for that evaluation. They are not retained
by `Simulation`, included in `Input_Values`, or reset by `Reset`. Existing
`Set_Applied_Forces` remains the independent generalized-DOF force input.
`Get_Acceleration` returns the last evaluated acceleration, including that
call's loads. Editing the caller's array does not invalidate the simulation
cache automatically: call `Evaluate` again to publish the changed acceleration.
A nonempty array must start at zero and contain exactly `Body_Count (D)`
elements; otherwise the public call returns `Invalid_Size` before updating any
cache or state. Any empty array means no loads. Body zero is the world and its
load is ignored. Each component uses the existing finite `Tier0_Real` domain.

The torque is specified **at the body's centre of mass**, expressed in world
axes; it is not a body-frame vector or a torque about the world origin. To apply
a force at another point, first add `(point - body_COM) × force` to its torque.
An out-of-domain derived value returns `Numeric_Limit`; failed Euler steps
preserve qpos, qvel and time, although derived caches may have been recomputed.

## C algorithm and integration

Reference: MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`,
`engine_support.c:mj_xfrcAccumulate` / `mj_applyFT` and
`engine_forward.c:mj_fwdAcceleration`.

C skips world-body loads and zero body wrenches, computes the loaded body's COM
Jacobian on its ancestor DOFs, and adds `Jpᵀ force + Jrᵀ torque` to the smooth
right-hand side. The new path visits bodies in ascending order, walks each loaded
body's parent chain and evaluates columns directly. It allocates no temporary
matrix and does not materialize a dense body-by-DOF Jacobian. Fixed descendants,
multiple scalar joints on one body, disconnected roots, hinge and slide joints
use the existing topology and world poses.

C chooses a dense or sparse temporary Jacobian using `mj_isSparse`; AUTO uses
sparse at 60 DOFs and above. The measured fixtures (at most 24 DOFs, AUTO) use
C's dense path. The new implementation computes only ancestor columns even for
these smaller models. This is a concrete algorithmic difference consistent with
the distributed-load timing results, not an isolated attribution of their cost.

For a hinge, the linear column is `direction × (body_COM - anchor)` and the
angular column is `direction`. For a slide, they are `direction` and zero.
Each update specifies the rounded order `(previous + dot(linear, force)) +
dot(angular, torque)`. The C construction through root-COM spatial DOFs can round
differently: the claim is tolerance-based numerical agreement, not bit identity.

External contributions are added after gravity, bias, passive forces, actuator
forces and generalized applied forces, before the acceleration solve. The
implicit-damping Euler solve reuses that same combined right-hand side; it does
not add the external forces again. Reevaluation always rebuilds this total,
including when positions and velocities are cached.

An omitted load argument takes a constant-time empty-input branch. An explicit
all-zero array still scans body wrenches; C additionally uses a bulk byte-zero
check. Thus the two zero-load API profiles must be measured separately.

## Formal scope

`Dot_Load` and `Contribution` specify exact floating-point formulas and bounds.
`Accumulate_Column` specifies the exact changed component, preservation of every
other component, and unchanged output on numeric rejection. `Apply_Buffers`
specifies bounded results, status range, identity for empty input and identity
on invalid size, with indexing safety and terminating ancestor traversal.
The phase/public contracts retain state/configuration/input preservation and
the existing Euler update relation. No assumptions, suppressed checks or trusted
bodies have been introduced for this feature.

The **whole ordered topology-to-generalized-force refinement theorem remains
pending**: it is not established by the safety contract on `Apply_Buffers`.
The missing work is a ghost model of the ordered traversal and invariants
connecting all updates to it, not a mathematical reason to settle for Silver.
The exact column/update contracts provide local Gold properties; they do not
amount to a complete functional proof of the traversal or the simulator.

## Reproducible validation

Run the checked differential suite with `--external` and both inertia policies:

```sh
python experimental/smooth/tools/compare_numerics.py \
  --report-dir /absolute/new-report --toolchain-root /absolute/toolchains \
  --external --samples 24 --policy Compatible \
  --extra-fixtures tests/movement_performance/c_parity_six/fixtures
```

Cases cover world-only loads, force-only and torque-only loads, a loaded leaf,
opposite loads, distributed mixed loads, offset/rotated COMs, fixed descendants,
branched and multiple-root models, and Euler damping branches. The probe checks
invalid sizes/bounds, removes loads and compares the new acceleration with C,
then restores the loads and requires exact recovery of the original Ada result.
A large but valid force tests numeric rejection without a committed state change.
The original suite without `--external` remains a separate regression check.

The benchmark harness is
`tests/movement_performance/external_forces/run.py`. It freezes sources and
binaries, retains the preceding gravity-optimized Ada build for the absent-load
profile, and compares the new nonzero-load profiles with the corresponding C
workload. It never reports old Ada as a valid baseline for unimplemented loads.
Input preparation and C reference calculations occur outside timing; the
measurement records paired order, every trajectory, medians, MAD, p95 and
bootstrap intervals for each model/state/profile.

Evidence and measured results are recorded in
`tests/movement_performance/external_forces/README.md`.

## Remaining force coverage

This completes caller-supplied body wrenches for the supported scalar-joint
subset. It does **not** add contact/constraint forces, joint limits, equality
constraints, tendon or flex forces, fluid forces, gravity compensation, plugin
forces, nonlinear elasticity, activation dynamics, or free/ball joint support.
Those remain explicit scope gaps when comparing with the full C engine.
