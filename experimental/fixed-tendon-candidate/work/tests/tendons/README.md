# Fixed tendons: implementation and acceptance evidence

This is an isolated integration draft based on commit
`677e75474f81e76cc0c99dd7eeb2edb22d5f6af9`. It has not been merged into the
concurrently edited main checkout. Numerical agreement, performance and SPARK
proof completion are separate acceptance criteria; see `evidence/results.md`
for the recorded status of each.

## Implemented scope

The experimental smooth pipeline now accepts fixed tendons over its supported
scalar hinge/slide joints. The owned configuration survives destruction of the
input model. It includes:

- Length in the original wrap order and velocity from the sparse Jacobian.
- Dead-band spring ranges and linear/polynomial spring and damper forces.
- Separate projection of spring and damper contributions, followed by their
  combination with the existing joint contributions.
- Tendon armature contributions to the existing mass sparsity pattern, including
  the dense mirror required by the pipeline's public matrix representation.
- Euler integration with explicit tendon damping, matching the reference.
- Repeated joint entries and their duplicate sparse columns, negative
  coefficients, cross-branch tendons, and spring/damper disable flags.

The repeated-coefficient bound is checked after ordered accumulation, so a
temporarily larger prefix that later cancels does not reject an otherwise
supported final Jacobian. A dedicated differential fixture covers that case.

The layout, constant Jacobian and ordered armature products are prepared at
creation. The timestep does not reconstruct or validate the tendon layout.
Different tendons' armature additions are not regrouped: their rounding order
remains observable. One rounded addition updates both symmetric mass entries.
The velocity reduction has four accumulators with C's lane combination and
sequential tail. Ghost models and proof helpers do not run in release builds.
For spring and damper magnitudes at most `1e30`, a proved rounded projection
kernel replaces per-DOF numeric guards with one gate per tendon. Larger forces
retain the checked path. A large-force cancellation fixture exercises that
path successfully; a separate policy test checks rejection without changing
state when a projected contribution exceeds the work interval.

The general tendon task is **not complete**: spatial paths, site/geom wrapping,
their varying Jacobians and Jdot, tendon actuator transmissions and their
inherited damping/armature and force limits remain unsupported. Constraints,
friction loss, contacts and other features outside the smooth pipeline are not
added by this change. Unsupported spatial tendons and tendon transmissions are
rejected explicitly and covered by rejection tests. This scope cannot establish
performance parity for full MuJoCo or for those missing contributions.
The public tendon value query currently recomputes its kinematics. API query
and model-creation performance are outside the measured timestep workload.

## C reference and details that affect equivalence

Reference: MuJoCo **3.14.0**, source commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, using the normal C SIMD paths.

- [`mj_tendon`](https://github.com/google-deepmind/mujoco/blob/9ecbb9d7b5ee623f54745638d36799ff90e6f7cd/src/engine/engine_core_smooth.c#L931)
  accumulates fixed length in wrap order and combines repeated joints into the
  first matching Jacobian slot. Duplicate columns emitted by the compiler must
  remain valid. Only the tendon CSR validator was relaxed to nondecreasing
  columns; other CSR structures retain strict ordering.
- [`mju_dotSparse`](https://github.com/google-deepmind/mujoco/blob/9ecbb9d7b5ee623f54745638d36799ff90e6f7cd/src/engine/engine_util_sparse.h#L197)
  uses four lanes and combines `(s0+s2)+(s1+s3)` before the tail. The AVX initial
  product can differ from an initial addition to positive zero in signed-zero
  bits; the tests establish numerical tolerance agreement, not bitwise identity.
- [`mj_tendonSpringDamper`](https://github.com/google-deepmind/mujoco/blob/9ecbb9d7b5ee623f54745638d36799ff90e6f7cd/src/engine/engine_core_util.c#L1120)
  applies the spring range, polynomial laws and disable flags. Projection stays
  separate for springs and dampers as in `mj_passive`.
- [`mj_tendonArmature`](https://github.com/google-deepmind/mujoco/blob/9ecbb9d7b5ee623f54745638d36799ff90e6f7cd/src/engine/engine_core_smooth.c#L1849)
  adds `Jj * (armature * Ji)` only where M already has a sparse entry. It does not
  insert cross-branch mass entries. This behavior was checked against C,
  including a two-root example; a mathematical dense outer product would differ.
- `mj_tendonDot` returns zero for fixed tendons. Therefore their armature does
  not add a Jdot bias term. `mj_EulerSkip` treats joint damping implicitly and
  tendon damping explicitly.

The creation caps are 256 DOFs, 1024 tendons and 65536 entries per stored terms,
Jacobian or mass plan. Exceeding a cap returns `Capacity_Exceeded`. Runtime
numeric limits remain explicit; no assumption or new trusted body substitutes
for a proof. Solver timeouts and missing functional driver contracts are open
proof engineering, not mathematical Silver exceptions.

## Reproduction

Use Python with `mujoco==3.14.0` and NumPy, and the recorded GNAT/GPRbuild/
GNATprove 16.1 toolchains. Run from the repository root. Replace paths with the
local toolchain and a validated C movement build; the reference build must have
`build.json` and `movement_c`, including matching C binary/library hashes.

```sh
ulimit -s 65536
python3 tests/tendons/generate_fixtures.py
PYTHON_WITH_MUJOCO experimental/smooth/tools/compare_numerics.py \
  --repo "$PWD" --toolchain-root TOOLCHAINS --report-dir NEW_NUMERICS \
  --samples 24 --case-timeout 300 --extra-fixtures tests/tendons/fixtures
PYTHON_WITH_MUJOCO experimental/smooth/tools/compare_numerics.py \
  --repo "$PWD" --probe CHECKED_PROBE --report-dir NEW_STRICT \
  --policy Strict --samples 24 --case-timeout 300 \
  --extra-fixtures tests/tendons/fixtures
PYTHON_WITH_MUJOCO tests/tendons/measure.py \
  --build NEW_BUILD --toolchain TOOLCHAINS --reference C_REFERENCE --build-only
PYTHON_WITH_MUJOCO tests/tendons/measure.py \
  --build NEW_BUILD --out NEW_SESSION_1 --blocks 24 --samples 5 --steps 500 --states 3
PYTHON_WITH_MUJOCO tests/tendons/measure.py \
  --build NEW_BUILD --out NEW_SESSION_2 --blocks 24 --samples 5 --steps 500 --states 3
```

The fixed seed records every generated state. Timing excludes input preparation
and output, alternates execution order, and checks every trajectory endpoint.
The baseline Ada executable predates tendon support, so it is compared only on
the no-tendon controls; there is no reduced-physics tendon baseline.
Timings are complete Euler trajectories, not isolated tendon microbenchmarks.
The p95 is over trajectory-average step times, not individual-step latency.
Within-session bootstrap intervals do not measure all between-session/system
uncertainty. Background load is recorded and quiet-session acceptance remains
separate from collecting a timing file.

Small-subprogram proof example:

```sh
python3 experimental/smooth/tools/prove_fragments.py \
  --repo "$PWD" --toolchain-root TOOLCHAINS --report-dir NEW_PROOF \
  --unit mj-fixed_tendons --name Store_Mass_Pair --name Add_Mass \
  --prover-seconds 8 --provers cvc5,z3 --steps 0 --jobs 2 \
  --wall-seconds 60 --total-seconds 180
```

Passing callers are conditional on callees' contracts. Neither a fragment pass
nor differential agreement closes the loader, entire dynamics pipeline, or
universal equivalence to C. The report lists remaining obligations explicitly.
