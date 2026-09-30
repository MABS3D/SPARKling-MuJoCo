# Publication verification — 2026-09-30

A fresh checked build of the combined active smooth sources passes against
the official MuJoCo 3.14.0 library:

- 400 joint/scalar scenarios, 45,584 scalar comparisons.
- 320 spatial-tendon/scalar scenarios, 21,944 comparisons.
- 32 quaternion/atomic-failure boundary scenarios.
- A ball-joint capacity model with 280 position coordinates and 210 DOFs.
- Two explicit loader rejections for ball/free joints combined with spatial tendons.

Both differential groups use external forces, 100-step trajectories and the
existing absolute/relative tolerance `2e-10`. Scalar regressions overlap between
groups. These are sampled comparisons, not universal C equivalence or a fresh
whole-pipeline proof. The build manifest records 137 source/input hashes,
the checked compiler command, harness hashes and the reference library hash.

The command executed from the repository root was:

```sh
/var/tmp/sparkling-movement-env/bin/python \
  experimental/smooth/tools/test_manifolds.py \
  --out /var/tmp/sparkling-publication-20260930/checked \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --expect-scalar-tendons
```

Saved JSON summaries, edge output, checked build logs and source audits describe
this publication. Generated binaries/build trees remain outside the checkout.
Candidate proof and performance reports retain their original scope; see the
[publication index](../../../docs/publication-2026-09-30.md).

The source audit records six differences between the archived spatial-tendon
integration snapshot and the subsequently optimized active pipeline. Its formal
results and timings apply to that snapshot; the fresh checked regression here
applies to the current source combination. Other selected current source hashes
match their recorded reports. The two older independent worktrees still match
the snapshots already published.
