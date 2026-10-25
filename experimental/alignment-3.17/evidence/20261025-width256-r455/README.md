# Local release-only 256-bit kernel preference r455

The derivative candidate and its shared builders use `-mprefer-vector-width=256` for `mj-solver_kernels.adb` in release only. Native O3, release LTO, FP contraction off, threshold16, all checked Ada bodies/contracts and ordinary validation flags are unchanged. The production C3.14 project/pin is untouched. This is a measured native-target configuration, not a portable speedup guarantee.

C3.17 source review: `engine_core_smooth.c` mj_factorI updates contiguous ancestor rows through mju_addToScl; the normal AVX helper uses four doubles (256 bits). Static disassembly of the actual Ada Add_Long_Row changes from four zmm arithmetic sites to four ymm sites. These are instruction sites, not dynamic counts or a causal attribution of every timing change. Scale_Row is in the same compilation unit and can also be affected.

The private two-reference suite passes all ten mass/derivative profile gates against C3.17/C3.14, including reversed mass storage for C3.17, plus row, cache and direct-constructor gates. The actual adopted GPR and shared builders are independently rebuilt/rechecked. Ada source and GPR bridges record the exact relationship. Both row profiles check 14,905 cases, cache checks48 records/144 states, and direct constructors check1,026 cases/100,236 values per profile. These numerical tests are separate from universal functional proofs.

No new language-level proof claim: the unchanged checked Ada source retains the scoped r441/r430 results. Three examined caller obligations remain, along with wider physical binding, factor/inverse/full dynamics and port/migration work. No mathematical domain narrowing, new assumption, suppression, changed deallocator, whole-dynamics Gold or C-parity claim.

The first private gate coordinator stopped after11 completed gates because its preparation anchor used command instead of cmd in the cache runner. The corrected resume recipe preserved those results and completed cache/constructors; the failure and correction are retained in harness-correction.json.

## Actual default movement results

Two full sessions;30 scenarios,24 balanced blocks,8 samples,32 warmups,100 steps,CPU12 on this WSL2/native target. Baseline is the retained default-vector-width LTO binary, current is the actual adopted default builder, C is the pinned source-built normal AVX/LTO reference with known flags (r430). Oracle correctness uses the independent C3.17 wheel. Exact Ada outputs and unchanged source/binary hashes pass. All raw samples, CIs and tail/dispersion statistics are archived. No own heavy job ran concurrently with timing.

