# Owned activation regression

These checked regressions run against the active smooth engine. Reference:
MuJoCo 3.14.0. Fixtures and the original three scripts come from the isolated
adhesion/activation candidate; the probe now also retains manifold, tendon,
muscle and fluid support. This directory does not certify the old candidate as
fully integrated.

From the repository root, with the project Python environment:

```sh
python tests/movement_performance/activation_dynamics/test_activation.py /tmp/activation-results /path/to/smooth_probe Compatible
python tests/movement_performance/activation_dynamics/test_edges.py /path/to/smooth_probe /tmp/activation-edges
python tests/movement_performance/activation_dynamics/test_failures.py /path/to/smooth_probe /tmp/activation-failures
```

`test_activation` covers enable/clamp/early/limit combinations. `test_edges`
covers exact-filter time constants, mixed stateless/stateful actuators and the
1024-state capacity. `test_failures` checks atomic rejection, including successful
Forward with a next activation that Euler must reject. Output directories must
be new. These are correctness tests, not benchmarks; timings are measured by
`experimental/smooth/tools/benchmark_force_integration.py`.
