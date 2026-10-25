# Row dispatch threshold experiment r450 — 25 October 2026

The eight-value threshold is not adopted. The working kernel stays at 16,
with release LTO as retained at r430 and the proved tendon context from r441.
No commits, staging or pushes.

The inspected official C3.17 mju_addToScl delegates to normal AVX groups of four.
The retained Ada long helper emits wider groups and is kept separate from the
short scalar caller. A private copy changes only the dispatch condition from
Count>=16 to Count>=8; exact arithmetic order, rejection/frame contracts, valid
input domains, native O3/LTO and FP contraction off are unchanged. This tests
whether the existing helper helps the 8–15 prefix lengths; it does not introduce
an intrinsic, assumption, suppressed check or new trusted body.

The Add_Row_Disjoint minimum closes 40 checks without warnings. The complete
Solver_Kernels unit closes 156 (139 proof, 17 flow) with six recorded diagnostics;
obligations_closed=true and strict passed=false. Its rounded value, rejection
and complete frame behavior are proved under the existing preconditions. All
14,905 row boundary cases pass in both ordinary validation and release LTO,
including each rejected SIMD lane, extreme valid origins and untouched regions.
These scopes are not added to each other or treated as a full LDL/dynamics proof.

Two complete integrated sessions each cover 30 scenarios, 24 balanced blocks,
eight trajectories, 32 warmups and 100 evolving steps per trajectory on CPU12.
Ada baseline/current endpoints are exactly equal; C agreement retains 2e-10
atol/rtol. Setup/reset/I/O are outside timing, no own heavy job overlaps it,
and every source/binary/library hash remains unchanged. The comparator is the
pinned source-built C3.17 GCC16/normal AVX/LTO library from r430; its flags and
independent wheel numerical oracle remain identified in the build receipts.

The earlier SIMD dispatch increases chain24 time by 3.20–4.10% and branches24
by 2.60–4.28%; the per-state within-session intervals exclude no change for
those multi-DOF cases in both sessions. Ball also regresses about 1.8–2.2%.
Hinge/free central values improve modestly, and free+ball intervals vary; all
per-model results are retained. No unweighted faster/slower count or mean of
percentages is used. No compensation or C parity is inferred. The dispatch
change worsens the target integrated workloads despite successful proofs and
numeric boundary tests, so full two-reference numerical promotion gates are not
run for this rejected variant. The already verified working implementation is
not replaced.

These data do not isolate vector setup, call overhead, frequency effects or
compiler layout as a unique cause. In particular, the short-model timings can
change while their helper lengths remain below eight. Static assembly and a
separate width experiment are appropriate next diagnostics; no speculative
cause is presented as measured attribution.

All source copies, scoped/whole reports, exact commands, boundary outputs,
reference metadata and raw timing/state samples are preserved. Compiler and
prover task caches and external toolchains are excluded. All members are hashed
and reread, and all 102 previous evidence-file hashes are preserved. Whole-port
coverage, coordinated C3.17 migration, outstanding functional proofs and C
performance parity remain unfinished.
