# Contact-free elastic edge networks

This independent SPARK API implements Cartesian particles connected by elastic
edges, corresponding to the `flexedge` spring/damper part of MuJoCo 3.14.0.
It includes edge geometry, elastic and viscous force assembly, gravity, applied
vertex forces and semi-implicit Euler integration. A pinned vertex retains its
entire input record; its velocity is ignored in edge kinematics. Forces on
pinned vertices are not returned as reaction forces.

`MJ.Elastic_Network.Forces` returns separate spring/damper arrays.
`MJ.Elastic_Network.Step` evaluates them and advances a whole network. Callers
own the particle, edge and applied-force arrays; no heap allocation is performed.
Particle/edge arrays start at 1; there must be 1–4,096 particles and up to
4,096 edges. Edges must connect distinct valid indices. Duplicate edges are
allowed and contribute in input order. The `Valid` predicate is the public
shape/topology precondition. Endpoint order controls the direction from A to B.

Each particle has three world-space translational coordinates, mass in
[mjMINVAL = 1e-15, 1e10], and an optional fixed/pinned flag. Coordinates, velocities,
applied forces and gravity use the existing Tier0 domain, [-1e10, 1e10].
Rest lengths, stiffness and damping are nonnegative Tier0 values. The timestep
is in [0, 1]. These are arithmetic bounds, not a stability guarantee: stiff
systems still require sufficiently small timesteps.

The edge law matches `mj_springdamper` in C's `engine_passive.c`:

- spring scalar: `stiffness * (rest_length - current_length)`;
- damper scalar: `-damping * edge_speed`;
- endpoint projection: opposite signed edge directions, skipping pinned DOFs;
- spring and damper sums stay separate until total-force assembly.

The length/direction calculation follows `mj_flex` and `mju_normalize3`,
including the `[1, 0, 0]` fallback below `mjMINVAL`. The Ada runtime sqrt contract
provides nonnegativity but no upper error bound. `Measure` therefore checks the
returned length against a conservative 1e11 bound (input-coordinate limits imply
a real norm below 3.5e10). An out-of-domain result produces `Numeric_Limit`;
no new sqrt assumption or silent clipping is used.

`Step` builds a candidate state and commits only after every coordinate and
velocity passes its numeric limit. On failure the entire input state is
unchanged. Spring/damping floating-point reductions are ordered, not assumed
associative. Proved contracts and C differential tests are distinct evidence;
see the [accepted results report](results/README.md) for proof status, C
comparisons and complete-step timings.

This is the first elastic subset, **not full MuJoCo flex support**. It does not
load flex from `MJ.Models`, couple vertices to arbitrary articulated bodies,
provide contacts/self-contact, enforce edge equalities, implement continuum
stretch/bending, interpolate flex nodes or supply implicit flex integration.
`MJ.Data.Create` continues to reject flex models. This package does not alter the
rigid-body pipeline being developed in the main task.

## Build and compare

With the project GNAT toolchain on PATH:

```
gprbuild -P experimental/deformable/elastic.gpr
```

The probe accepts a text network and emits initial forces and the final state.
The differential runner generates MuJoCo XML and equivalent probe input,
compiles a frozen checked dependency closure and archives its hashes:

```
python experimental/deformable/tools/compare.py \
  --toolchain-root /path/to/toolchains --out /tmp/elastic-results
```

Python requires NumPy and the pinned MuJoCo 3.14.0 binding. The tests compare
independent calls to the real C engine, not a Python rewrite of its force law.

Example: `bin/elastic_probe < tests/spring_pair.input` from this directory
simulates a stretched spring with one fixed endpoint for 100 steps. Input rows
are: vertex/edge/step counts, timestep and gravity; then one mass, pinned flag,
position, velocity and applied force row per vertex; then endpoint indices,
rest length, stiffness and damping per edge.

## Proof and performance reproduction

Start with the affected subprograms, then verify both complete units using the
repository's bounded proof runner (GNAT/SPARK 16.1):

```
python3 experimental/smooth/tools/prove_fragments.py \
  --toolchain-root /path/to/toolchains --report-dir /tmp/elastic-proofs \
  --whole-unit mj-elastic_kernels --whole-unit mj-elastic_network \
  --provers cvc5,z3,altergo --prover-seconds 5 --steps 0 \
  --jobs 2 --cap-mb 3000 --wall-seconds 900 --total-seconds 2000
```

The benchmark compiles a release Ada dependency snapshot and a native C harness
against the recorded MuJoCo C build. Pass the `build.json` from a project
movement-performance run; its `builds.c.command` supplies compiler/include/link
flags. The Python wheel compiles XML to MJB outside timing; the native library
loads that MJB. This avoids relying on XML compilation under the native C
finite-math build. All initial states, native build flags, hashes, raw samples,
final states and paired confidence intervals are recorded.

```
python experimental/deformable/tools/benchmark.py \
  --toolchain-root /path/to/toolchains --c-build /path/to/build.json \
  --out /tmp/elastic-timings --blocks 12 --steps 1000 --cpu 8
```

Only equivalent contact-free Cartesian networks are compared. The Ada path is
specialized to diagonal particle masses; C executes its general engine with
body, kinematics, inertia and BVH bookkeeping. A speedup here is **not** a claim
about arbitrary articulated or contact-rich deformable simulations. The native
C reference retains its normal SIMD implementation. Input construction, model
loading and output are outside timing; the entire force/integration step and
Ada's atomic candidate-state commit are inside timing.
