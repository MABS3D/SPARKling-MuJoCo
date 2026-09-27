# Diagnostic cost attribution — NOT production optimizations

See [the report](../../../docs/cost-attribution.md). Guard removal variants are
intentionally unproved; do not copy them into active simulation or claim Gold.
The fused-force variant changes internal Gravity/Bias outputs and FP order.

Reconstruct the frozen verification build using `../compact_mass_retry/build.py`,
then run (replace the placeholder paths):

```sh
python3 build.py --frozen FROZEN_BUILD --out NEW_BUILD --toolchains TOOLCHAINS
PYTHON_WITH_MUJOCO measure.py --build NEW_BUILD --inputs INPUTS --out SESSION1 --session 11
PYTHON_WITH_MUJOCO measure.py --build NEW_BUILD --inputs INPUTS --out SESSION2 --session 12
PYTHON_WITH_NUMPY summarize.py SESSION1 SESSION2 --out summary.json
```

`INPUTS` is the extracted `inputs/` folder in evidence/measurements.zip. Run
sessions sequentially, after builds have finished. Default 20 blocks balances
ten executables. `--only phase_scans` was used to add the tenth executable to
the original pilot build; it is included automatically in a fresh build.

Evidence includes full source/build snapshots, binaries, patches, source hashes,
C source excerpts, compiler flags, hardware/reference metadata, sampled outputs,
per-block timings, within-session CIs, and SHA-256 sums. The old nine-variant
pilot is retained separately and excluded from final summary. No proof was
attempted or claimed for diagnostic ablations. Active simulator files unchanged.
