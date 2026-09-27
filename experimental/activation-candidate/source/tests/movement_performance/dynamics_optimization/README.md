# Active articulated-dynamics optimization

The baseline contains the complete 24 smooth Ada sources frozen before this
change; `baseline.json` authenticates them. The builder copies the active sources
into an isolated snapshot, builds baseline/current with the same release flags,
and builds a separate current probe with assertions and runtime checks enabled.
It reuses the native MuJoCo 3.14.0 C reference only after checking its recorded
binary and shared-library hashes. It does not apply the historical matrix bridge
or the experimental readiness shortcut.

The changes implement composite rigid-body mass assembly, recursive accumulation
of separate gravity/bias wrenches, cached inertia products in the dense fallback,
reused scaled pivots during condition checks, and Euler solve reuse when damping
is zero. They remain in the experimental smooth pipeline. See the
[implementation and results](../../../docs/dynamics-optimization.md).

## Reproduce

Use Python with MuJoCo 3.14.0 and NumPy, GNAT/GCC 16.1, and a native C build
prepared as in the [parent experiment](../README.md). All output directories
must be new. Example with the paths used for the recorded run:

```sh
python3 tests/movement_performance/dynamics_optimization/build.py \
  --out /var/tmp/dynamics-build-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --reference-build /var/tmp/sparkling-movement-final

/var/tmp/sparkling-movement-env/bin/python \
  experimental/smooth/tools/compare_numerics.py \
  --probe /var/tmp/dynamics-build-new/checked/bin/smooth_probe \
  --report-dir /var/tmp/dynamics-numerics-new --samples 24 \
  --extra-fixtures tests/movement_performance/dynamics_optimization/fixtures

# Only after proofs, builds and numerical tests have finished:
/var/tmp/sparkling-movement-env/bin/python \
  tests/movement_performance/dynamics_optimization/compare.py \
  --build /var/tmp/dynamics-build-new --out /var/tmp/dynamics-session-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --cpu 12
```

Repeat the final command with a different output directory for another session.
There are five models, three initial states per model, 24 balanced process-order
blocks, four samples per process, and 100 steps per sample after warmup. Python
does not run inside the timed loop. Default floating-point equality in the parent
runner is still strict; this algorithm experiment explicitly requests tolerance
because CRB changes the summation order. Every final state is checked against C
and the frozen Ada baseline with absolute/relative tolerance `2e-10`.

The extra correctness fixtures cover a 24-DOF chain, branching, multiple roots
including fixed massless grouping bodies, zero damping, and a wide-coordinate
fallback. The last fixture uses finite qpos values of approximately `6e9` on
three collinear slides: accumulated body centers leave the fast path's `1e10`
domain while individual state coordinates remain supported. It is not a timing
case. The tests also check mass symmetry/positive definiteness, dynamics
residuals, exposed forces, accelerations, trajectories, and status policy.

Evidence is under `evidence/`: source/build/harness snapshots, exact commands,
proof logs and obligations still open, checked-probe outputs, both timing
sessions, and file hashes. A completed numerical or timing test is not a proof
of the recursive pipeline. Proof claims refer to the archived source snapshots
and contracts of each invocation.
