# Spatial tendon wrapping candidate

This SPARK implementation translates spatial routing in `mj_tendon` and
sphere/cylinder `mju_wrap` from **MuJoCo 3.14.0**, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. It is now connected to MJB loading,
owned simulation state, passive forces, Forward and Euler in the **experimental
smooth engine**. It is not a completed or formally certified MuJoCo port.
The 2026-10-02 integration also connects fixed tendons to the same owned
configuration and passive-force order; see [current integration evidence](../../docs/force-integration.md).
The old fixed-tendon candidate remains an archived, separate implementation.

## Implemented behavior

- World/local transforms and wrapping around spheres and infinite cylinders.
- Both tangency solutions, upstream tie-breaking and crossing rejection;
  no-wrap, collinear, coincident, tangent, tiny-radius and inside-endpoint cases.
- `sidesite` selection, including the inside-wrap Newton iteration, its 20-step
  limit, and the same default-point fallback as C.
- Cylinder height interpolation and helical arc length.
- Site/geometry/site routes, successive wraps separated by sites, and pulley
  branches. A pulley replaces the following branch's divisor, as in C.
- Total length and world wrap points, with C's site/geometry/pulley object tags.
- First Jacobian, tendon velocity `J*qvel`, and additive generalized force
  projection `qforce += J^T*force`, including a moving wrapping body.
- Transactional numerical failure: zero length, zero Jacobian, no partial
  points. Ordinary no-wrap is a successful straight segment, not an error.

`Wrap.Arc_Length` is **only the curved segment**. `Evaluate.Length` includes
both straight legs and pulley division. An inside wrap can have two identical
contact points and zero arc length while still being a valid wrapped path.

## Integration interface

`MJ.Tendon_Geometry.Wrap` is the small geometry kernel.
`MJ.Spatial_Tendons.Evaluate` assembles one spatial tendon from caller-owned
arrays. The caller supplies current world site and geometry poses, body origins,
and world linear/angular Jacobian columns at those origins. Point columns are
computed as `linear + angular cross (point - origin)`. The interior arc has the
same body at both ends and does not add a separate Jacobian contribution.

Arrays start at zero. Capacities are bounded to 4,096 sites/geometries/bodies,
4,096 DOFs and 4,096 route nodes; reserve at least `3 * Route'Length` output
points. Null DOF arrays are supported. `Evaluate` uses caller-provided storage
and has no heap allocation. The engine allocates its owned configuration and
output cache when creating the simulation, then releases both in `Data.Free`.
Input positions and velocities are bounded by `1e10`; pulley divisors are in
`[1e-10, 1e10]`. Supply actual rotation matrices from kinematics: the numeric
component-bound predicate does not prove orthogonality.

Call `Valid_Path` when constructing/changing a route. Before `Evaluate`, callers
must establish `Valid_Kinematics` for the current state, by a runtime gate or
proved upstream contracts. These are public preconditions, not facts established
by the current candidate. Development/validation builds check them; the release
build removes contract instrumentation. Production numerical limit checks remain.

Pass the computed scalar tendon force from the spring/damper, actuator or tendon
constraint stage to `Project_Force`. Negative force pulls, consistently with C.
The tests compare this projection with MuJoCo's actual tendon spring/damper
`qfrc_passive`, rather than only comparing two copies of a force formula.

The engine adapter uses dense body Jacobian columns, referred to each body's
**center of mass**. World site/geometry transforms use the body origin instead.
Confusing these two reference points changes the projected force for an offset
inertia. Both moving wrap bodies and nonzero inertial offsets are tested.

`MJ.Spatial_Tendon_Models.Load` takes an owned copy of compiled model routes,
local site/geometry poses, spring ranges and polynomial stiffness/damping.
The original MJB model can be freed after `Data.Create`. The passive-force phase
updates world geometry, evaluates each path, computes `J*qvel`, accumulates
spring and damper channels separately, and publishes forces and tendon outputs
only after every check succeeds. `Data.Get_Tendon_Outputs` returns length,
velocity and total passive scalar force; stale/incorrectly sized queries return
an explicit status and zero outputs. Repeated force evaluation does not accumulate
the previous result again.

The integrated scope now includes hinge/slide/ball/free joints (up to 256 DOFs
and 512 position coordinates), with constraints disabled. The adapter uses
velocity-space Jacobians even when `nq != nv`. Mixed fixed/spatial tendons are
accepted. Fixed tendons retain wrap-order length, sparse velocity reduction,
repeated-joint zero slots, polynomial spring/damper laws and cached armature
updates in C's existing mass pattern. A fixed tendon still references only
hinge/slide joints; other ball/free joints may coexist in the same model.

