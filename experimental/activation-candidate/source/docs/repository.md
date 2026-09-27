# Repository organization

`spark-port` is the default and active development branch. The `foundation`
work is merged into it without rewriting either branch's history.

- `src/`: Ada/SPARK port and generated model definitions.
- `docs/`: contracts, proof scope, performance reports and policies.
- `experimental/`: explicitly scoped collision and smooth-dynamics prototypes.
- `tests/` and `tools/`: tests, reproducible comparison tools and archived evidence.
- `mujoco/`: upstream reference submodule, pinned to MuJoCo 3.14.0.

Evidence directories intentionally retain source snapshots, build metadata,
measurements and proof receipts, including failed experiments. They are not
build scratch directories. See each evidence README and manifest for provenance.

## Branch consolidation — 2026-09-25

The inherited upstream branches below are reference history, not SPARK work.
They are retained as `archive/2026-09-25/<old-branch-name>` tags so their tips
remain recoverable after branch cleanup. In particular, the old remote `main`
was the upstream C development tree; it was not the SPARK development branch.
Their unreviewed C changes are not merged into the port or its pinned submodule.

| Former branch | Preserved commit |
| --- | --- |
| `actions-version` | `030a30ea49c84a216476a74e8c0aa52353340899` |
| `build-yml` | `b718d79d4e10213703c95230f219805c214f9078` |
| `cmake` | `155d6c686a87fdc56b1a21a9b106444dbdfa6073` |
| `crt-plugin-init` | `314965a3cb81cfd19686ed31b9f85b28a6ce1e4b` |
| `dependabot/npm_and_yarn/wasm/brace-expansion-2.1.2` | `aed409cfb942c0c9cbcd5c1e0fb671406e5d00a4` |
| `dependabot/npm_and_yarn/wasm/postcss-8.5.26` | `e1341f7c6b59a2997c39edf58c5ba628fd6e0925` |
| `dependabot/pip/mjx/pip-26.2` | `01d64ff8122685b7f9f223dd7bbbb9ed35fa7b5a` |
| `dependabot/pip/python/pillow-12.3.0` | `faaf6ae5fdfdf992bd6fdef691969dd7d7937fd3` |
| `dependabot/pip/python/pip-26.2` | `e19a62fd111a8afa55927e5e80a1ccd15070af9c` |
| `dependabot/pip/python/pytest-9.0.3` | `685c9ca5befcf8b107e09b7326ed5438c1e982c1` |
| `dependabot/pip/python/setuptools-83.0.0` | `a219e2fd979e1a1dcfd9779a455ce69d1df6e8ef` |
| `erez-tom-patch-1` | `50c27cf771c40d373a9485e6f4ffab3fe9f4b727` |
| `haroonq-patch-1` | `25fe3c08f58736725c9445a83308f48fb582b2f7` |
| `haroonq-patch-2` | `48bcdf22c88cccf2f8d871b0be8c79c508b8c331` |
| `live` | `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd` |
| `main` | `2ca87041807fc2e66331ca5b0f276bf3abb472a5` |
| `mjwarp_doc_batched_model_field_warning` | `8e39d5049610bf7bb4cdc6aacd304d58c5f61311` |
| `quagla-patch-1` | `7fb4442685a6a5dc54478a936ecea235a15fe3ac` |
| `yuvaltassa-patch-1` | `ae4c5bb4bb822272f5cb040648e9c124135e9a29` |

To inspect an archived branch, use `git show archive/2026-09-25/<old-branch-name>`.
To resume it, create a branch at that tag with `git switch -c <new-name> <tag>`.

The pre-consolidation SPARK tips are also retained as
`archive/2026-09-25/foundation` and `archive/2026-09-25/spark-port`.
