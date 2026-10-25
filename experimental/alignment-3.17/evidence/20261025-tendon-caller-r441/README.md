# Tendon caller composition r441 — 25 October 2026

Local only; no commits, staging or pushes. This checkpoint changes proof context,
not the runtime formulas, contracts, accepted input domain or runtime checks.
Release LTO and the retained solver remain as measured at r430.

The actual Assemble_Compact_Path minimum now proves the complete precondition
of Compact_Tendon_Mass.Accumulate, including the captured plan's index/mirror
relations after compact construction. It closes 21 checks, with two obligations
still open: the overall producer postcondition and readiness before compact
publication. Twelve inherited diagnostics remain separate; coverage is complete,
obligations_closed=false and strict passed=false for this caller scope. The
unchanged Solve postcondition remains open, giving three outstanding obligations
in the examined caller scopes, down from four. Broader Data/dynamics/physical
binding and factorization proofs are not included in that count.

The retained change hides only the Mass_Ready expression body at this caller.
The independently proved Expose_Compact_Layout lemma supplies its exact predicate,
and the existing fully specified/verified tendon accumulator contract remains
available. Hiding a definition removes unfolding information; no assumption,
skip, suppression or trusted implementation body is introduced. The proof uses
the same 3-second/650-MiB per-check limits, 2500-MiB group cap, j1, no inlining
and a bounded aggregate run. Deallocator implementations and warnings are unchanged.

Making Ready opaque as well did not improve the result and is not retained.
A private variant split Storage_Ready, Configuration_Bounded and
Configuration_Valid into assertions; all remained unfinished under the existing
limits. Its assertions are not in the working tree. A separate private variant
hid the recursive tendon Model expression, also with no additional closure;
it too is not adopted. All variants and reports are retained, without treating
proved minima under unproved callers as a complete dynamics proof.

The corrected source audit compares the two C3.17 frozen closures and separately
checks live owned experimental Ada. The only changed Ada file is
mj-data-inertia_phase.adb; its program/contract token stream is unchanged after
removing comments and GNATprove Hide_Info annotations. This is a lexical control,
not a claim of identical compiler binary bytes or a new whole-program proof.
The initial audit mistakenly compared working production C3.14 core src with the
candidate C3.17 foundation; it stopped and its scope correction is recorded.
No core ABI difference is being hidden. The live retained file is byte-identical
to the successful tendon-call proof snapshot.

No new runtime traversal or measured speedup follows from this annotation.
The r430 ordinary/LTO numerical, boundary, cache/Euler and paired performance
results remain their explicitly versioned evidence; they are not relabeled as
fresh runs here. Full MuJoCo coverage, coordinated C3.17 migration, functional
composition and C performance parity remain unfinished.

The archive preserves frozen sources, rejected private diagnostics, exact proof
reports/commands and the source audit. All members are hashed and reread, and
all 97 previous evidence-file hashes are preserved.
