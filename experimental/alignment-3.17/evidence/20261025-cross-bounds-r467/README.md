# Local Cross bound diagnostics r467

Neither private Cross variant is adopted. Working experimental Ada sources remain byte-identical to r455; release LTO, the Solver_Kernels256-bit preference and threshold16 remain. No commits, staging, pushes or remote writes; HEAD is `398c2dde5299ec46cfb00bffd91e7660a852907a`.

## Current-build diagnostic profile

The actual r455 source/build is instrumented with gprof, preserving LTO and per-file vector width. Each of chain24, branches24 and free_ball runs12,000 samples of100 steps. Exact uninstrumented Ada outputs and the independent C oracle pass. Solve_Compatible_Buffers receives28.33%,17.78%,28.65% of sampled main-image self time respectively. Chain24 Cross receives10.19% and is called360,060,000 times across the process (including warmups/setup); about300 calls per simulated step.

These are instrumented full-process samples, not release timing, C phase costs, or a fraction of the Ada/C slowdown. Setup/reset/output are included, shared-library histogram time is excluded, and inlining attributes work to containing symbols. No other heavy job overlapped movement timing.

## Exact bound transformation and proof

Old Cross uses six Product subtype checks at±2e300, producing six runtime range-failure sites and12 comparisons in actual release disassembly. Under its unchanged public operand bound±1e150 these intermediate bounds are redundant. The private r457 body keeps all six rounded products and three ordered differences, replaces the six subtype restrictions by six explicit Static assertions, and preserves every public precondition/postcondition and stronger conditional bound. No suppression, assumption, new trusted implementation, input narrowing, changed deallocator or floating-point reassociation is introduced.

The minimum closes86 checks (84 proof,2 flow), with10 diagnostics recorded separately. The complete Smooth_Math unit closes796 (738 proof,58 flow), with66 diagnostics (43 operator-reassociation,10 Sqrt,7 Sin,6 Cos imprecise-call). These diagnostics make strict passed=false even though obligations_closed=true, coverage=all, no open checks, and no skips/assumptions are reported. Exact Cross arithmetic is proved under its contracts; this does not prove the full simulation, physical binding, or real-arithmetic accuracy of elementary functions. The full source and raw .spark/log receipts are retained.

The test-only bit-transport probe checks5,972 cases/17,916 components per validation/release profile against the pinned source-built C3.17 with FP contraction off. Coverage includes positive/negative zero, normal/subnormal exponents, maximum admitted operands, conditional-bound scales and cancellation. All bits agree. Ada.Unchecked_Conversion only transports bits in this non-SPARK test harness; production/proof code has no dependency on it.

The first bit-test startup (r460) failed before running cases: the process had the system libstdc++ without GLIBCXX_3.4.35. The r466 bootstrap verifies and prepends the pinned GCC16 runtime before starting Python/NumPy. Corpus and comparisons are unchanged. The failed tree, original recipe, corrected recipe and runtime receipt are retained.

## Performance decisions

The first variant removes the checks and permits automatic LTO inlining. Static named Cross call sites drop33→0; the named body disappears. Two complete30-scenario sessions show chain24 gains around7.4–8.5%, but fixed-tendon regressions6.5–7.0%, with95% intervals excluding1. This prevents adoption of that variant. No causal claim attributes the entire regression solely to inlining: layout and other compiler decisions also change.

The second variant adds only pragma No_Inline(Cross) to the private logical body. The recorded byte comparison establishes identity after removing that directive. It retains33 named call sites, zero Cross range-failure sites and zero comparisons. Fixed tendons improve around2–3%, but chain24 is1.6–3.2% slower in the first session (two intervals exclude1) and inconclusive in the second; branches24 is inconclusive. It does not establish a satisfactory multi-DOF improvement and is not adopted. The old full proof is explicitly for r457 without this compiler directive; no final-source whole-unit proof or promotion claim is made for r462.

Each performance session uses24 balanced blocks,8 samples,32 warmups,100 steps,CPU12, identical checked Ada endpoints and independent C oracle tolerance2e-10. C is the unchanged pinned source-built normal AVX/LTO reference with known GCC16 flags. Each session stores raw timings, dispersion/tails and95% intervals. Results of different models are not averaged or counted to claim compensation or parity.

