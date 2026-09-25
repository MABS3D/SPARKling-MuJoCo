# Six C-path optimizations: reproducible evidence

The delivered runtime source is the `source` tree in
`build-inputs-and-binaries.zip`, built from the final repository snapshot
`/var/tmp/sparkling-six-final-source6`. Its runtime sources matched the working
tree byte for byte at final validation. `build.json` records compiler commands,
source hashes and the native SIMD C executable/library hashes. The C reference
is MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.

The frozen prior Ada baseline is the ancestor-factor implementation preceding
these six changes, not the original dense prototype. Its files and checksums
are also retained in the parent `baseline` directory and `baseline.json`.

## Delivered result

- Both policies pass 624 scenarios and 168,192 comparisons each against C.
- All 85 policy cases / 170 scenarios pass on the final checked executable.
- Final checked fault, readiness and spatial-fallback probes each pass 104
  scenarios / 28,032 C comparisons, including their private assertions.
- Reduction probe: 34,031 cases per checked/release build.
- Disjoint-row probe: 14,905 cases per checked/release build.
- Topology probe: all three simple fixtures in checked/release, both policies,
  stale imported constants, ownership, destruction and reuse.

The final timing sessions are `performance/first` and `performance/repeat`:
11 models × 3 states × 24 balanced blocks, CPU 12, four 100-step measured
repeats and two warmups per executable invocation. Both runs use the same
final release executable, without diagnostic instrumentation. Every measured
trajectory is compared with C. See `summary.json` and
[the report](../../../../docs/c-parity-six.md) for per-model results.

All 66 within-session paired bootstrap 95% intervals for current/prior Ada
are below one. These are per-case intervals without multiplicity correction,
not a guarantee across all machines or models. C remains faster in every
measured model. Raw process outputs and balanced ordering are retained.

## Gold and unfinished work

| Complete unit | Emitted proof checks | Open |
| --- | ---: | ---: |
| Smooth_Topology | 208 | 0 |
| Simple_Kernels | 10 | 0 |
| Ancestor_Rows | 773 | 0 |
| Spatial_Dynamics | 341 | 0 |
| Spatial_Storage | 94 | 0 |
| Solver_Kernels | 101 | 0 |
| Solver_Reductions | 740 | 0 |

These establish the specified rounded operations, bounds, exact storage
mapping, frame properties and rejection policy. They do not establish ideal
real arithmetic identities or the physical correctness of the entire engine.
The reduction whole-unit run also reports 84 successful flow checks.

Additional selected closures: flat kinematic allocation/clear/free 37+73+1;
phase-guard equivalence 1; historical readiness/Jacobian lemmas 1+1;
Pipeline storage-frame checks 15; rotation bound-widening lemma 3.

Still open, explicitly **neither Gold nor accepted Silver exceptions**:

- Fixed_Position: one normalization-cut assertion among 21 checks. Its
  downstream postconditions passing under that cut do not close the helper.
- Spatial.Prepare: four storage-frame obligations among 11 selected checks.
- Actuation_Phase.Compute: state-image preservation postcondition, one among
  33 checks; its stable-storage assertion closes.
- Load_Ancestor_Factor: two checks in the last completed 23-check diagnostic.
  A later broader-frame retry timed out without emitted checks.
- Build_Topology composition, complete force/inertia/pipeline integration,
  and the integrated precondition of the disjoint-row update remain within
  the pre-existing experimental proof scope.

Timeouts and zero-check runs are retained as diagnostics, never counted as
passes. No new arithmetic assumptions or deallocator trust boundary were
added. The historical modeled deallocators remain in use.

`proofs/*.json` and the zipped logs give exact targets, emitted counts, errors
and commands. `proof-sources.json` maps every proof snapshot file to its content
hash; `proof-source-objects.zip` stores those exact bytes by hash, including
older diagnostic snapshots. The two final specification edits after their
unit proofs are comment/spacing changes only, checked in
`proof-source-equivalence.json`.

## Provenance of refinements

Diagnostic archives retain the first, slower embedded-cache pilot, the flat
cache pilot, the build4 timing sessions, and the final rebuild identity tests.
Later proof-only source changes altered code generation between build4 and
build5; those earlier timing sessions are therefore **not** used as final
performance evidence. Build6 release is byte-identical to build5, and both
final timing sessions explicitly measure build6. Its checked executable was
revalidated after the final cut refinement.

The nested-clock profile and one-full/five-mutable guard count probe use earlier
frozen snapshots identified in their manifests. Each checks exact outputs
against its matching uninstrumented executable. Their timings are diagnostic,
not release speed claims.

The proof driver now merges hidden `.spark` flow errors into its diagnostics.
The regression test for the real hidden fatal error passes both checks; see
`proof-driver-regression.log` and the repository's `proof_diagnostics` fixture.

## Reproduce

Use the pinned GNAT/GCC and GNATprove 16.1 toolchain and a Python environment
with `mujoco==3.14.0` and numpy. Run from the repository root; use fresh output
directories. Environment-specific paths below match the recorded workstation.

```sh
python3 tests/movement_performance/c_parity_six/build.py \
  --out /var/tmp/six-build --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --reference-build /var/tmp/sparkling-movement-final

/var/tmp/sparkling-movement-env/bin/python experimental/smooth/tools/compare_numerics.py \
  --probe /var/tmp/six-build/checked/bin/smooth_probe --policy Compatible \
  --samples 24 --extra-fixtures tests/movement_performance/c_parity_six/fixtures \
  --report-dir /var/tmp/six-compatible

# Repeat numerical validation with --policy Strict and a fresh report directory.
/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/c_parity_six/compare.py \
  --build /var/tmp/six-build --out /var/tmp/six-first \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --cpu 12 --blocks 24

# Repeat compare.py sequentially with a fresh output directory, with all
# compiler/prover jobs stopped. Do not compare instrumented timing against C.
```

The executed rebuild helper is retained in `harness/rebuild_final_used.py`.
The current helper additionally writes objcopy output to fresh temporary files
so inspecting sections does not rewrite the compared executable in place;
recorded executable hashes were checked unchanged.

The parent directory contains the individual topology, reduction, spatial,
readiness, guard-count and diagnostic-profile drivers. Each proof report has
its exact GNATprove command. `manifest.json` hashes the complete retained
artifact set; it excludes only itself.
