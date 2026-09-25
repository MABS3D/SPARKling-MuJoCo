# Integrated movement evidence

See [interpretation and decision](../../../docs/movement-performance.md).
The bridge was rejected. `current` in the historical JSON means that candidate;
the active prototype's math body was restored to the preserved baseline.

* `first.json`, `repeat.json`: complete reports, including every timed sample,
  final state, process order, block pairing and summary. Both report `complete`.
* `first-raw.zip`, `repeat-raw.zip`: original native outputs, XML/MJB fixtures,
  deterministic state inputs and oracle results. No samples were filtered out.
* `build.json`, `build-inputs.zip`: measured binary hashes, compiler switches,
  versions, CPU information, immutable Ada sources, harness and build logs.
  The recorded original runner captured the candidate from the working source.
  The maintained runner now overlays the preserved candidate explicitly, so the
  experiment remains reproducible after restoring the active source.
* `reproduction.json`: a fresh build with the maintained runner produced
  identical baseline, candidate and C release executable hashes and identical
  states on all three models. The checked executable has different debug paths.
* `c-build/`: actual native C configuration, flags, build log, source and library
  hashes, and dependency revisions/hashes. AVX intrinsics and LTO are enabled.
* `checked-numerics.json`, `checked-numerics.zip`: checked candidate numerical
  and status tests against the pinned Python/C oracle, including raw outputs.
* `proof-small/`, `proof-unit/`: minimal diagnostics and complete candidate
  `MJ.Smooth_Math` proof (751 proved checks, 61 flow checks, zero open/errors).
  Absolute scratch paths in manifests locate the original sessions; the final
  Ada source snapshot is also preserved in `build-inputs.zip`.
* `quaternion-rejected-proof/`: separate unpromoted quaternion bridge, four open
  assertions, and its exact source. This is not part of the final candidate.
* `candidate-apply.asm`: disassembly of the candidate's matrix-vector wrapper.
* `summary.json`: scope and decision; `manifest.json`: receipt for these files.

The two runs are on one machine in one period. The test does not establish a
universal performance ordering, individual-step tail bounds, full-engine
equivalence, or Gold for the unfinished dynamics. It does establish a usable
whole-step baseline and rejects this particular bridge on measured workloads.
