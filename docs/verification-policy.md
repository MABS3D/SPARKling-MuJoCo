# Verification policy: Gold wherever possible

Project direction agreed on 2026-09-23: maximize proved functional properties
(SPARK Gold) throughout the port. Silver is the safety baseline, not the default
completion target. Retain Silver-only coverage for a property only when a
documented mathematical or research limitation prevents a sound stronger claim.

The [SPARK assurance levels](https://docs.adacore.com/spark2014-docs/html/ug/en/usage_scenarios.html)
distinguish Silver (absence of runtime errors), Gold (key integrity/functional
properties), and Platinum (full functional correctness against a specification).
These are scopes of assurance, not prover effort settings or certifications.

## What to prove

For each kernel, specify and prove useful output behavior as well as bounds,
initialization, indexing safety, and termination. A passing safety proof or a
postcondition that only restates a result subtype is not sufficient evidence of
the intended operation. Keep preconditions meaningful for callers; do not exclude
required inputs merely to make the proof pass.

Separate three claims:

1. Runtime safety under explicit preconditions.
2. Functional behavior of the floating-point algorithm, including evaluation
   order, branches, fallback values, and preservation of unaffected data.
3. Accuracy relative to real arithmetic, stability, and physical properties.

A limitation in the third claim must not prevent proving the second. Floating
point alone is not a reason to stop at Silver. Many rounding-error bounds are
established mathematics, not open research; use them when their assumptions
match the actual implementation. Do not claim exact real identities for rounded
operations, or treat C differential tests as universal equivalence proofs.

## Immediate vector priorities

- Zero, fill, copy, equality, component-wise arithmetic, scaled additions, and
  in-place updates: prove exact component relations and bounds/frame properties.
- Cross3 and fixed-size dot products: prove the specified floating-point
  expression with its evaluation order.
- Sum and L1: add a functional model of the ordered floating-point accumulation
  and prove the loop implements it, beyond just range and empty-array behavior.
- Generic Dot: model the actual four-lane accumulation, lane combination, and
  remainder; a mathematical real dot product is not an interchangeable model.
- Norms and distances: prove composition with the specified squared reduction
  and runtime square root, documenting the runtime contract boundary. This alone
  does not prove a bound on error against the ideal Euclidean norm.
- Normalization: prove the returned original length, tiny-norm fallback,
  component scaling, and the near-unit no-op branch of Normalize4. Pursue a
  justified approximate-unit-norm bound separately; do not assert exact unit
  length for floating-point output.

These are implementation/proof objectives. Newly written contracts are not
verified results until their obligations pass. In particular, the vector work
in progress must not inherit the older foundation snapshot's verification claim.

## Performance against the C reference

**Current priority (updated by the user on 2026-09-24):** assess performance
parity on representative integrated movement workloads before expanding scope.
Preserve Gold while optimizing and use the normal C SIMD implementation as the
reference. This supersedes the earlier requirement that no individual kernel
slowdown could be compensated by gains elsewhere.

The acceptance metric is measured total time for an equivalent supported
movement workload, with correctness checked separately. Microbenchmarks remain
diagnostic: retain reproducible regressions and their uncertainty, but do not
use an unweighted count of faster/slower cases or an average of their percentage
changes as an integrated performance result. A local regression may be accepted
when representative integrated measurements establish parity or improvement;
report workload-specific regressions rather than hiding them in a global mean.
Missing integrated measurements leave aggregate performance pending.

Measure baseline Ada, current Ada and the corresponding C workload, including
real call frequencies, data dependencies and memory traffic. Distinguish a
kinematic update from a complete dynamics/integration step. Report time per step
and trajectory, dispersion and tail timings across documented models and sizes.
The experimental smooth pipeline uses its own math routines. Identify any
experimental bridge explicitly: its performance cannot establish the benefit of
other kernel changes unless those kernels are actually on the measured call
path. Its supported scope and
pending proofs/alignment must remain explicit; it is not full MuJoCo.

Use representative sizes and branches on the supported target hardware, with
comparable release optimizations and floating-point semantics. Include the C
reference's normal SIMD paths. Keep input preparation and I/O outside the timed
region, prevent dead-code elimination, repeat measurements in alternating order,
and report dispersion as well as central timings. Record compiler versions,
flags, hardware, source hashes and the reference version. Judge parity against
measurement uncertainty, not an arbitrary allowance for slower code.

Repeat the comparison after implementation or build changes that can affect
performance, and measure the integrated component as it becomes available.
Performance measurements are distinct from numerical differential tests and
formal proofs; all remain required. Preserve the specified floating-point
evaluation order and proved contracts when optimizing. This policy is an
acceptance requirement, not evidence that existing components already meet it.

## Proof evidence and exceptions

Record the functional property, its assumptions, and its proof status per
subprogram. For any remaining Silver-only property, describe the missing
mathematical result or model, the strongest property already proved, and the
work required to close the gap. A solver timeout, an inconvenient invariant,
or a missing ghost model is unfinished proof engineering, not a research-based
exception. Such work may remain explicitly pending, but must not be presented
as completion of the Gold objective.

Do not replace a proof with an assumption, suppression, or new trusted body to
claim Gold. Keep existing reviewed warnings and modeled deallocators unchanged
as previously agreed. Start diagnosis at the smallest subprogram; use complete
unit proofs and fresh evidence for integration. Clearly distinguish safety,
functional, numerical-accuracy, and differential-test evidence in reports.
