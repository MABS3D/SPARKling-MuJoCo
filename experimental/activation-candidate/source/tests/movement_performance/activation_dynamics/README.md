# Activation dynamics checks and timings

Use Python with `mujoco==3.14.0` and numpy, native GNAT 16.1, GNATprove and
gprbuild. All output directories must be new. No test changes the main model or
source tree. Run from the repository root.

Build a checked probe with `experimental/smooth/tools/compare_numerics.py`
(`--toolchain-root`, `--report-dir`); its result JSON identifies the executable.
The probe reads compact `na` activation values after qpos/qvel/control/applied
force, before any external body wrench values, time and step count.

```sh
python tests/movement_performance/activation_dynamics/test_activation.py OUT PROBE
python tests/movement_performance/activation_dynamics/test_activation.py STRICT_OUT PROBE Strict
python tests/movement_performance/activation_dynamics/test_edges.py PROBE EDGES_OUT
python tests/movement_performance/activation_dynamics/test_failures.py PROBE FAILURE_OUT
```

The first test covers 36 combinations × 12 randomized states. Edges include
mixed active/stateless arrays, external body wrenches and 1/6/24 DOFs with up to
192 active actuators, plus a mixed-type 1,024-actuator capacity case. Failure tests are policy/atomicity tests, not assertions
that C rejects the same inputs. The regular compare_numerics suite remains a
regression test for stateless models. The checked probe also validates reset,
invalid sizes, high array lower bounds, non-advancing Forward and cache behavior.

Release comparison:

```sh
python tests/movement_performance/activation_dynamics/build.py \
  --out BUILD --toolchain-root TOOLCHAINS --c-library LIBMUJOCO
python tests/movement_performance/activation_dynamics/measure.py BUILD TIMINGS 24
python tests/movement_performance/activation_dynamics/diagnostic.py BUILD ATTRIBUTION
```

`measure.py` reconstructs MJB files from the supplied XML, uses the exact saved
nonzero inputs, and checks final qpos/qvel/time/activation against saved 3.14 C
outputs in every run. Records include distributions and bootstrap ratios.
Run twice without concurrent builds/proofs when a quiet host is available.
Never interpret an average of percentage speedups as whole-engine performance.

`diagnostic.py` holds controls/activations at zero so the physical trajectories
are identical with and without dynamics; it is cost attribution only. The
separate nonzero trajectory comparisons determine acceptance. Regenerate the
fixtures/oracle outputs explicitly with `prepare_bench.py OUTPUT_DIRECTORY`
when intentionally changing the reference; do not silently relabel old data.

Builds freeze the dependency closure and record compiler flags, CPU, executable,
source, library and C++ runtime hashes. The local handoff evidence records
actual proof commands and immutable proof snapshots, including failed attempts.
