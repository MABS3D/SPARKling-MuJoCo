# Local four-value row experiment r365 — 25 October 2026

No commits or pushes. The active kernel is restored byte-for-byte to retained
r349; its prior C3.17/C3.14 gates and 156-check unit evidence remain in r353.
This experiment is not promoted.

## Structure and proof scope

C3.17 mju_addToScl_avx explicitly updates four doubles then a scalar tail. This
prototype uses a fixed four-value Ada subtype and four independent ordered
multiply/add expressions. Two checked slices provide value copies to avoid
aliased writable/read-only formals; actual release assembly has two vector
arithmetic instructions in the compact long helper and no memcpy/memmove calls
there. All language checks remain enabled, with no unsafe FP, assumption, skipped
body, trusted foreign implementation or stronger public input restriction.

The arithmetic helper Add_Four closes 17 checks. The pure ghost equivalence between
a four-value rejection flag and its buffer slice closes 8; Add_Block_Four closes 39
checks, including exact rounded values, rejection and the complete untouched
frame. These minima are warning-free and separately scoped, not a whole-row proof.
Earlier helper attempts left two then one obligations open; expressing the same
slice domain and separating the pure rejection lemma closes those obligations.

The complete blocked row is unfinished proof engineering. Its first for-loop
version proves 79 checks but leaves four invariant obligations open. The while
version initially has a misplaced Loop_Variant/Loop_Invariant grouping rejected
by the compiler; corrected grouping still leaves five invariants open. A targeted
repeat of the original for-loop minimum uses 10 seconds/1000 MiB per prover,
one worker, 2500 MiB/600 seconds aggregate. Its final status is recorded below
and in the complete raw report. No timeout is presented as a mathematical
research exception, no open check is suppressed, and no whole-row or workspace
Gold claim is made.

Targeted repeat: obligations_closed=False; remaining open entries=4.

## Numerical/performance evidence

The threshold-four prototype passes all 14,905 row cases in validation and strict
release. Two full sessions each measure ten models/three states, 24 balanced
blocks, four samples,100 evolving steps and two warmup trajectories. Every Ada
endpoint equals retained baseline values; C agrees at the existing atol/rtol 2e-10.
Setup/reset/I/O are outside timing. The prototype improves several small cases
but repeatedly slows the 24-DOF chain about3–4%, so those gains do not establish a
general improvement. The row composition proof remains open independently.

A threshold-sixteen prototype changes only the dispatch constant. The copied
cache is private; its log confirms both the kernel and inlined caller rebuild.
Assembly of the actual solver differs from threshold-four only in that compare
immediate, and fresh/reused retained baseline ELFs have identical SHA256. Two
full sessions show substantially different ratios even on cases not executing
the new long helper; causal attribution from those ratios alone is insufficient.
Exact timing/interval records and binary/source audit remain available.

The benchmark runner now supports explicit --warmups and a diagnostic --models
subset. Defaults remain unchanged. All fixture RNG draws are retained before
filtering, and all 12 diagnostic inputs are byte-identical to full-suite inputs.
Two further control sessions use 12 balanced blocks, 32 samples, 32 warmups and
four models/three states. They still show a roughly 1–3% chain regression rather
than a stable benefit; branches include parity in their intervals. Hinge and ball
ratios vary from the short-run sessions. No arbitrary noise threshold, unweighted
model average or selected best session is used as acceptance evidence.

CPU affinity is 12 inside WSL2. CPU frequency controls are not exposed in the guest;
this fact is recorded, not asserted as the measured cause. Bootstrap intervals
are within-session and do not cover every between-session environment change.
Actual assembly and input identity checks complement the statistics.

The normal C3.17 wheel remains SIMD-enabled, with unknown library compiler flags;
none of these records establishes final matched-build C parity. These are smooth
Euler trajectories excluding contacts/constraints, sensors, rendering and activation
state models. No full C3.14/C3.17 integration gate is borrowed for this unadopted
prototype. Full port/current-release alignment, global functional dynamics and
performance parity remain open.

## Artifacts

The ZIP preserves all source attempts,actual helper/row proof drivers and reports,
strict corpus, full and control sessions, raw timings/trajectories,assembly/binary
checks, hardware record and the exact cache-copy build recipe. Compiler/prover
object/task caches,external toolchains and external C shared library are omitted;
hashes, pins, flags and commands remain. Every member is hashed and reread and all
earlier inventory entries are preserved. The previous live kernel and reviewed
deallocators/warnings are unchanged. New benchmark diagnostic controls are the
only retained executable changes from this experiment.
