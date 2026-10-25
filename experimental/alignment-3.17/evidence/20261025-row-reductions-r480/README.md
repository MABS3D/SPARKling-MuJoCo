# Generic row reductions and rejected optimization experiments

Local checkpoint after published commit `6b552b3af`. None of the three private
kernel variants is adopted. The active arithmetic/kernel remains byte-identical
to r455. The retained addition is a dedicated generic-row regression corpus;
performance parity, complete dynamics Gold and the full port remain open.

## C review and private variants

C3.17 `mj_factorI` updates compact ancestor rows using `mju_addToScl` and scales
each completed row using `mju_scl`. Their normal AVX implementations operate on
four doubles with scalar tails. The reviewed files, pinned reference metadata,
frozen Ada sources and actual recipes are in `row-reductions.zip`.

1. **Short-row widened source index, r468–r471.** Only the Count<16 index
   expression is widened to Int64 before arithmetic, as already done in the
   long helper. Final conversion/access checks, domain, ordered rounded formula,
   rejection and frame contracts remain. The minimum closes 39 checks; the
   whole unit closes 155 (138 proof/17 flow), with six inherited diagnostics.
   Ball time increases 2.60–2.90% across the two sessions; all its intervals
   exclude no change. Chain24 has no repeatable demonstrated improvement.

2. **Direct Add_Row/Scale_Row expressions, r472–r474.** The exact expressions
   replace intermediate constrained function results; functional specifications
   and final Work_Real rejection remain. Minima close 31/19 checks; the complete
   unit closes 156 (139 proof/17 flow), with six diagnostics. Static caller
   disassembly falls from 1,856 to 1,824 instructions and 135 to 129 floating
   compare sites. Nevertheless fixed-tendon time increases 4.69–5.00% and
   spatial-tendon time 4.24–4.50%, with repeatable intervals excluding no change.
   Chain24 gains are small and some intervals include no change. Not adopted.

3. **Existing integer-bit helper in both generic rows, r476–r478.** This replaces
   checked Int64 rejection counts while retaining the original constrained
   arithmetic expressions. The helper moves before its additional uses. Minima
   close 31/19 checks; the whole unit closes 156 (139 proof/17 flow), with four
   remaining diagnostics. Its caller grows to 2,422 static instructions and
   223 floating compare sites, with four rather than three zmm arithmetic sites.
   Ball increases 3.93–4.26%; free increases 1.83–2.02%. Chain24 intervals include
   no change throughout. Not adopted. These static counts are diagnostic, not
   dynamic cycle counts or proof of the cause of any measured regression.

The archived initial `instructions` fields also counted disassembly byte
continuation lines. `assembly-correction.json` supersedes those labels using
`objdump --insn-width=16` and independent ELF symbol sizes. The baseline caller
occupies 8,873 bytes; the widened, direct-expression and bit-rejection variants
occupy 9,081, 8,759 and 11,496 bytes respectively. The original ZIP, executable
hashes, proofs and timing records are preserved verbatim.

Every changed subprogram is proved before the full unit. Minima are warning-free;
whole-unit obligations are closed but strict warning-free `passed` is false.
The remaining warning expressions are bridged to identical baseline expressions.
No assumption, suppressed check, new trusted production body, stronger public
precondition, changed FP association or deallocator change is introduced.
These proofs cover ordered floating-point values, bounds, rejection and frames
under the existing contracts, not full factorization or physical accuracy.

The initial r470 coordinator stopped on whole-unit strict `passed=false` despite
closed obligations; r471 explicitly checks the closed obligations and preserves
all six warnings. No proof is rerun or relabeled warning-free. The first r468
preparation compared the production 3.14 files to the frozen 3.17 ABI and stopped;
the corrected foundation-aware snapshot exactly matches r453 before the edit.

## Numerical and timing scope

Each variant passes all 14,905 disjoint-row cases in both ordinary validation
and release. Each has two complete movement sessions: ten models, three states,
24 balanced blocks, eight samples, 32 warmups, 100 evolving Euler steps, CPU12.
Baseline/current Ada endpoints are exactly equal and C agreement retains
atol/rtol 2e-10. No own heavy task overlaps timing. All frozen source, executable
and C-library hashes are checked. Setup, reset and I/O stay outside timing.

Both Ada variants use native O3, LTO, FP contraction off and the existing release
256-bit per-file preference. The reference is the existing pinned source-built
C3.17 normal AVX/LTO library with known GCC16 flags; the independent official
wheel supplies the numerical oracle. r478 reuses the freshly compiled r474
baseline ELF byte-for-byte; its checksum also matches r470 and historical r455.
All actual build metadata, raw endpoint outputs, per-block timings, medians,
MAD, trajectory-mean p95 and within-session bootstrap intervals are archived.
No unweighted aggregate, noise allowance or full C-parity claim is made.

The prepared C3.17/C3.14 full promotion recipes r475/r479 are **unexecuted**:
the integrated regressions reject these private variants first. Numerical
endpoint/corpus success does not imply performance acceptance. Contacts,
constraints, sensors, rendering and general MuJoCo feature coverage are outside
these movement measurements.

## Retained generic-row corpus, r481–r483

The old 14,905-case probe tests Add_Row_Disjoint. It does not directly exercise
Add_Row or Scale_Row. The new `generic_rows_probe.adb` tests those operations
with 137,754 cases per profile: lengths 0–256, every rejected entry and both
signs, numeric subtype limits, complete SIMD blocks, scalar tails, signed zero,
different nonzero origins and Natural'Last. Every output component is compared
bit-for-bit with the ordered scalar expression; rejection uses a separate
early-exit oracle. Unchecked_Conversion transports test bits only and is not a
production body or premise of the formal proofs.

The retained baseline and all three private variants pass in both validation
and release. The first corpus build r481 failed before execution because a
Smooth_Math import was missing; r482 corrects the import without changing the
cases. Both attempts and the final provider hashes are archived.
The final public driver removes an unused vector-width override inherited from
the older harness. A mechanical bridge verifies that this is the only change;
the actual default flag lists and Ada corpus are identical. The full final
baseline rerun passes both profiles; `final-driver-validation.json` records it.

Run from the repository root with a prepared supported snapshot:

```sh
python3 experimental/dynamics-derivatives-candidate/tests/check_generic_rows.py \
  --build FROZEN_SNAPSHOT --out NEW_OUTPUT
```

The test driver retains the normal validation and release flags and freezes its
probe. This is compiler/runtime regression coverage, separate from universal
language proofs, C equivalence and movement performance.

The archive excludes generated compiler/prover caches. It retains copied raw
SPARK reports, logs, source closures, binaries, test fixtures and actual recipes.
Its compressed payloads are stored using the exact evidence store; use
`python3 tools/evidence_store.py restore` if the original ZIP is absent.
