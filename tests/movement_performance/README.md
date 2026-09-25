# Integrated movement experiment

This page describes the historical math-bridge experiment. For the active CRB,
recursive-force and solve-reuse implementation, use the separate
[dynamics optimization experiment](dynamics_optimization/README.md), which
freezes the complete prior smooth sources instead of overlaying the bridge.

This measures 100 successive Euler steps, including kinematics, dense inertia,
forces, actuation, solves and integration. It uses the existing smooth fixtures:
one motorized hinge, a branched five-DOF model and a twelve-DOF chain. Each model
has three deterministic nonzero initial states and constant inputs. These are
representative of the supported prototype, not a distribution of all MuJoCo
applications. Contacts, constraints, free/ball joints and rendering are absent.

Three independently linked executables run the same saved MJB and state:

* `baseline`: the smooth prototype before the math bridge, preserved in
  `baseline/mj-smooth_math.adb`; all other sources match the current snapshot.
* `current`: the **experimental candidate**, preserved in
  `candidate/mj-smooth_math.adb`, with production Gold `MulMatVec3` and
  `MulMatTVec3` kernels on its call path. The name is a historical report key;
  the candidate was rejected and is not the active smooth implementation.
* `c`: native upstream MuJoCo 3.14.0, calling `mj_step` in C, without Python in
  the timed loop. It is linked to a separately built shared C library.

The runner overlays the preserved bodies explicitly, including in the checked
build. The active prototype retains its original body after the measured
regression. See [results and decision](../../docs/movement-performance.md).

This isolates the effect of the **bridge**. It does not retroactively measure
all past kernel optimizations. In particular, generic matrix transpose is not
part of this movement call path. The prototype uses dense mass construction and
additional condition-estimation solves, whereas C uses its upstream algorithms.
Those costs belong in the total result; no parity of algorithmic work is claimed.

Model loading, state reset, controls, allocation of results, output formatting,
Python orchestration and numerical comparisons are outside timed intervals.
Internal work performed by a simulation step remains inside. Each process warms
up twice and reports four trajectory samples. Ada checks the returned status
after every step; C warnings are checked after each trajectory. All final states
are consumed and checked. Six permutations of process order balance treatment
positions and precedence; the default repeats this over 24 blocks, pinned to one
CPU. Keep proofs, builds and other heavy jobs out of the measurement interval.

The report contains all samples, median/MAD, p95 and paired bootstrap intervals.
The p95 is for **trajectory-average cost per step**, not individual-step latency
or a real-time worst-case bound. Intervals describe a single session, with no
multiple-comparison correction. Repeat close decisions in another session.
No fixed percentage is automatically declared noise.

Every result is compared with the pinned Python/C numerical oracle at
`abs(error) <= 2e-10 + 2e-10*abs(reference)`. Baseline/current Ada outputs must
also compare exactly as floating-point values. This does not test NaN payloads
or signed-zero bits. A separate checked build runs the broader smooth numerical
and policy suite. Tests do not establish whole-pipeline Gold: the experimental
dynamics retain their documented open proof obligations.

The default Ada comparison remains exact. The explicit
`--ada-comparison tolerance` option applies the same absolute/relative bound
to Ada versus Ada when testing a changed floating-point algorithm; the report
records the mode and maximum observed discrepancy. `--extra-fixtures` and
repeatable `--model` options select additional cases without changing defaults.

## Reproduce

Use Python with `mujoco==3.14.0` and NumPy, plus the native GNAT/GCC toolchain.
Build upstream commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd` with CMake Release,
AVX intrinsics and LTO enabled, and both C/C++ release flags:

```text
-O3 -march=native -ffp-contract=off -ffinite-math-only
-fno-trapping-math -fno-math-errno
```

Disable examples, tests and simulate. Use the same GCC installation as GNAT.
The report's `c-build` evidence records the actual CMake configuration, flags,
source hashes, library hash and dependency revisions. The runner records its
Ada/C driver flags, compiler versions, source snapshots and binary hashes.
Ada is linked with LTO in the executable; the C engine has LTO within its shared
library, with an external `mj_step` call. This is an explicit linkage difference.

```sh
python tests/movement_performance/run.py \
  --out /var/tmp/movement-new \
  --toolchain-root /path/to/toolchains \
  --c-library /path/to/native/libmujoco.so.3.14.0 --build-only

python experimental/smooth/tools/compare_numerics.py \
  --probe /var/tmp/movement-new/checked/bin/smooth_probe \
  --report-dir /var/tmp/movement-checked-new --samples 24

# Run only after correctness checks and proof/build jobs finish.
python tests/movement_performance/run.py \
  --out /var/tmp/movement-new --reuse-build \
  --toolchain-root /path/to/toolchains \
  --c-library /path/to/native/libmujoco.so.3.14.0 --cpu 12
```

The output directory must be new for a build; its `timings` directory must be
new for a measurement. A partial report has `complete: false`; a failed command
or incomplete report is never a successful experiment. `source` and the preserved
harness are the build inputs. To change source, create a new build/report rather
than using `--reuse-build`.
