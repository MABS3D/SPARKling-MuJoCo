# Independent validity of poses and Jacobians

The baseline freezes the preceding readiness/deferred-Jacobian implementation.
The active build keeps six readiness checks per successful Euler step, but those
checks inspect Jacobian values only when `Jacobian_Valid` is true. Pose updates
invalidate the flag without clearing the arrays; materialization alone overwrites
them. See [results and proof scope](../../../docs/jacobian-validity-performance.md).

Build and validate with fresh output directories:

```sh
python3 tests/movement_performance/jacobian_validity/build.py \
  --out /var/tmp/jacobian-build-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --reference-build /var/tmp/sparkling-movement-final

/var/tmp/sparkling-movement-env/bin/python experimental/smooth/tools/compare_numerics.py \
  --probe /var/tmp/jacobian-build-new/checked/bin/smooth_probe \
  --report-dir /var/tmp/jacobian-compatible-new --policy Compatible \
  --extra-fixtures tests/movement_performance/dynamics_optimization/fixtures
# Repeat with --policy Strict and a fresh report directory.

/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/inertia_policy/check_policy.py \
  --probe /var/tmp/jacobian-build-new/checked/bin/smooth_probe \
  --out /var/tmp/jacobian-boundaries-new

python3 tests/movement_performance/jacobian_validity/check_caches.py \
  --build /var/tmp/jacobian-build-new --out /var/tmp/jacobian-cache-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains
# Repeat compare_numerics.py with the test-only cache probe.

python3 tests/movement_performance/jacobian_validity/profile.py \
  --build /var/tmp/jacobian-build-new --out /var/tmp/jacobian-profile-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains

# Run twice, separately, only after all builds/proofs/validation finish.
/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/dynamics_optimization/compare.py \
  --build /var/tmp/jacobian-build-new --out /var/tmp/jacobian-first-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --cpu 12

/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/jacobian_validity/profile.py \
  --build /var/tmp/jacobian-build-new --out /var/tmp/jacobian-profile-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --fixtures /var/tmp/jacobian-first-new/timings --cpu 12
```

The extra cache probe injects ±1e100 into stale Jacobian storage. It verifies
that pose updates leave this storage untouched, fast paths ignore it, and fallback
materialization restores exactly the eager values. Marking those nonempty arrays
valid must make readiness fail. A Jacobian flag without valid poses is rejected
also for zero DOFs. The probe forces a work-domain failure at a hinge column,
checks that partial construction is not published and other caches/physical state
are preserved, then retries after recomputing poses.

Exact column formulas and exact store/frame contracts are distinct from a proof
that the complete traversal implements the physical Jacobian for every topology.
The latter refinement remains pending. Instrumentation never enters proof or
release binaries; its nested timings include clock overhead.
