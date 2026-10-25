# Structural validation: native row-domain checkpoint r186

The 3.17 foundation builder now applies `validation-structures.patch` after
`validation.patch`. Production stays on 3.14; its source files are unchanged.
This checkpoint is local and has not been committed or pushed.

## Proved scope

`MJ.Model_Structures` retains its complete-unit closure of 315 checks after
29 minimal scopes. These are the same checks viewed minimally and as one unit,
not 630 distinct checks. Four recursion warnings and two operator-reassociation
warnings remain visible (six total). Functional properties cover CSR admission
and first bad row, ordered subset search, row equality, ancestor counts and the
mass-row relation under their explicit span/order/link preconditions.

Validation and release each pass its 1230 isolated cases: 1222 comparisons with
the unchanged pinned C3.17 `validateSparse`, seven owned-array shape cases and
one deliberate duplicate-tendon correction. C3.17 rejects the nonstrict width-two
`[0,0]` row at Nv1; Ada keeps that compiler-produced case admissible. The Shape
comparison uses Int64 lengths, correcting the previously found 2**31 conversion
issue without narrowing its public domain.

The current `MJ.Model_Admission` whole-unit proof closes 166 checks, including
the four exact native-CSR adapters, Check_Maps and the shape lemmas. Two recursion warnings and two
operator-reassociation warnings remain visible (`obligations_closed=true`,
strict `passed=false`). Success contracts compose the native CSR/FLEX/B/D/map predicates
under the separately proved kernels and layout/sparse preconditions. Each new
native-CSR adapter specifies equality to the complete CSR mapper/kernel result,
including the field and first offending row, rather than just the status.

The mesh core closes 36 checks under size/mesh-layout preconditions. A proved
static ghost lemma derives that layout from the unchanged public precondition;
the public Mesh_Faces_At wrapper closes six checks and specifies equality to
the core result. Meshes_OK closes four checks. No ghost declaration remains
inside an expression: the failed prototype triggered an internal GNATprove
error and is retained with its exact source and log.

The renewed affected caller contracts close: Diagnose_Sparse 42, Diagnose 14
and Validate 7. The earlier independent resource/capacity receipts remain
scoped as recorded in r176 (67/38 checks); they are not new whole-unit claims. The general layout lemma closes two
checks and the joint-array lemma six. Only the recorded scopes are claimed;
caller proofs use their callee contracts. Exact first-error completeness and
all generated-clause/whole-validation-unit proofs are not established here.
Legacy source comments about the proven checker predate this migration and
do not extend these receipts to unverified 3.17 code.

The four old count reductions close their current bound contracts (7/7/7/8
checks), but those contracts do not specify the exact count. Exact reduction
models and capacity sufficiency beyond the existing algebra/bound properties
remain Gold objectives, not mathematical Silver exceptions. No assumption,
trusted body, proof skip or narrowed public precondition was introduced.

## Complete foundation gates

The final generated foundation r186 and proof snapshot r184 contain exactly
the same 46 library/project files. Validation and release each pass:

- All ten existing Ada suites.
- All 100 raw corpus models and all expected validated-load outcomes: 49 OK,
  36 Unsupported_Flex and 15 Unsupported_Plugins. No corpus case is skipped.
- Twelve ABI scenarios and eight wide-reference boundary cases.
- Sixty-nine real C-produced structural admission scenarios.
- Deterministic regeneration and all 77 existing Python tests.

The 69 admission cases retain the previous 49 scenarios and add eight
C-accepted row-storage cases and twelve malformed native CSR cases. Exact typed Ada diagnostics are checked;
non-FLEX cases also require exact complete-validator diagnostics. The unchanged
official C3.17 validator supplies verdicts and implicated fields. The FLEX
fixture populates all three CSR patterns, including efm0, using vertex edge
constraints and bend-only elasticity following the actual C producers.
Full FLEX validation still returns Unsupported_Flex; these helper cases do not
remove that limitation or establish complete FLEX simulations.

[Current row-domain sources, receipts and controls](evidence/20261024-row-domain-r186/README.md)
include the six demonstrated pre-change Ada rejections, exact C fixtures and
the updated version-aware diagnostic tests.
[Earlier integrated evidence](evidence/20261024-caller-foundation-r176/README.md)
retains the compiler-error prototype, timeouts and scoped reuse audit. [Kernel evidence](evidence/20261024-structural-kernels-r150/README.md)
and [historical admission r158](evidence/20261024-model-admission-r158/README.md)
remain separate. Large regenerable images and untimed executable omissions are
listed by hash and remain available at their recorded local paths.

## Remaining work and reproduction

Native Sparse_M/B/D/Ten_J_OK now use the same independent row-span model as
C, permitting reordered/shared spans, gaps and unused storage. Unused columns
are not read or constrained. CSR_OK remains the legacy compact utility for
existing callers; it no longer defines native 3.17 admission. Two repeated
Row_Valid scans are removed from each parent-subset evaluation, and two
constant-time span guards from each D/B comparison; their preconditions are
proved from the already validated matrices.

The consumer audit finds an existing explicit compact-M restriction in the
experimental derivative adapter. It rejects noncompact inputs rather than
using wrong offsets, but still needs adaptation before 3.17 engine/API
migration. Spatial-tendon access uses actual row addresses/widths; plugin copy
preserves descriptors. This audit is not whole-consumer acceptance.
Four disjoint C row permutations preserve 32 torque-driven steps exactly in
the measured qpos/qvel/qacc values. Shared-storage inputs are admission-only;
no Ada movement or timing claim follows from those controls.

Complete FLEX admission, plugins/engine/API migration, exact count models,
full generated-reader/validator Gold and integrated C3.17 performance parity
remain open. No timing improvement is claimed here.

Regenerate the overlay with `tests/make_structures_overlay.py`.
`tests/build_foundation.py` prepares, generates and verifies the full candidate
in separate phases. `tests/prepare_admission.py` accepts either a verified
unoverlaid foundation or one with the identical structural overlay already
applied; both paths produce the same library and the patch is not applied twice.
Use `tests/prove_admission.py --subprogram NAME` before `--whole-admission`.
`tests/test_admission.py --mode validation|release|both` tests the requested
profiles without silently skipping cases. Drivers require fresh explicit Linux
output paths and the official 3.17 Python environment/reference checkout.
