# Equivalent numeric bound checks

Frozen baseline: `bf265c8f544e8e151c62a30634cd1d44ea613c3d`. Each baseline smooth
source is hash-pinned in `baseline.json`. The active optimization expresses
the dynamic-array scan as an absolute-magnitude comparison, retaining its exact
interval postcondition and integer SIMD rejection count. The singleton shortcut,
scalar work check, and fixed-size math/spatial predicates remain unchanged.

```sh
python3 tests/movement_performance/bounds_validation/build.py \
  --out /var/tmp/bounds-build --toolchain-root TOOLCHAINS \
  --reference-build PINNED_C_BUILD
PYTHON_WITH_MUJOCO tests/movement_performance/c_parity_six/compare.py \
  --build /var/tmp/bounds-build --out /var/tmp/bounds-session1 \
  --toolchain-root TOOLCHAINS --cpu 12 --blocks 24
```

Repeat the integrated comparison in another directory while no build, proof or
other benchmark is running. Use the shared `c_parity_six/summarize.py` for the
two sessions. The workload is 11 models, three initial states, four 100-step
trajectories per process, alternating baseline Ada/current Ada/normal SIMD C.
Inputs, outputs, CPU, flags, binary/source hashes and dispersion are recorded.

The builder also runs finite boundary cases in checked and optimized builds:
every component, both signs, exact thresholds, adjacent floating-point values,
zero, subnormals, large finite values, empty arrays, SIMD tails and high array
bounds. Explicit failures remain active with `-gnatp`. They complement the exact
functional proof and guard against optimizer mistakes. The compact helper's
standalone structural test is separate and is not on the active movement path.

Run `experimental/smooth/tools/compare_numerics.py` with the built checked probe,
24 samples, both policies, and `tests/tree_invariants/fixtures`. Count retained
checks using `../phase_closure/check_guard_counts.py --mutable-per-step 3`.
Instrumented output must equal release output; instrumentation time is not used.

See [results and proof scope](../../../docs/bounds-validation-performance.md).

The evidence is a frozen scan-only snapshot. Subsequent standalone compact helper
extensions and their current-source proofs are recorded in `../compact_mass_retry`;
they do not change the active stepping path.
