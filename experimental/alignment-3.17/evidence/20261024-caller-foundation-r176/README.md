# Local caller and complete foundation checkpoint r176

No commit, push or production migration was performed. Production remains on
3.14. The reference is official MuJoCo 3.17.0, commit
`800a109a4bdd02cb60404d565db4ae16fb04a53b`.

The final foundation r176 contains the byte-identical library/project closure
of proof snapshot r174 (46 files). Model_Admission closes 116 whole-unit checks;
there are no open obligations, assumptions or proof skips. Two recursion and
two operator-reassociation warnings remain explicit: obligations_closed=true,
strict passed=false. The separately proved structural kernel contracts remain
prerequisites, not an unverified trusted replacement.

The affected caller contracts close: Diagnose_Sparse 54, Diagnose_Assets 67,
Compute_Caps 38, Diagnose 14 and Validate 7. The mesh core closes 36 checks,
its exact-result wrapper six, its static layout lemma two and Meshes_OK four.
The joint-count layout lemma closes six. Unchanged subprogram contracts/bodies
and contexts are audited before reusing their earlier scoped receipts. These
results do not claim complete generated-clause or validation-unit proof closure.
The four old reduction contracts establish bounds, not exact counts; exact
count models/capacity sufficiency remain unfinished Gold work.

Validation and release each pass ten Ada suites, 77 Python tests, twelve ABI
scenarios, eight wide-bound cases, deterministic generation and all 100 corpus
inputs. The expected load outcomes remain 49 OK, 36 Unsupported_Flex and
15 Unsupported_Plugins. Both profiles also pass 49 real C-produced admission
cases: 33 FLEX helper, seven B/D, six map-bound and three mesh cases. Exact Ada
diagnostics are checked; non-FLEX scenarios additionally require exact complete
validator diagnostics. FLEX full admission remains unsupported.

`validation.zip` retains seven source snapshots (including the earlier r158),
26 proof attempts and all r170/r176 complete gate receipts, logs, projects,
small inputs and the actual C validator library/license. It includes failed
mesh/capacity checks, the 240-second diagnostic limit and the exact GNATprove
internal-error prototype. The final plain source tree is under
`foundation/r176/source/`; proof snapshots have their source-hash manifests.
`archive-manifest.json` lists every member and every omitted large generated
MJB or untimed executable by path, hash and size. Original omitted artifacts
remain at the recorded local paths. No missing/failed case was removed from
the acceptance runs; archive omission is separate from test execution.

The preparation driver was subsequently made safe for already integrated
foundations. Its final version is `drivers/final/prepare_admission.py`.
Smoke manifests r177/r178 verify that integrated r176 and unoverlaid r5 inputs
produce the identical proved library. Their source bytes are reused from
`foundation/r176/source/`, as recorded in summary.json.

The following commands run the current working tree with fresh output paths:

```sh
python3 experimental/alignment-3.17/tests/build_foundation.py --phase prepare --out /var/tmp/foundation-new --reference-root /path/to/pinned-mujoco317
python3 experimental/alignment-3.17/tests/build_foundation.py --phase generate --out /var/tmp/foundation-new --python /path/to/mujoco317/bin/python
python3 experimental/alignment-3.17/tests/build_foundation.py --phase verify --out /var/tmp/foundation-new --python /path/to/mujoco317/bin/python --reference-root /path/to/pinned-mujoco317 --mode validation
python3 experimental/alignment-3.17/tests/build_foundation.py --phase verify --out /var/tmp/foundation-new --python /path/to/mujoco317/bin/python --reference-root /path/to/pinned-mujoco317 --mode release
python3 experimental/alignment-3.17/tests/prepare_admission.py --foundation /var/tmp/foundation-new --out /var/tmp/admission-new
python3 experimental/alignment-3.17/tests/prove_admission.py --engine /var/tmp/admission-new --out /var/tmp/diagnose-new --subprogram Diagnose
python3 experimental/alignment-3.17/tests/prove_admission.py --engine /var/tmp/admission-new --out /var/tmp/admission-whole-new --whole-admission
```

For the exact historical checkpoint use the archived source/driver versions
and matching toolchain, rather than later working-tree edits. Complete FLEX,
plugin/engine/API migration, legacy compact CSR domain differences, exact count
models, global Gold and C3.17 movement performance remain open. No performance
improvement or complete port acceptance is claimed by these loading/proof tests.