Tendon actuator transmissions, tendon limits/friction/constraint rows, sleep
handling and spatial tendon armature/Jdot remain unsupported and are rejected.
MuJoCo 3.14 itself rejects tendon armature combined with geometry wrapping;
its `mj_tendonDot` also does not support wrapping-geometry derivatives.
Boxes, capsules, meshes and cylinder end caps are not wrapping primitives in
the reference algorithm and are not introduced here.

Dense Jacobian construction/copies and repeated validation remain in this
integration. The C sparse ancestor traversal is still an optimization gap;
working integration is not a claim of performance parity.

## Numeric and formal assurance

The floating-point operation order follows C with FP contraction disabled. This
is an implementation of the upstream algorithm, not a proof of globally shortest
paths or ideal real-number geometry. Standard Ada elementary functions supply
square root and trigonometry. There are no custom assumed transcendental lemmas,
`pragma Assume`, proof suppressions, or imported C production kernels.

One intentional difference is explicit rejection when a rounded `acos`/`asin`
argument is outside its domain, or a cylinder denominator is nonpositive. C can
return NaN in these situations. The candidate returns `Numeric_Limit` without
clamping or pretending the path is valid. A reproducible C NaN case and failure
after an already successful pulley branch are regression tests.

Useful exact contracts specify vector arithmetic, world point Jacobian columns,
the ordered velocity accumulation, additive force projection, polynomial
spring/damper behavior, flat-to-body Jacobian conversion and output retrieval.
The standard runtime square-root model establishes only limited sign/special-case
properties. Norm contracts express composition with that runtime; they do not
establish a real-number accuracy bound or exact unit length. Explicit limits
are checked before path-length accumulation. **The complete
geometry/path algorithm is not yet Gold, nor is whole-unit Silver claimed.**
Unclosed range/precondition/loop obligations and the missing global functional
wrapping/path model remain proof engineering work. These are not classified as
mathematical Silver exceptions. Read `evidence/proof-*/manifest.json`, the full
logs and `.spark` reports for the actual scope of each successful local proof.

Latest measured results and the exact assurance boundary are in [RESULTS.md](RESULTS.md).

## Reproduction

Use Python with `numpy` and the MuJoCo **3.14.0** wheel, the pinned `mujoco/`
submodule, GCC, GPRbuild and GNATprove. The helpers discover the session toolchain
under `/var/tmp/sparkling-matrix-recovery/toolchains`; override it using
`SPATIAL_TOOLCHAINS`, or provide binaries on `PATH`. `SPATIAL_SCRATCH` defaults to
`/var/tmp/sparkling-spatial-tendons-20260930`. All build products stay there.

```sh
python tests/test_spatial.py --mode development
python tests/test_spatial.py --mode validation
python tests/test_spatial.py --mode release
python tests/test_integration.py
python tests/prove.py --scope small
python tests/prove.py --scope whole
python tests/prove.py --scope flow
python tests/prove_integration.py --scope kernels
python tests/prove_integration.py --scope loader
python tests/prove_integration.py --scope phase
python tests/prove_integration.py --scope callers
python tests/prove_integration.py --scope flow
python tests/benchmark.py
python tests/benchmark_integration.py
```

Tests extract the unchanged wrapping section from the pinned upstream git blob
and compile it with upstream BLAS/spatial routines. Complete paths are compared
against the actual MuJoCo wheel, including its compiled route, sparse Jacobian,
wrap-point output, velocity and passive-force pipeline. Finite differences of
the Ada path length provide an independent Jacobian check away from branch
boundaries. Tests and proof commands write source hashes and evidence locally.
The proof command deliberately exits nonzero when obligations remain open.

The geometry microbenchmark consumes the arc and all six contact-point
coordinates, with matching C/Ada compiler optimizations, normal C platform SIMD,
LTO and no FP contraction. Historical length-only measurements, which allowed
final point transforms to be removed, are retained separately and are not the
current result.

`benchmark_integration.py` measures complete 64-step Euler trajectories, with
4,096 trajectories per sample, after excluding reset/input preparation/readback.
It compares the release-built experimental engine against the official 3.14.0
MuJoCo library. The driver compiler flags match; the official wheel's internal
build flags are not independently controlled. Both arms use the same allowed
logical CPU, discard warm-up, alternate five samples and check final-state
checksums. Raw trajectory wall times, thread CPU times, sample means and p95 wall times
are retained. Thread CPU timing separates descheduling from computation, but
does not remove frequency or shared-resource variability.
Other host activity is not controlled. The representative cases have 2/8/16 DOFs
and 1/4/8 spatial tendons; no conclusion about other workloads follows from them.

See `NOTICE` and the repository Apache-2.0 license for upstream attribution.
