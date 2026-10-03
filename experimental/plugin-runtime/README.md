# Native plugin runtime and smooth-step adapter

Reference: official MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, rechecked on 2026-10-02.

`MJ.Plugin_Runtime` owns fixed-capacity plugin configuration, state and outputs. It dispatches native Ada callbacks through a generic formal subprogram. Initialization/reset/copy/destruction, stage-filtered sensor/passive/actuator evaluation, activation derivatives, advance and SDF queries are implemented. Rejected callbacks retain the published runtime, including outputs and plugin state. This transactional policy is explicit; it does not claim rollback of external callback side effects.

`MJ.Data.Plugin_Engine` copies an official compiled Model into owned Ada data, evaluates plugin forces in the smooth dynamics pipeline, and advances Euler position/velocity/activation/time before the advance callback. C is used only by the test oracle. The adapter supports the documented smooth engine domain, plugin sensors, joint transmissions and zero/one plugin activation dimension. SDF distance/gradient can be queried, but SDF collision geometry and mixed built-in/plugin sensor models are still rejected by this adapter. This is an opt-in project, not a replacement for the shared constrained entry.

Sensor callback selection follows `engine_sensor.c`, including `needstage=None` callbacks in the position stage. Cutoff selection intentionally keeps upstream's strict sensor-stage comparison. A generic callback is responsible for its own functional contract and effects; this runtime is not a dynamic C plugin loader or a port of the entire plugin ABI/resource-provider API.

## Recovery verification

A fresh checked build and 212 differential cases passed after recovery on 2026-10-02. The comparison covers slide/hinge trajectories at 0, 1 and 100 steps, all four sensor stages, activation derivatives, disable flags, force limits, cutoff and a multi-capability plugin. Lifecycle, stage selection, SDF and atomic failure edge checks also passed. Receipts: `/var/tmp/sparkling-services-plugin-recovery-20261002/manifest.json` and `compare-final/results.json`.

The proof driver freezes the source closure, records hashes and retains structured diagnostics; individual functions must be checked before the complete unit. The complete protocol (29 checks), runtime instance (61 checks) and actual Ada callback (54 checks) pass after minimal subprogram checks. Lifecycle, atomic rejection and unselected-state preservation are functional contracts. Engine composition proof is pending. No whole-engine Gold or full movement performance claim follows from these differential tests. Recovery progress and exact source limitations are tracked in `plans/2026-10-02-recovery-services.md`.

Reproduction:

```sh
python3 experimental/plugin-runtime/tools/build.py --out /var/tmp/plugin-check
python3 tools/guarded.py --cap-mb 2500 --timeout 240 -- /var/tmp/sparkling-movement-env/bin/python experimental/plugin-runtime/tests/compare.py --binary /var/tmp/plugin-check/build/validation/bin/plugin_probe --out /var/tmp/plugin-compare
/var/tmp/plugin-check/build/validation/bin/runtime_edges
python3 experimental/plugin-runtime/tools/prove.py --out /var/tmp/plugin-cutoff --only Cutoff
python3 experimental/plugin-runtime/tools/prove.py --out /var/tmp/plugin-add --only Add
python3 experimental/plugin-runtime/tools/prove.py --out /var/tmp/plugin-multiply --only Multiply
python3 experimental/plugin-runtime/tools/prove.py --out /var/tmp/plugin-whole
```

Every command uses one build/proof job and the bounded watchdog. Output directories must be fresh unless the build driver is explicitly given `--resume`, which refreshes plugin sources while preserving frozen common dependencies.
