# Publication verification — 2026-10-01

The current combined smooth sources pass a fresh checked comparison against
the official MuJoCo 3.14.0 library:

- 400 joint/scalar scenarios, 45,584 comparisons.
- 320 spatial-tendon/scalar scenarios, 21,944 comparisons.
- 32 quaternion/atomic-failure boundary scenarios.
- The ball capacity model with 280 positions and 210 DOFs.
- Two explicit unsupported-feature rejections for ball/free with spatial tendons.

The differential groups overlap on scalar regressions. They use external loads,
100-step trajectories and the existing absolute/relative tolerance `2e-10`.
The build manifest records 137 source/input hashes and the reference library
hash. These tests do not constitute a complete dynamics proof.

The command executed from the repository root was:

```sh
/var/tmp/sparkling-movement-env/bin/python \
  experimental/smooth/tools/test_manifolds.py \
  --out /var/tmp/sparkling-publication-20261001/checked \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --expect-scalar-tendons
```

Candidate proofs, differential tests and benchmarks retain their recorded
source scopes; they were not all rerun during publication. The audit verifies
the current material and tendon-view source hashes, checksums, new ZIP archives
and the frozen mesh source snapshot. The newer mesh benchmark script adds a
supplementary layout comparison; the measured original remains archived.
The 67 sealed text proof logs under ignored object directories are intentionally
included. No external build scratch is imported.

See the [publication index](../../../docs/publication-2026-10-01.md) for changes,
proof boundaries, performance limitations and integration still required.
