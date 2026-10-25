# Direct four-lane reduction work in progress

No new numerical implementation is adopted in this checkpoint. The working
kernel keeps the verified vector Scale_Row from r503. The complete port,
whole dynamics proofs and C performance parity remain unfinished.

## C comparison and code-generation diagnosis

C3.17 mju_dotSparse_avx accumulates four products in a local vector, merges
lanes in the documented order and processes the scalar tail. The scalar C
fallback likewise keeps four local sums before returning the merged result.
The reviewed pinned C files are archived.

r511 changes only Dot_Blocks storage: four local accumulators and a local
rejection count are published once to the unchanged output parameters. Its
minimum closes 173 checks with seven inherited diagnostics; strict warning-free
`passed` is false. The initial 240-second run is terminated by the watchdog;
the 600-second run finishes after 553 seconds with no open obligations.

Actual release Dot_Four has 814 disassembled instructions and 3,804 bytes in
both variants. The eight differing instruction operands are source-line numbers
on range/overflow failure paths. This change does not remove the successful-path
overhead and is not adopted as a performance optimization. Equal instruction
counts alone are not treated as byte identity; the full comparison is retained.

## Direct arithmetic candidate

r515 uses the same rounded products and additions directly, with Real local
intermediates and structural count subtypes justified by the existing domain.
It preserves all public input/output/count/fast-fallback contracts and FP order.
Existing lane-unfolding lemmas and explicit Product equalities connect the
runtime expressions to the exact model. Final output subtype checks remain.
No assumed fact, suppression, unsafe FP option, trusted production body or
stronger public input condition is introduced.

r518 adds proof-only opaque recursive models and an empty-block lemma. The lemma
closes four checks, with inherited model diagnostics recorded separately.
r523 brings the existing Product contract/bounds into scope before each raw
product through Ghost Static constants. Its runtime arithmetic is unchanged.
These proof facts are obligations or consequences of proved contracts, never
assumptions. r516 and r520 reach the 600-second aggregate watchdog without a
complete final report; they do not establish a closed direct-loop proof.

Compilation of r518 shows a separate 580-instruction/2,656-byte Dot_Blocks with
four ymm arithmetic sites, where baseline Dot_Four is scalar. Dot_Four is now
incorporated into the caller, which grows from 1,834 to 2,034 instructions.
The separate helper/caller counts are not dynamic execution counts and do not
prove a speedup. The latest r523 changed-loop proof is tracked separately in
`pending-proof.json`; no whole-unit direct-reduction Gold claim is made here.
No integrated performance measurement of this candidate is claimed.

## Retained extended regression corpus

The existing dense/strided-sparse corpus is extended to call Dot_Blocks directly
and verify all four lane values bit-for-bit and the exact rejection count, in
addition to Dot_Four merging/tails and the existing ordered/forward fallback
checks. Signed-zero and all-large-product cases are included. Unchecked_Conversion
transports test bits only and is not a production body or proof premise.

Both retained baseline and r518 pass **36,079 cases per profile** in ordinary
validation and release with the normal checked compiler/FP settings. This is
numerical/compiler regression evidence, not a replacement for the unfinished
direct-loop proof or C equivalence/performance evidence. The tested providers
are retained in the repository as `check_solver_reductions.py` and
`reductions_probe.adb`, byte-identical to the executed inputs.

```sh
python3 experimental/dynamics-derivatives-candidate/tests/check_solver_reductions.py \
  --build FROZEN_SNAPSHOT --out NEW_OUTPUT
```

The archive preserves immutable frozen sources, completed raw proof reports,
timeout logs, assembly, actual build recipes, the extended corpus and executables.
Compiler/prover caches and mutable output of the active proof run are excluded.
It can be restored through the exact evidence store. No commit or push accompanies
this local checkpoint.
