# Vectorized solver rows and numeric bounds scans

The baseline freezes the preceding independent-Jacobian-validity implementation.
Current `Add_Row`, `Scale_Row` and `All_Within` preserve exact rounded per-entry
expressions and domain decisions. Integer rejection counts permit SIMD without
the Boolean-reduction miscompile reproduced with this GNAT/GCC 16 toolchain.
A rejected solver row is disposable scratch: callers return immediately; physical
state remains unchanged and a retry reloads the factor from the mass matrix.

See [results, limitations and proof scope](../../../docs/solver-rows-performance.md).

Use fresh output directories (the tools deliberately refuse to overwrite evidence):

```sh
python3 tests/movement_performance/solver_rows/build.py \
  --out /var/tmp/rows-build-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --reference-build /var/tmp/sparkling-movement-final

/var/tmp/sparkling-movement-env/bin/python experimental/smooth/tools/compare_numerics.py \
  --probe /var/tmp/rows-build-new/checked/bin/smooth_probe \
  --report-dir /var/tmp/rows-compatible-new --policy Compatible \
  --extra-fixtures tests/movement_performance/dynamics_optimization/fixtures
# Repeat with --policy Strict and another report directory.

/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/inertia_policy/check_policy.py \
  --probe /var/tmp/rows-build-new/checked/bin/smooth_probe --out /var/tmp/rows-policy-new

python3 tests/movement_performance/solver_rows/check_rows.py \
  --build /var/tmp/rows-build-new --out /var/tmp/rows-lanes-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains

python3 tests/movement_performance/solver_rows/check_failures.py \
  --build /var/tmp/rows-build-new --out /var/tmp/rows-failures-build-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains
# Repeat compare_numerics.py with the resulting test-only smooth_probe.

# Timing sessions must run separately after all builds, proofs and tests finish.
/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/dynamics_optimization/compare.py \
  --build /var/tmp/rows-build-new --out /var/tmp/rows-first-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --cpu 12
# Repeat with another fresh output directory.
```

`rows_probe` covers lengths 0–256, nonzero array lower bounds, each rejected lane,
SIMD tails, inclusive limits, adjacent floating-point values and extreme permitted
operands. It uses explicit failure branches even in release builds. The failure
probe injects bounded symmetric matrices into private mass storage and exercises
every rejected position of the first updated row; it checks sticky clamp diagnosis,
physical-state/input preservation, invalid acceleration, and successful retry.
Neither test child nor instrumentation enters the ordinary release/proof build.
