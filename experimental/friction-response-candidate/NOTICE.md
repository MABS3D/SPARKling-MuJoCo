This candidate translates algorithms from MuJoCo 3.14.0, upstream commit
9ecbb9d7b5ee623f54745638d36799ff90e6f7cd:

- `src/engine/engine_util_misc.c`: `mju_encodePyramid`, `mju_decodePyramid`.
- `src/engine/engine_solver.c`: scalar PGS, `costChange`, PCG32/Fisher-Yates,
  Nesterov extrapolation and adaptive restart.
- `src/engine/engine_util_blas.c`: ordered four-lane `mju_dot` reduction.

MuJoCo is Copyright 2021 DeepMind Technologies Limited and is distributed
under Apache License 2.0. See the upstream license in `mujoco/LICENSE` in this
repository. Existing attribution and license notices remain applicable.

The test harness extracts the original C cost-change and PCG32 bodies into an
external temporary directory, and links only the oracle against the official
MuJoCo shared library. Production Ada does not depend on that library.
