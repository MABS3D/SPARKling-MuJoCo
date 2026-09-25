# Minimal smooth dynamics — review draft

**Inertia policy update:** `Create` now defaults to `Compatible`, using reverse
`LᵀDL` with a `1e-15` pivot floor and the queryable, resettable `Clamped_Dof`
diagnostic. Pass `Solver_Policy => Strict` to retain the previous relative
pivot/condition rejection policy. Numeric-domain limits remain active in both
modes. See [policy, tests and current performance](../../docs/inertia-policy.md).

Current reference: MuJoCo **3.14.0**; see [migration scope and evidence](../../docs/mujoco-3.14-alignment.md). The 3.12 results below are historical evidence, not results relabelled for 3.14.

The first [integrated movement benchmark](../../docs/movement-performance.md)
compares full Euler trajectories against a native 3.14 C build. The prototype
remains slower in the measured workloads. A proved matrix-kernel bridge added
cost and was retained only as a reproducible experiment; the active math body
was restored. This benchmark does not establish whole-pipeline Gold or parity.

The active [articulated-dynamics optimization](../../docs/dynamics-optimization.md)
adds CRB mass assembly and recursive gravity/bias accumulation for three or more
DOFs, with a bounded dense fallback, scaled-diagonal reuse and no-damping Euler
reuse. Checked numerical tests now include 24-DOF and multiple-root models
against 3.14.0. `MJ.Spatial_Kernels` closes 413 proof obligations; composition of
the new recursions remains open. Whole-step timings improve substantially for
larger models but do not reach C parity.

This directory contains the owned-state and scalar hinge/slide baseline of
SPARKling MuJoCo. It remains separate from the main library for review.
The checked Ada executable has been built and compared with the official
MuJoCo **3.12.0 C library**, through its Python binding. Reproducible fixtures,
inputs, outputs, executable/source hashes and build logs are captured by
[`compare_numerics.py`](tools/compare_numerics.py).

The verification target is **Gold wherever possible**, following the repository
[verification policy](../../docs/verification-policy.md). Contracts specify
floating-point formulas, state transitions, preserved inputs, reset behavior and
atomic failure. Numerical comparisons and executable contract checks are not
universal proofs. Some proof obligations remain open: **neither whole-subset
Gold nor whole-subset Silver has been established**. Solver timeouts and missing
invariants are pending proof engineering, not mathematical exceptions.
See [verification scope](verification.md) for the claim boundaries.

The complete `MJ.Smooth_Math` unit has passed 645 proof checks and 57 flow
checks, including functional formula and frame contracts, with no open checks.
This establishes those specified properties under the recorded runtime
contracts; the lifecycle and dynamics units still need compositional closure.

`smooth.gpr` imports the model library and keeps runtime checks enabled.
The differential runner compiles an immutable snapshot of the probe's actual
source dependency closure, without including unrelated units under development.

## Components

| Package | Intended responsibility |
| --- | --- |
| `MJ.Smooth_Math` | Small vector, quaternion and rotation operations |
| `MJ.Spatial_Kernels` | Contracted spatial inertia, motion and wrench operations |
| `MJ.Data` | Owned model snapshot, state, scratch buffers, reset, accessors and status handling |
| `MJ.Data.Kinematics` | Body and joint poses, body motion, center-of-mass Jacobians |
| `MJ.Data.Inertia` | Dense mass matrix, joint armature and LDL factorization/solve |
| `MJ.Data.Forces` | Gravity, velocity-dependent inertial bias, linear springs and damping |
| `MJ.Data.Actuation` | Scalar joint transmissions, fixed gain, optional affine bias and clamping |
| `MJ.Data.Forward` | Current-state acceleration pipeline |
| `MJ.Data.Euler` | Semi-implicit Euler, with optional implicit linear damping |

## Supported model subset

The intended subset is an ordered tree of fixed bodies and scalar hinge/slide
joints. A body may have more than one scalar joint. Body and inertial frame
rotations, joint anchors, principal inertia and joint armature are retained.
Axes accepted by the model validator are normalized once in the owned snapshot.
Pose updates, velocities and Jacobians all use this same normalized axis.

