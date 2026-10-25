# Local slice-view experiment r334 — 25 October 2026

This experiment is not adopted. It creates two checked, noncopying slice views
of the disjoint source/target ranges and uses the integer-bit rejection helper.
It keeps the original public precondition, rounded formula, rejection predicate
and full-frame contract. There are no suppressed checks or unsafe FP flags.

The r330 minimum leaves two obligations open: floating addition safety and
preservation of the rejection-prefix invariant. Adding explicit input/source and
remaining-target bounds in r332 closes the addition check, but leaves source
bound preservation and the rejection-prefix invariant open. These are unfinished
proof engineering, not mathematical research exceptions. A proved check that
relies on an unproved invariant is not a complete safety proof. No whole-unit or
Gold claim is made for either slice-view version.

The final r332 variant passes all 14,905 strict row cases in validation/release.
Two separate full-movement sessions each cover ten models/three states, 24
balanced blocks, four samples, 100 evolving steps and two warmup trajectories,
CPU 12. Every candidate endpoint is exactly equal to baseline Ada and agrees
with C at the unchanged atol/rtol 2e-10. Setup/reset/I/O stay outside timing.
Strict flags match across Ada builds; no gnatp or unsafe FP is present. Numerical
experiments are recorded despite the open proofs; they do not close them.

Some small models improve about 4–8%, but the 24-DOF chain loses the roughly9%
gain of the direct bit variant and has a repeatably slower state. Branches also
have repeatable regressions. Release assembly has no additional vector arithmetic
or bit instructions in the updated loop; the update remains scalar. Source-level
views therefore did not produce the intended SIMD gain. All per-scenario medians,
MAD, trajectory-mean p95 and paired within-session bootstrap intervals are kept;
no unweighted average or arbitrary noise threshold is used. Normal C3.17 wheel
compiler flags remain unknown, so this is not matched-build parity acceptance.
The exact assembly and raw sessions determine the conclusion, not intent.

The working tree retains the separately proved r326 bit-row candidate and its
reported tendon regressions. Full C3.17/C3.14 gates for that candidate live in the
r329 checkpoint; no integration gate is borrowed for these slice-view variants.
Full-port completion, current-release migration and C performance parity remain
open. All work is local, with no commits or pushes.

The ZIP contains both frozen view closures, failed minimum reports and actual
runners, the strict corpus, paired builds, all raw trajectories, assembly and the
measurement recipe. Compiler/prover object/task caches, external toolchains and
the external C shared library are omitted; manifests and hashes remain. Every
member is hashed and reread, with earlier inventory entries preserved.