| Session | Model/state | Current/baseline (95% CI) | Current/C (95% CI) |
|---|---|---|---|
| 1 | hinge_motor/0 | 0.9793 (0.9741–0.9885) | 1.1056 (1.0733–1.1191) |
| 1 | hinge_motor/1 | 0.9818 (0.9766–0.9875) | 1.1131 (1.0948–1.1191) |
| 1 | hinge_motor/2 | 0.9786 (0.9619–0.9820) | 1.1163 (1.1110–1.1186) |
| 1 | affine_chain/0 | 0.9765 (0.9728–0.9801) | 1.2033 (1.1976–1.2103) |
| 1 | affine_chain/1 | 0.9798 (0.9749–0.9867) | 1.2085 (1.1954–1.2180) |
| 1 | affine_chain/2 | 0.9787 (0.9689–0.9854) | 1.2129 (1.1994–1.2223) |
| 1 | branched/0 | 0.9722 (0.9690–0.9787) | 1.1987 (1.1902–1.2060) |
| 1 | branched/1 | 0.9739 (0.9691–0.9758) | 1.2000 (1.1920–1.2033) |
| 1 | branched/2 | 0.9727 (0.9634–0.9745) | 1.1984 (1.1949–1.2023) |
| 1 | ball/0 | 0.9425 (0.9407–0.9449) | 1.2678 (1.2627–1.2718) |
| 1 | ball/1 | 0.9444 (0.9420–0.9462) | 1.2655 (1.2371–1.2708) |
| 1 | ball/2 | 0.9439 (0.9383–0.9453) | 1.2518 (1.2308–1.2682) |
| 1 | free/0 | 0.9857 (0.9782–0.9893) | 1.3155 (1.2694–1.3208) |
| 1 | free/1 | 0.9855 (0.9833–0.9872) | 1.3098 (1.2975–1.3185) |
| 1 | free/2 | 0.9817 (0.9556–0.9863) | 1.3033 (1.2914–1.3118) |
| 1 | free_ball/0 | 0.9846 (0.9612–1.0440) | 1.7644 (1.6849–1.8773) |
| 1 | free_ball/1 | 0.9830 (0.8478–1.0220) | 1.6886 (1.3679–1.7920) |
| 1 | free_ball/2 | 0.9821 (0.9525–1.0148) | 1.7268 (1.7062–1.7852) |
| 1 | fixed_tendon/0 | 0.9184 (0.9141–0.9352) | 1.2521 (1.2275–1.2697) |
| 1 | fixed_tendon/1 | 0.9172 (0.9143–0.9188) | 1.2487 (1.2373–1.2520) |
| 1 | fixed_tendon/2 | 0.9154 (0.9115–0.9208) | 1.2550 (1.2504–1.2600) |
| 1 | spatial_ball/0 | 0.9509 (0.9498–0.9526) | 1.5533 (1.5379–1.5572) |
| 1 | spatial_ball/1 | 0.9508 (0.9488–0.9560) | 1.5408 (1.5092–1.5557) |
| 1 | spatial_ball/2 | 0.9486 (0.9422–0.9508) | 1.5523 (1.5454–1.5564) |
| 1 | chain_24/0 | 0.9781 (0.9657–0.9898) | 2.3643 (2.3343–2.3946) |
| 1 | chain_24/1 | 0.9796 (0.9646–0.9942) | 2.3897 (2.3537–2.4244) |
| 1 | chain_24/2 | 0.9760 (0.9525–0.9909) | 2.3481 (2.2957–2.3861) |
| 1 | branches_24/0 | 0.9938 (0.9833–1.0051) | 1.6848 (1.6481–1.7064) |
| 1 | branches_24/1 | 1.0138 (0.9909–1.0586) | 1.6582 (1.5485–1.7461) |
| 1 | branches_24/2 | 0.9930 (0.9800–1.0066) | 1.6762 (1.6359–1.7022) |
| 2 | hinge_motor/0 | 0.9806 (0.9768–0.9838) | 1.1124 (1.1067–1.1187) |
| 2 | hinge_motor/1 | 0.9798 (0.9755–0.9831) | 1.1128 (1.1067–1.1166) |
| 2 | hinge_motor/2 | 0.9792 (0.9746–0.9840) | 1.1184 (1.1134–1.1222) |
| 2 | affine_chain/0 | 0.9787 (0.9737–0.9856) | 1.2113 (1.1914–1.2189) |
| 2 | affine_chain/1 | 0.9755 (0.9696–0.9803) | 1.2042 (1.1997–1.2076) |
| 2 | affine_chain/2 | 0.9779 (0.9744–0.9796) | 1.2119 (1.2084–1.2153) |
| 2 | branched/0 | 0.9737 (0.9689–0.9802) | 1.1989 (1.1910–1.2074) |
| 2 | branched/1 | 0.9729 (0.9689–0.9758) | 1.1979 (1.1907–1.2042) |
| 2 | branched/2 | 0.9750 (0.9694–0.9826) | 1.1998 (1.1958–1.2107) |
| 2 | ball/0 | 0.9441 (0.9426–0.9462) | 1.2699 (1.2649–1.2738) |
| 2 | ball/1 | 0.9451 (0.9430–0.9499) | 1.2684 (1.2452–1.2778) |
| 2 | ball/2 | 0.9408 (0.8393–0.9519) | 1.2702 (1.2340–1.2854) |
| 2 | free/0 | 0.9868 (0.9830–0.9900) | 1.3071 (1.2875–1.3150) |
| 2 | free/1 | 0.9844 (0.9724–0.9872) | 1.2952 (1.2724–1.3101) |
| 2 | free/2 | 0.9847 (0.9832–0.9877) | 1.3103 (1.2957–1.3177) |
| 2 | free_ball/0 | 0.9847 (0.9532–1.0116) | 1.7809 (1.7217–1.8148) |
| 2 | free_ball/1 | 0.9886 (0.9606–1.0139) | 1.7763 (1.7020–1.8028) |
| 2 | free_ball/2 | 0.9709 (0.9424–0.9965) | 1.7496 (1.6983–1.7821) |
| 2 | fixed_tendon/0 | 0.9153 (0.9114–0.9272) | 1.2494 (1.2381–1.2641) |
| 2 | fixed_tendon/1 | 0.9151 (0.9120–0.9236) | 1.2519 (1.2271–1.2626) |
| 2 | fixed_tendon/2 | 0.9175 (0.9143–0.9252) | 1.2537 (1.2286–1.2661) |
| 2 | spatial_ball/0 | 0.9488 (0.9459–0.9507) | 1.5483 (1.5228–1.5570) |
| 2 | spatial_ball/1 | 0.9504 (0.9495–0.9637) | 1.5354 (1.5131–1.5563) |
| 2 | spatial_ball/2 | 0.9482 (0.9363–0.9520) | 1.5483 (1.5437–1.5568) |
| 2 | chain_24/0 | 0.9782 (0.8766–1.0391) | 2.1766 (1.9339–2.4196) |
| 2 | chain_24/1 | 0.9768 (0.9639–0.9928) | 2.3605 (2.3406–2.3948) |
| 2 | chain_24/2 | 0.9818 (0.9743–0.9952) | 2.3645 (2.3454–2.4030) |
| 2 | branches_24/0 | 0.9978 (0.9763–1.0719) | 1.6827 (1.6252–1.8144) |
| 2 | branches_24/1 | 1.0021 (0.9810–1.0097) | 1.7036 (1.6728–1.7155) |
| 2 | branches_24/2 | 1.0122 (0.9927–1.0225) | 1.6935 (1.6519–1.7062) |

Ratios below1 favor current Ada; ratios above1 against C remain a gap. Do not average these model percentages or count winners to claim aggregate compensation. Prototype timings are separately retained. Small changes whose CIs include1 remain inconclusive; no arbitrary noise allowance is applied.

No commits, staging, pushes or remote writes. HEAD remains `398c2dde5299ec46cfb00bffd91e7660a852907a`. Previous107 inventory files are preserved byte-for-byte. The ZIP excludes compiler/prover caches and external toolchains; it retains frozen sources, manifests, compiler recipes, executables, logs, generated inputs, numerical outputs and all raw integrated timing results.
