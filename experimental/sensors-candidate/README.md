# Native sensors recovered on 2026-10-02

The opt-in adapter owns sensor metadata and computes outputs from the actual Ada simulation and its contact/limit producers. The source model is freed by the differential probe. Sensor IDs 0 through 46 are represented by the current corpus; this is not universal coverage of their configurations.

Site rangefinders use MJ.Rays with synchronized Ada poses, material visibility, native mesh/BVH and heightfield traversal, and all six C 3.14.0 data fields. Contact reductions include none, minimum distance, maximum force and net force; the empty net-force result retains the global normal/tangent axes. Tactile sensors always reserve three channels per taxel, with tangent channels zero when frames are absent.

Validation: 264/264 trajectories, 204,352 values, 33 models, 8 samples and 30 steps against official MuJoCo 3.14.0. The sensor kernel has 73 proved checks, zero open obligations and full SPARK coverage, with ordered floating-point and range-width contracts. Receipts and exact frozen source hashes are in `evidence/recovery-20261002`. The context, geometry, engine composition and real-number accuracy are not proved by these kernel results. Integrated performance remains pending.

Remaining scope includes camera range images, tracking/target camera modes, delayed/history/interval sensors, mixed user/plugin sensors and advanced geometry-distance/tactile producers. Unsupported configurations return a status. Builtin primitive distance/tactile geometry is restricted to planes, spheres, capsules, ellipsoids, cylinders and boxes. The adapter retains the underlying smooth/constrained engine limits.

Reproduce:

```sh
python3 experimental/sensors-candidate/tests/build.py --out /var/tmp/sensors-repro --working-dependencies
/var/tmp/sparkling-movement-env/bin/python experimental/sensors-candidate/tests/check.py --binary /var/tmp/sensors-repro/build/validation/bin/sensor_probe --out /var/tmp/sensors-compare --samples 8 --steps 30
python3 experimental/sensors-candidate/tests/prove.py --out /var/tmp/sensors-range-proof --only Range_Width
python3 experimental/sensors-candidate/tests/prove.py --out /var/tmp/sensors-whole-proof
```

Builds/proofs run from frozen closures outside the checkout, with one job and memory/time watchdogs. The default build takes common dependencies from HEAD; `--working-dependencies` explicitly includes recovered working sources. Evidence never transfers automatically to a changed dependency closure.
