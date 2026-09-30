# Free and ball joints in active smooth dynamics

**Current update:** see [performance work and current validation scope](manifold-performance.md).
The concurrently updated tendon loader currently rejects free/ball plus spatial
tendons (`nq != nv`); the combined-tendon results below describe the earlier
merged snapshot. This limitation is distinct from the supported free/ball
smooth dynamics and is now tested as an explicit unsupported feature.

Implemented on 2026-09-30 against MuJoCo 3.14.0. The extension is active in
`MJ.Data.Forward.Evaluate` and `MJ.Data.Euler.Step`, under the existing
experimental smooth runtime. The new path has checked numerical evidence;
**its compositional Gold proof is still open**. Existing proof counts belong
to their recorded source snapshots and do not transfer to this extension.

## Representation and C algorithm

| Joint | Position coordinates | Velocity coordinates |
| --- | ---: | ---: |
| Hinge/slide | 1 | 1 |
| Ball | 4, quaternion | 3, local angular velocity |
| Free | 7, world translation and quaternion | 6, world linear and local angular velocity |

The owned snapshot now keeps separate position and velocity addresses.
The historical private `Nj`, `First_Joint` and `Joint_Count` fields refer to
expanded DOF entries/spans; source-model joint type and group addresses remain
in each entry. Public `Position_Count` and `Velocity_Count` return actual
`nq` and `nv`. Position storage allows 512 entries while velocity storage
retains its 256-DOF limit. Reset restores the copied `qpos0` exactly.

The scalar path retains its kernels. For free/ball models the new kinematics
construct world body poses, inertial frames and grouped motion axes. Ball
rotation occurs about its joint anchor; a free body's pose is absolute.
Grouped angular-axis derivatives use the velocity before adding the rotational
triple, as in C `mj_comVel`. The existing ancestor-row compact CRB assembly,
factorization and solve consume the expanded DOFs directly.

The path accumulates gravity, velocity bias, armature, passive joint springs
and damping, generalized applied forces and projected external body loads.
Joint quaternion springs use a rotation-vector difference. Actuation retains
all six free-joint gear components or three ball-joint components, including
`jointinparent`, fixed gain, affine bias and control/force limits.
The concurrent spatial-tendon implementation is preserved; its initial
joint spring/damping channel now handles these joint groups too.

Euler first stages velocities and positions. Translation/scalar coordinates
use the semi-implicit velocity; quaternions use normalized right multiplication
by the angular increment, matching C's child-frame convention. Rejected numeric
updates preserve positions, velocities and time. Tiny quaternion fallback uses
the norm threshold, including vectors whose individual components are below
`mjMINVAL` but whose norm exceeds it.

C sources used to check the algorithm:

- [`mj_kinematics`, `mj_comPos`, `mj_comVel`, `mj_transmission`](../mujoco/src/engine/engine_core_smooth.c).
- [`mj_springdamper`](../mujoco/src/engine/engine_passive.c).
- [`mj_integratePosInd`](../mujoco/src/engine/engine_support.c).
- [`mju_quatIntegrate`](../mujoco/src/engine/engine_util_spatial.c).

## Checked numerical evidence

The full runner builds an immutable dependency snapshot with assertions,
overflow checks and validity checks enabled. The official Python binding to
MuJoCo 3.14.0 supplies the C oracle. Recorded results are in
[`manifold-20260930`](../experimental/smooth/results/manifold-20260930/).

| Validation | Result |
| --- | --- |
| 12 free/ball/mixed fixtures plus 15 scalar fixtures; 16 samples each | 432 scenarios, 48,640 value comparisons passed |
| 25 spatial-tendon fixtures plus 15 scalar fixtures; 8 samples each | 320 scenarios, 21,944 value comparisons passed |
| Quaternion edges, exact reset/input preservation, atomic rejection | 32 scenarios passed |
| 70 independent ball joints, zero gravity, reset and Euler | `nq=280`, `nv=210`, passed |

The first two suites include external body loads and repeated trajectories of
100 steps. They compare poses, mass, force channels, acceleration and state
against C at `atol=rtol=2e-10`, with quaternion sign equivalence. Supported
inertia-policy tests and unsupported-feature rejection tests also pass.
These comparisons establish agreement on the sampled inputs, not universal
equivalence or a proved numerical error bound. The large-capacity test checks
state directly; it avoids the public dense-matrix getter's expensive executable
postcondition.

Reproduce with GNAT/GPRbuild on `PATH` and Python containing
`mujoco==3.14.0` and NumPy, using a fresh output directory:

```sh
python experimental/smooth/tools/test_manifolds.py --out /tmp/manifold-check
```

An optional `--toolchain-root` accepts the repository runner's directory layout
with `gnat/`, `gprbuild/` and `gnatprove/` toolchains. Source/binary hashes,
build logs, MJBs and captured inputs/outputs remain in the output directory.

## Formal status and remaining obligations

No new trusted body, assumption or suppressed runtime check was introduced.
Contracts include position-group layout, staged Euler state relations, preserved
state on failure and actuator force reduction. The final focused proof of
`Widen_Motion` closes 3 proof checks and 1 flow check. This small bounds lemma
does not establish the physical dynamics.

Fragmented proof diagnostics for quaternion normalization/increments, grouped
axis advancement, `Build_Manifold_Bodies`, `Manifold_Actuation.Compute` and
`Integrate_Manifolds` still contain unproved bounds, loop/frame invariants and
functional composition obligations. Whole-unit diagnostics are also open.
Earlier diagnostic reports retain their own source hashes; timeout rows are
not passes. Neither whole-path Silver nor Gold is established, and solver
limitations are not classified as a mathematical Silver exception.

Start further closure at the quaternion helpers and axis-advancement contracts,
then discharge caller preconditions and Euler/actuation relations, followed by
whole-unit and integration proofs.

## Performance and scope

The saved active-source timing sample uses release GNAT 16.1.0, `-O3`,
`-march=native`, inlining, LTO and matching floating-point contraction settings.
C 3.14.0 retains its normal AVX/intrinsics. Six alternating blocks contain seven
timed trajectories of 800 Euler steps each, after two warmups; every final
trajectory is checked against C. Data preparation and output are outside timing.

| Workload | Median paired Ada/C ratio | Range across six blocks |
| --- | ---: | ---: |
| Free body | 1.039 | 0.807–1.357 |
| Ball body | 1.035 | 0.784–1.166 |
| Free + ball + hinge | 1.244 | 1.060–1.340 |
| Ball chain | 1.291 | 1.212–1.896 |
| Scalar hinge | 0.797 | 0.649–1.038 |
| Scalar chain, 12 DOFs | 1.413 | 1.061–2.112 |

Ratios below one indicate faster Ada. Dispersion is large: these are local
diagnostic timings, without a pre-change scalar baseline. They establish
neither parity nor a regression-free change. Earlier timing samples are retained
as historical measurements, not attributed to the final merged executable.
The active timing manifest records the exact source snapshot; subsequent
constructor proof refactoring in the main thread is separately captured by the
final checked-validation manifest.

This remains Euler smooth dynamics with constraints disabled. Contacts,
collision response, joint limits, equality constraints, activation dynamics,
unsupported transmission/tendon variants and the other existing excluded
features remain outside this runtime. It is not a complete `mjData` port.
