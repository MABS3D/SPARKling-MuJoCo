# Proved phase-entry guard elimination

The frozen baseline is the working source after the pose-tree proof milestone.
It includes those previously uncommitted changes and is intentionally not Git HEAD.
`baseline.json` pins every smooth source used for the prior Ada executable.

Build (using the existing hash-pinned MuJoCo 3.14.0 C build):

```sh
python tests/movement_performance/phase_closure/build.py \
  --out /var/tmp/phase-build \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --reference-build /var/tmp/sparkling-six-final-source6
```

Run the existing integrated comparison twice in separate output directories:

```sh
python tests/movement_performance/c_parity_six/compare.py \
  --build /var/tmp/phase-build --out /var/tmp/phase-session1 \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --blocks 24 --cpu 12
```

Do not run proofs, builds or another benchmark during timing. The comparison
covers 11 models, three initial states each, alternating prior Ada/current Ada/C.
The library and binary hashes, compiler flags and hardware are recorded in the
build and measurement artifacts. Differential tests and proofs are separate.

Count the retained checks and verify exact instrumented/release outputs:

```sh
python tests/movement_performance/phase_closure/check_guard_counts.py \
  --build /var/tmp/phase-build --out /var/tmp/phase-guards \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --fixtures /var/tmp/phase-session1/timings --mutable-per-step 3
```

Instrumentation timing is not performance evidence. This guard count applies
to this frozen change; it is not a permanent acceptance requirement for future
optimizations.