Actuators have one control and one output, no activation state, a scalar joint
transmission, a fixed gain and either no bias or an affine bias. This covers the
basic motor and position/velocity servo force laws. Control and actuator force
limits are supported. Actuator damping and actuator armature are excluded.

`Create` uses the existing model layout and model validators, followed by checks
for this subset. The draft requires:

- Euler integration and the model's `Dsbl_Constraint` flag set;
- `nq = nv = njnt`, with hinge/slide joints only;
- at most 256 degrees of freedom, 4,096 bodies and 1,024 actuators;
- one control and output per actuator, in actuator order.

Requiring disabled constraints makes the intended scope explicit: this draft
does not implement contacts, joint limits, equality constraints or a constraint
solver. A model with geometry is not thereby given collision dynamics.

Other excluded features include free/ball joints, activation dynamics, tendons,
flex bodies, plugins, mocap, history, fluid forces, gravity compensation,
nonlinear stiffness/damping and joint-level aggregate actuator force limits.
Unsupported enable flags and actuator-group disabling are rejected. Geometry
and site world transforms, sensors and rendering are not computed by this API.

This is a small independent runtime representation. It is not a complete
`mjData` port and does not provide its binary layout or full C API.

## State and lifetime

`Simulation` is a limited private type to prevent accidental copying of its
owned access values. `Create` copies the supported model parameters and
allocates state, derived results and scratch storage. Changing or releasing
the caller's model after a successful creation is not intended to change the
simulation. To adopt a different configuration, release and recreate it.

`Reset` restores `qpos0`, sets time and velocities to zero, clears controls and
applied forces, clears derived/scratch storage and invalidates cached results.
`Free` releases the owned storage. There is no automatic finalization in this
draft; callers must arrange cleanup. Allocation failure (`Storage_Error`) is
outside the status-based failure contract and still needs a lifetime review.

The algorithm reuses preallocated buffers. Executable contracts additionally
copy bounded state/input images; `Write_Vector` checks preservation of the
untouched array entries, and mass assembly checks symmetry invariants. These checks can be expensive and are enabled in the
validation build. No timing or allocation-free execution claim is made for it.

The intended call sequence is:

1. Load or construct an `MJ.Models.Model` in the supported subset.
2. Call `MJ.Data.Create`, and proceed only on `Success`.
3. Optionally use `Set_State`, `Set_Control` and `Set_Applied_Force`.
4. Call `MJ.Data.Forward.Evaluate` for current-state derived results, or
   `MJ.Data.Euler.Step` to advance one timestep. Check each returned status.
5. Use the getters with output arrays of the corresponding count.
6. Call `MJ.Data.Free` when finished.

State inputs use `Tier0_Real` and `Nonneg_Tier0`. These are typed Ada inputs,
not a decoder or sanitizer for arbitrary foreign bytes. Indices used by
control, force and body accessors are zero-based. Getter array lower bounds
need not be zero; lengths must match. The mass matrix is returned as `nv * nv`
elements in row-major order.

State changes invalidate derived results. Changing a control invalidates
actuation and acceleration; changing an applied force invalidates acceleration.
A successful step invalidates the old state's results. Call `Evaluate` again
before requesting results for the new state. Getters can return
`Stale_Results` rather than exposing an outdated cache.

## Dynamics conventions

Vectors and body motion are expressed in world coordinates. Quaternions use
`(w, x, y, z)`. Body motion is stored at the body origin; the translational
Jacobians used to assemble inertia and forces refer to the center of mass.

The dense inertia fallback computes:

```text
M = sum_b (mass_b * Jv_b^T * Jv_b + Jw_b^T * Iworld_b * Jw_b)
    + diag(joint_armature)
```

The Strict LDL solver measures `s = ||A||_inf` for the matrix actually being
solved (`M` or `M + h*D`). It uses the dimensionless draft threshold
`tau = 64 * max(1, nv) * Real'Model_Epsilon`. A zero matrix or computed
nonpositive pivot returns `Singular_Inertia`; a positive pivot with
`pivot / s <= tau` returns `Ill_Conditioned_Inertia`. Small absolute mass alone
is no longer the rejection criterion.