Full two-reference promotion gates were prepared in r461 but not executed: the performance decision rejected both candidates first. That recipe is retained as unexecuted preparation, not evidence. Working source remains r455. Three examined caller obligations and wider port/migration/dynamics/physical binding proofs and C parity remain open.

## Raw paired results

| Variant/session | Model/state | Current/baseline (95% CI) | Current/C (95% CI) |
|---|---|---|---|
| automatic-inline-1 | hinge_motor/0 | 0.9421 (0.9381–0.9457) | 1.0512 (1.0440–1.0541) |
| automatic-inline-1 | hinge_motor/1 | 0.9459 (0.9418–0.9493) | 1.0504 (1.0164–1.0584) |
| automatic-inline-1 | hinge_motor/2 | 0.9432 (0.9408–0.9452) | 1.0543 (1.0503–1.0570) |
| automatic-inline-1 | affine_chain/0 | 0.9891 (0.9854–0.9927) | 1.1866 (1.1768–1.1947) |
| automatic-inline-1 | affine_chain/1 | 0.9887 (0.9790–0.9948) | 1.1860 (1.1786–1.1951) |
| automatic-inline-1 | affine_chain/2 | 0.9881 (0.9849–0.9900) | 1.1802 (1.1581–1.1885) |
| automatic-inline-1 | branched/0 | 0.9933 (0.9787–1.0223) | 1.1798 (1.1481–1.2166) |
| automatic-inline-1 | branched/1 | 0.9897 (0.9683–0.9991) | 1.1656 (1.1407–1.1850) |
| automatic-inline-1 | branched/2 | 0.9884 (0.9832–0.9921) | 1.1631 (1.1514–1.1776) |
| automatic-inline-1 | ball/0 | 0.9232 (0.9205–0.9349) | 1.2324 (1.2008–1.2516) |
| automatic-inline-1 | ball/1 | 0.9226 (0.9182–0.9342) | 1.2360 (1.2059–1.2550) |
| automatic-inline-1 | ball/2 | 0.9276 (0.9203–0.9462) | 1.2418 (1.2311–1.2663) |
| automatic-inline-1 | free/0 | 0.9182 (0.9167–0.9355) | 1.2731 (1.2669–1.2962) |
| automatic-inline-1 | free/1 | 0.9178 (0.9136–0.9365) | 1.2621 (1.2314–1.2857) |
| automatic-inline-1 | free/2 | 0.8836 (0.7994–0.9815) | 1.2795 (1.2043–1.4319) |
| automatic-inline-1 | free_ball/0 | 0.9163 (0.8215–1.0928) | 1.7094 (1.5772–2.0244) |
| automatic-inline-1 | free_ball/1 | 0.9228 (0.8237–1.0068) | 1.5601 (1.3172–1.7231) |
| automatic-inline-1 | free_ball/2 | 0.9580 (0.9052–1.0126) | 1.6994 (1.6494–1.7801) |
| automatic-inline-1 | fixed_tendon/0 | 1.0645 (1.0507–1.0721) | 1.3337 (1.3029–1.3415) |
| automatic-inline-1 | fixed_tendon/1 | 1.0692 (1.0645–1.0745) | 1.3362 (1.3274–1.3447) |
| automatic-inline-1 | fixed_tendon/2 | 1.0672 (1.0616–1.0692) | 1.3331 (1.3294–1.3367) |
| automatic-inline-1 | spatial_ball/0 | 0.9532 (0.9516–0.9551) | 1.5278 (1.5159–1.5335) |
| automatic-inline-1 | spatial_ball/1 | 0.9531 (0.9517–0.9550) | 1.5099 (1.4925–1.5277) |
| automatic-inline-1 | spatial_ball/2 | 0.9530 (0.9518–0.9543) | 1.5228 (1.4942–1.5285) |
| automatic-inline-1 | chain_24/0 | 0.9257 (0.9198–0.9426) | 2.1617 (2.1464–2.2118) |
| automatic-inline-1 | chain_24/1 | 0.9196 (0.9038–0.9273) | 2.1703 (2.1368–2.1807) |
| automatic-inline-1 | chain_24/2 | 0.9227 (0.9166–0.9291) | 2.1628 (2.1479–2.1815) |
| automatic-inline-1 | branches_24/0 | 0.9484 (0.9336–0.9556) | 1.5841 (1.5605–1.5967) |
| automatic-inline-1 | branches_24/1 | 0.9788 (0.9489–1.1009) | 1.5280 (1.4570–1.7229) |
| automatic-inline-1 | branches_24/2 | 0.9531 (0.9431–0.9855) | 1.6084 (1.5916–1.6527) |
| automatic-inline-2 | hinge_motor/0 | 0.9454 (0.9421–0.9495) | 1.0541 (1.0505–1.0590) |
| automatic-inline-2 | hinge_motor/1 | 0.9421 (0.9389–0.9454) | 1.0527 (1.0482–1.0573) |
| automatic-inline-2 | hinge_motor/2 | 0.9433 (0.9399–0.9475) | 1.0555 (1.0513–1.0589) |
| automatic-inline-2 | affine_chain/0 | 0.9882 (0.9806–0.9993) | 1.1694 (1.1294–1.1958) |
| automatic-inline-2 | affine_chain/1 | 0.9886 (0.9839–1.0193) | 1.1799 (1.1341–1.1982) |
| automatic-inline-2 | affine_chain/2 | 1.0005 (0.9869–1.0515) | 1.2009 (1.1344–1.2485) |
| automatic-inline-2 | branched/0 | 0.9863 (0.9390–0.9898) | 1.1706 (1.1459–1.1747) |
| automatic-inline-2 | branched/1 | 0.9886 (0.9869–0.9914) | 1.1370 (1.0802–1.1738) |
| automatic-inline-2 | branched/2 | 0.9895 (0.9861–0.9933) | 1.1579 (1.1319–1.1759) |
| automatic-inline-2 | ball/0 | 0.9220 (0.9169–0.9239) | 1.2347 (1.2090–1.2411) |
| automatic-inline-2 | ball/1 | 0.9215 (0.9198–0.9242) | 1.2304 (1.2133–1.2409) |
| automatic-inline-2 | ball/2 | 0.9219 (0.9187–0.9270) | 1.2258 (1.1977–1.2378) |
| automatic-inline-2 | free/0 | 0.9177 (0.9072–0.9211) | 1.2711 (1.2655–1.2759) |
| automatic-inline-2 | free/1 | 0.9197 (0.9183–0.9209) | 1.2685 (1.2583–1.2734) |
| automatic-inline-2 | free/2 | 0.9203 (0.9185–0.9218) | 1.2709 (1.2619–1.2821) |
| automatic-inline-2 | free_ball/0 | 0.9519 (0.9084–0.9817) | 1.7006 (1.6510–1.7506) |
| automatic-inline-2 | free_ball/1 | 0.9609 (0.9385–0.9870) | 1.6916 (1.6702–1.7347) |
| automatic-inline-2 | free_ball/2 | 0.9499 (0.9299–0.9747) | 1.6507 (1.6353–1.7063) |
| automatic-inline-2 | fixed_tendon/0 | 1.0685 (1.0416–1.0710) | 1.3224 (1.3037–1.3374) |
| automatic-inline-2 | fixed_tendon/1 | 1.0683 (1.0654–1.0704) | 1.3310 (1.3063–1.3377) |
| automatic-inline-2 | fixed_tendon/2 | 1.0700 (1.0528–1.0725) | 1.3333 (1.3088–1.3387) |
| automatic-inline-2 | spatial_ball/0 | 0.9529 (0.9271–0.9543) | 1.5205 (1.4950–1.5259) |
| automatic-inline-2 | spatial_ball/1 | 0.9530 (0.9515–0.9541) | 1.5111 (1.4892–1.5274) |
| automatic-inline-2 | spatial_ball/2 | 0.9530 (0.9511–0.9548) | 1.5215 (1.5045–1.5314) |
| automatic-inline-2 | chain_24/0 | 0.9159 (0.9083–0.9244) | 2.1643 (2.1423–2.1843) |
| automatic-inline-2 | chain_24/1 | 0.9220 (0.9147–0.9472) | 2.1575 (2.1213–2.2088) |
| automatic-inline-2 | chain_24/2 | 0.9152 (0.9081–0.9266) | 2.1512 (2.1182–2.1798) |
| automatic-inline-2 | branches_24/0 | 0.9381 (0.8977–0.9535) | 1.5654 (1.5122–1.5920) |
| automatic-inline-2 | branches_24/1 | 0.9490 (0.9297–0.9555) | 1.5930 (1.5690–1.6098) |
| automatic-inline-2 | branches_24/2 | 0.9617 (0.9508–0.9711) | 1.5920 (1.5690–1.6185) |
| no-inline-1 | hinge_motor/0 | 0.9725 (0.9688–0.9745) | 1.1403 (1.1018–1.1473) |
| no-inline-1 | hinge_motor/1 | 0.9744 (0.9700–0.9764) | 1.1391 (1.1264–1.1434) |
| no-inline-1 | hinge_motor/2 | 0.9717 (0.9684–0.9736) | 1.1411 (1.1193–1.1454) |
| no-inline-1 | affine_chain/0 | 0.9813 (0.9725–0.9847) | 1.2516 (1.2485–1.2567) |
| no-inline-1 | affine_chain/1 | 0.9892 (0.9814–0.9932) | 1.2574 (1.2477–1.2647) |
| no-inline-1 | affine_chain/2 | 0.9867 (0.9750–0.9942) | 1.2564 (1.2382–1.2686) |
| no-inline-1 | branched/0 | 0.9773 (0.9715–0.9874) | 1.1844 (1.1681–1.1955) |
| no-inline-1 | branched/1 | 0.9820 (0.9605–0.9966) | 1.1857 (1.1603–1.2064) |
| no-inline-1 | branched/2 | 0.9760 (0.9739–0.9780) | 1.1683 (1.1635–1.1877) |
| no-inline-1 | ball/0 | 1.0003 (0.9973–1.0026) | 1.2570 (1.2459–1.2811) |
| no-inline-1 | ball/1 | 1.0013 (0.9975–1.0041) | 1.2649 (1.2423–1.2824) |
| no-inline-1 | ball/2 | 0.9984 (0.9872–1.0035) | 1.2816 (1.2764–1.2887) |
| no-inline-1 | free/0 | 0.9802 (0.9612–0.9822) | 1.2921 (1.2679–1.3021) |
| no-inline-1 | free/1 | 0.9835 (0.9814–0.9857) | 1.2987 (1.2710–1.3091) |
| no-inline-1 | free/2 | 0.9843 (0.9809–0.9856) | 1.3076 (1.2679–1.3103) |
| no-inline-1 | free_ball/0 | 0.9952 (0.9571–1.0139) | 1.8152 (1.7244–1.8382) |
| no-inline-1 | free_ball/1 | 0.9863 (0.9670–1.0111) | 1.7672 (1.7085–1.7874) |
| no-inline-1 | free_ball/2 | 0.9785 (0.9523–1.0106) | 1.7129 (1.6551–1.7877) |
| no-inline-1 | fixed_tendon/0 | 0.9745 (0.9673–0.9901) | 1.2459 (1.2177–1.2699) |
| no-inline-1 | fixed_tendon/1 | 0.9790 (0.9691–0.9904) | 1.2542 (1.2228–1.2689) |
| no-inline-1 | fixed_tendon/2 | 0.9752 (0.9685–0.9887) | 1.2484 (1.2423–1.2657) |
| no-inline-1 | spatial_ball/0 | 0.9583 (0.9569–0.9591) | 1.5254 (1.5107–1.5401) |
| no-inline-1 | spatial_ball/1 | 0.9566 (0.9510–0.9580) | 1.5160 (1.5000–1.5331) |
| no-inline-1 | spatial_ball/2 | 0.9574 (0.9557–0.9584) | 1.5321 (1.5301–1.5386) |
| no-inline-1 | chain_24/0 | 1.0160 (1.0066–1.0319) | 2.3910 (2.3563–2.4085) |
| no-inline-1 | chain_24/1 | 1.0167 (0.9991–1.0234) | 2.3717 (2.3455–2.3889) |
| no-inline-1 | chain_24/2 | 1.0317 (1.0113–1.0982) | 2.3920 (2.3348–2.4852) |
| no-inline-1 | branches_24/0 | 1.0005 (0.9951–1.0142) | 1.6932 (1.6387–1.7187) |
| no-inline-1 | branches_24/1 | 1.0153 (0.9980–1.0262) | 1.7160 (1.6777–1.7345) |
| no-inline-1 | branches_24/2 | 0.9982 (0.9864–1.0163) | 1.6855 (1.6589–1.7190) |
| no-inline-2 | hinge_motor/0 | 0.9711 (0.9674–0.9731) | 1.1412 (1.1358–1.1453) |
| no-inline-2 | hinge_motor/1 | 0.9722 (0.9704–0.9753) | 1.1400 (1.1368–1.1433) |
| no-inline-2 | hinge_motor/2 | 0.9681 (0.9644–0.9714) | 1.1365 (1.1336–1.1392) |
| no-inline-2 | affine_chain/0 | 0.9797 (0.9669–0.9893) | 1.2518 (1.2302–1.2667) |
| no-inline-2 | affine_chain/1 | 0.9791 (0.9749–0.9911) | 1.2284 (1.2060–1.2477) |
| no-inline-2 | affine_chain/2 | 0.9832 (0.9714–0.9941) | 1.2441 (1.2120–1.2665) |
| no-inline-2 | branched/0 | 0.9825 (0.9538–0.9857) | 1.1994 (1.1726–1.2035) |
| no-inline-2 | branched/1 | 0.9772 (0.9716–0.9883) | 1.1885 (1.1730–1.2030) |
| no-inline-2 | branched/2 | 0.9904 (0.9728–1.0127) | 1.1857 (1.1626–1.2269) |
| no-inline-2 | ball/0 | 1.0014 (0.9767–1.0040) | 1.2813 (1.2538–1.2882) |
| no-inline-2 | ball/1 | 1.0046 (0.9821–1.0531) | 1.2579 (1.2279–1.3782) |
| no-inline-2 | ball/2 | 1.0020 (0.9591–1.0059) | 1.2588 (1.2397–1.2870) |
| no-inline-2 | free/0 | 0.9819 (0.9262–0.9857) | 1.2955 (1.2518–1.3085) |
| no-inline-2 | free/1 | 0.9825 (0.9776–0.9862) | 1.2899 (1.2623–1.3059) |
| no-inline-2 | free/2 | 0.9821 (0.9798–0.9853) | 1.3027 (1.2971–1.3119) |
| no-inline-2 | free_ball/0 | 0.9830 (0.9547–1.0129) | 1.7604 (1.7244–1.8004) |
| no-inline-2 | free_ball/1 | 0.9874 (0.9622–1.0018) | 1.7460 (1.7188–1.7718) |
| no-inline-2 | free_ball/2 | 0.9732 (0.9552–0.9992) | 1.7308 (1.7190–1.7543) |
| no-inline-2 | fixed_tendon/0 | 0.9762 (0.9738–0.9864) | 1.2544 (1.2506–1.2660) |
| no-inline-2 | fixed_tendon/1 | 0.9728 (0.9577–0.9794) | 1.2489 (1.2232–1.2580) |
| no-inline-2 | fixed_tendon/2 | 0.9788 (0.9745–0.9869) | 1.2590 (1.2524–1.2704) |
| no-inline-2 | spatial_ball/0 | 0.9575 (0.9560–0.9589) | 1.5313 (1.4988–1.5350) |
| no-inline-2 | spatial_ball/1 | 0.9589 (0.9577–0.9598) | 1.5275 (1.5121–1.5350) |
| no-inline-2 | spatial_ball/2 | 0.9597 (0.9587–0.9620) | 1.5354 (1.5211–1.5408) |
| no-inline-2 | chain_24/0 | 1.0105 (0.9954–1.0312) | 2.3716 (2.3409–2.4231) |
| no-inline-2 | chain_24/1 | 1.0020 (0.9932–1.0120) | 2.3616 (2.3233–2.3864) |
| no-inline-2 | chain_24/2 | 1.0030 (0.9930–1.0153) | 2.3566 (2.3311–2.3845) |
| no-inline-2 | branches_24/0 | 1.0096 (0.9927–1.0280) | 1.7117 (1.6796–1.7429) |
| no-inline-2 | branches_24/1 | 1.0130 (0.9989–1.0586) | 1.7138 (1.6581–1.7728) |
| no-inline-2 | branches_24/2 | 0.9984 (0.9891–1.0098) | 1.6954 (1.6815–1.7179) |

All112 preceding inventory entries remain unchanged. ZIP exclusions are compiler/prover caches and external toolchains; frozen source, proofs, binaries, disassembly, inputs, bit outputs, gprof artifacts and all raw timing records are retained.
