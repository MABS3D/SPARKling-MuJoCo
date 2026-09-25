# Solver row optimization evidence

Final implementation: `build.json`, source/flags/logs in `build-inputs.zip`.
`first.json` and `repeat.json` are the independent final release sessions;
`summary.json` is a compact per-model view, not a weighted aggregate score.
The corresponding raw archives include inputs, models and process outputs.
`pre-hybrid-diagnostic.json` is an earlier implementation, not the final result.

`compatible.json`, `strict.json`, `boundaries.json`, `failures.json` and `lanes.json`
record final validation. `exact.json` and `prior-outputs.zip` preserve the exact
comparison with the preceding Jacobian-validity stage. Instrumented `profile.json`
includes clock overhead and is diagnostic only.

`proofs` contains successful and unsuccessful attempts. Final row/count bodies
are covered by `verified-kernels`; final scalar-bound specialization by
`single-bound`; final Jacobian caller by `ensure-final`. `solve-final` has 47 open
checks and is not a completed proof. Manifests map every proof snapshot path to
its SHA256-named file in `proof-source-objects.zip`. Earlier Boolean variants and
an abandoned short-buffer branch are retained as history, not release sources.

`boolean-reduction-reproducer.zip` contains the failing optimized source,
disassembly/output and the passing scalar-control project/output. Both use the
same source tree. For relocation, update the absolute source directories in the
extracted GPR files; the scalar control adds `-fno-tree-vectorize` to compilation
and linking. The toolchain version and ordinary release flags are recorded in
`build.json`. `simd.txt` shows representative instructions from the final binary.

`manifest.json` records hashes and lengths of the evidence files, including
nested proof manifests. No archived timing or old proof is silently replaced.
