# Validated entry reuse and deferred Jacobians

`baseline/` freezes the 28 smooth sources after the inertia policy work, before
this refactor. `baseline.json` authenticates those files. This experiment keeps
six full `Is_Ready` scans per successful Euler step and does not enable the
historical `Ready_Flag` experiment. See [results](../../../docs/readiness-performance.md).

Use the existing GNAT/GPRbuild/GNATprove bundle and the Python environment with
MuJoCo 3.14.0/NumPy. Replace output paths with fresh directories:

```sh
python3 tests/movement_performance/readiness/build.py \
  --out /var/tmp/readiness-build-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --reference-build /var/tmp/sparkling-movement-final

/var/tmp/sparkling-movement-env/bin/python experimental/smooth/tools/compare_numerics.py \
  --probe /var/tmp/readiness-build-new/checked/bin/smooth_probe \
  --report-dir /var/tmp/readiness-compatible-new --policy Compatible \
  --extra-fixtures tests/movement_performance/dynamics_optimization/fixtures
# Repeat with --policy Strict and a different report directory.

/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/inertia_policy/check_policy.py \
  --probe /var/tmp/readiness-build-new/checked/bin/smooth_probe \
  --out /var/tmp/readiness-boundaries-new

python3 tests/movement_performance/readiness/check_caches.py \
  --build /var/tmp/readiness-build-new --out /var/tmp/readiness-cache-probe-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains
# Repeat compare_numerics.py using this probe and a fresh report directory.

python3 tests/movement_performance/readiness/profile.py \
  --build /var/tmp/readiness-build-new --out /var/tmp/readiness-profile-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains

# Run after all compilation, proof and validation jobs finish; repeat separately.
/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/dynamics_optimization/compare.py \
  --build /var/tmp/readiness-build-new --out /var/tmp/readiness-first-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --cpu 12

# Diagnostic instrumentation, separately from the uninstrumented sessions.
/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/readiness/profile.py \
  --build /var/tmp/readiness-build-new --out /var/tmp/readiness-profile-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --fixtures /var/tmp/readiness-first-new/timings --cpu 12
```

The cache probe is test-only. It compares public eager materialization against
private deferred materialization and both consumers, checks idempotent reuse,
state invalidation and preservation under control/applied-force setters. It
checks exact cache values and physical state; it does not constitute a proof.
The profile checks six readiness calls per step, zero Jacobian construction on
fast multi-DOF paths, one construction on the one-DOF fallback, and unchanged
physical solve counts. Profile timings include clock overhead and nest within
phase timings; use only the uninstrumented sessions for performance claims.

The policy boundary fixtures and their `dof_simplenum`/armature qualifications
remain as documented in [inertia policy](../../../docs/inertia-policy.md).