After factorization, solves against all unit vectors estimate
`kappa_inf(A) = ||A||_inf * ||A^-1||_inf`. They use the diagonal factors divided
by `s`, producing columns of `s * A^-1` directly. Absolute row sums are
accumulated in preallocated scratch; no full inverse is stored. An estimated
condition number at least `1 / tau` returns `Ill_Conditioned_Inertia`.
The physical force RHS is restored before the acceleration solve.

This policy addresses uniform scaling and accounts for coupling, but depends
on the chosen coordinate units and does not perform diagonal equilibration.
The computed estimate and threshold are not certified error bounds. The
condition estimate, used only in Strict mode, adds `nv` triangular solves, hence additional cubic work;
it is a straightforward draft implementation, not a performance optimization.
The Strict solver does not regularize the matrix, and existing arithmetic storage
limits can still return `Numeric_Limit`. Divisions check the prospective
quotient against those limits before using a small positive pivot.

The force convention is:

```text
M * qacc = gravity - bias + passive + actuation + applied
passive_j = -stiffness_j * (qpos_j - qpos_spring_j) - damping_j * qvel_j
```

Here `bias` includes velocity-dependent inertial terms and excludes gravity.
For comparison with MuJoCo's combined `qfrc_bias`, use `bias - gravity`.
Spring and damper terms respect the copied disable flags.

Scalar actuator transmission uses `length = gear * qpos` and
`velocity = gear * qvel`. The force law is:

```text
force = gain * control + bias0 + bias1 * length + bias2 * velocity
generalized_force[joint] += gear * force
```

Control clamping occurs before that force law; actuator force clamping occurs
before projection through the gear. Disabled actuation has zero force and zero
actuator velocity, matching `mj_fwdVelocity`; transmission length is retained.

Euler updates velocity before position:

```text
(M + h * D) * a_effective = gravity - bias + passive + actuation + applied
qvel_next = qvel + h * a_effective
qpos_next = qpos + h * qvel_next
```

`D` is the diagonal joint damping matrix when implicit Euler damping is
enabled; otherwise `a_effective` is the ordinary forward acceleration.
The right-hand side already includes the current state's passive damping.
The step stages positions and velocities in scratch buffers before committing
them. A returned failure is intended to leave positions, velocities and time
unchanged; it may change scratch and derived buffers. This is not a guarantee
for unhandled exceptions in an unverified draft.

## Validation and remaining work

The reproducible suite currently covers 15 models and 32 states per model:
45,120 scalar comparisons, including trajectories of 1 and 100 Euler steps.
It includes empty/fixed systems, hinge and slide joints, branched multi-joint
bodies, a 12-DOF chain, off-center anchors and COMs, rotated inertias, armature,
reference positions, springs/damping, shared motor/servo transmissions, negative
gears, clamps, and individual disable flags. A uniformly small positive mass is
accepted. The mixed comparison gate is `abs(error) <= 2e-10 + 2e-10*abs(reference)`;
it is an empirical test tolerance, not a proved forward-error bound.

In addition, seven numerical-policy cases check exact failure atomicity:
time, position, velocity and acceleration limits, singular inertia, diagonal
ill-conditioning and coupled ill-conditioning. Five unsupported-model cases
check rejection of free/ball joints, RK4, enabled constraints and fluids. The
probe also exercises reset, double creation/free, a freed source model,
nonzero input-array bounds, arrays ending at `Natural'Last`, invalid setter
sizes/indices and stale results.
Seven direct normalization edge cases exercise zero, tiny and large values and
unchanged rejected inputs. Mass symmetry, positive definiteness on supported
test configurations and the scaled equation residual are checked independently of the C comparison.

The tests found and corrected one C mismatch: actuator velocities must be zero
when actuation is disabled. Proof diagnostics also exposed possible index
overflow in contracts that concatenated caller-owned arrays; round-trip
contracts now compare components without concatenating those arrays.
Quaternion normalization now stages its result and
checks a near-unit predicate before committing. The forward acceleration limit,
condition threshold and error statuses remain deliberate differences from C's
warning/autoreset policy.

Outstanding engineering includes complete lifecycle/dynamics compositional
proofs, an independently specified mass/force recursion, allocation
failure cleanup, and broader numerical conditioning analysis. There is no
approved Silver-only mathematical exception. Dense storage/algorithms, optimized
sparse dynamics, free/ball joints, collisions/constraints and integration into
the main build are separate future work. No performance-parity claim is made.
