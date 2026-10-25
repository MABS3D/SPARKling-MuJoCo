# Direct reductions: closed minimum, integrated timing still unconvincing

The active numerical implementation remains unchanged from the published
vector Scale_Row checkpoint. No direct-dot runtime candidate is adopted here.
Full MuJoCo migration, whole dynamics Gold and C performance parity are pending.

## Scoped functional proof

The direct block candidate keeps four local Real accumulators and the exact
C/AVX lane order, merge and scalar tail. Inline scalar helpers return Real with
proved Static product, addition and model-equality contracts. The public input
domain, exact rejection count and fallback behavior remain unchanged. No
assumption, suppressed check or new trusted production body is introduced.

The changed Dot_Blocks minimum closes all **197 checks** (182 proof, 15 flow)
in r543. Multiply_Work, Add_Lane_Value, Fast_Product and Fast_Advance_Lane close
5, 9, 13 and 14 checks respectively. Seven inherited recursive-model diagnostics
are kept separate; the strict warning-free `passed` field is false.

The whole-unit r554 attempt hits its 900-second watchdog without a completed
SPARK report. This is not a closed unit proof. Its long-running unchanged
small-row lemma is then factored through model-base and unfold contracts.
Initialize_Small_Models closes 8 checks; the changed Prove_Small_Row closes all
**53 checks** in r564, including its final equality and original postcondition.
The first version with one open final assertion, intermediate diagnostics and
an unsupported direct cut/invariant placement are preserved as unfinished or
rejected attempts. These are proof-engineering results, not Silver exceptions.

## Numerical and compiler checks

The r541 candidate passes **36,079 reduction cases per profile**, checking block
lanes bit-for-bit, exact rejected counts, four-lane merge/tails and legacy ordered
fallback over dense and strided patterns through 256 DOFs. All 13 broader groups
pass against C3.17/C3.14 in validation/release, including 5,760 derivative cases,
raw mass, compact cache and direct CRB constructors. Each scope remains distinct
from universal C equivalence and ideal-real accuracy.

Assembly of r541 has a separate 2,491-byte/546-instruction Dot_Blocks with four
YMM arithmetic sites. Dot_Four is incorporated into the larger solver caller;
its absence as a separate symbol never means that its work disappeared.
The normal shared builder reproduces the private current executable exactly.
A rebuilt baseline differs only in relative RPATH and derived dynamic metadata,
with identical machine code, rodata and data; full ELF identity is not claimed.
The actual benchmark verifies copied executable and shared-library hashes.

## Integrated movement

r557 covers all 30 supported smooth Euler scenarios with three byte-identical
copies per role. r562 repeats 15 scenarios from five critical models using six
copies per role. Both use 36 balanced cyclic/reverse blocks, 8 samples, 32 warmups,
100 steps, CPU 12, normalized argv0, shared immutable fixtures and replica-then-
block bootstrap intervals. Ada endpoints match exactly and C endpoints meet the
recorded tolerance. No own compiler, prover or archive job overlaps either run.
C is the normal source-built native C3.17 SIMD/LTO reference, contraction off.
Its shared library is common to all C launchers; independent library placement
is not covered by this experiment.

In the six-copy repeat, chain24 current/baseline medians are 1.01123, 1.00161 and
1.01067; all intervals include 1. The corresponding current/C medians are
2.40316, 2.35243 and 2.38178. Branches24 intervals also include 1. The initial
free-ball state-0 regression is not confirmed in the repeat. Hinge medians show
about 9-10% less time, but one of its three repeated intervals still includes 1.
All workload-specific measurements and uncertainty remain available. No
unweighted average across models or arbitrary noise allowance is used.

The SIMD instruction change does not establish the intended multi-DOF benefit,
so the runtime remains private. r565 starts a further compiler-boundary trial
that combines accumulation and merge in one outlined routine, with the proved
ghost small-row factoring. Only its immutable inputs are captured here; its
active r566 proof and r567 build outputs are excluded. Read actual process/tool
state before resuming them. No result is inferred from a pending file.

## Reproduction and storage

`direct-dot-contracts.zip` retains frozen sources, exact manifests, copied SPARK
reports, all completed logs, numeric results, executables and raw movement
samples. Compiler/prover caches are excluded. Prior r510 baseline inputs are
in the r525 bundle and r499 movement fixtures in the r503 bundle; their inventory
hashes remain unchanged. External toolchains and the C shared library are
identified by hashes and are not embedded. Restore exact ZIPs with
`python3 tools/evidence_store.py restore` before extracting them at their recorded
paths. The runners record all commands, flags, versions and source hashes.

This is a local evidence checkpoint, separate from proof or performance
acceptance. It does not publish a commit or change the active runtime.
