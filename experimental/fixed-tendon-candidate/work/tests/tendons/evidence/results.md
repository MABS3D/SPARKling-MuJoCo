# Fixed-tendon acceptance results

**Integration draft: full Gold and performance parity across all supported workloads are not established.**

The supported implementation is described in [the scope and reproduction guide](../README.md).

## Checked numerical agreement

| Policy | Scenarios | Scalar comparisons | Policy/rejection tests | Result |
|---|---:|---:|---:|---|
| Compatible | 648 | 92232 | 17 | passed |
| Strict | 648 | 92232 | 17 | passed |

Tolerance: `2e-10 + 2e-10*abs(reference)`. This is sampled agreement, not a universal equivalence proof.

## Integrated performance

All ratios are **Ada time / C time**, lower is faster. The range below spans the individual state/session median ratios; it is not a pooled mean or a confidence interval.

| Workload | DOFs | Tendons | Range of median ratios |
|---|---:|---:|---:|
| tendon_scalar | 1 | 1 | 0.5502–0.5657 |
| tendon_chain_6 | 6 | 3 | 1.0607–1.0825 |
| tendon_branches_6 | 6 | 3 | 0.9379–0.9516 |
| tendon_nonlinear | 6 | 3 | 1.0338–1.0718 |
| tendon_chain_24 | 24 | 12 | 1.0914–1.1262 |
| hinge_motor | 1 | 0 | 0.6700–0.7169 |
| branched_multijoint | 5 | 0 | 1.0025–1.0204 |
| chain_24_without_tendons | 24 | 0 | 1.4328–1.4613 |

The CPU, compiler, release flags, hashes and raw paired samples are archived. Baseline Ada is compared only on the no-tendon controls.

No own proof/build jobs ran concurrently with the final timing sessions. Other activity on this shared machine was not controlled. Load averages are recorded below; a low average alone cannot certify an interference-free session.

- Session 1: 24 alternating blocks, 15 samples × 1000 Euler steps, 3 states per model, CPU 12; load averages start `[1.35546875, 2.89404296875, 5.30712890625]`, end `[1.16552734375, 2.49853515625, 4.9794921875]`.
- Session 2: 24 alternating blocks, 15 samples × 1000 Euler steps, 3 states per model, CPU 12; load averages start `[0.779296875, 2.27490234375, 4.8251953125]`, end `[1.25439453125, 2.0927734375, 4.56103515625]`.

### Individual results

MAD and p95 refer to trajectory-average ns/step. Ratio confidence intervals use paired block medians and bootstrap resampling within a session.

| Session | Case/state | Ada median ns | C median ns | Ada MAD ns | Ada p95 ns | Ratio [95% CI] |
|---:|---|---:|---:|---:|---:|---|
| 1 | tendon_scalar-0 | 304.9 | 544.7 | 9.5 | 452.8 | 0.5541 [0.5454, 0.5634] |
| 1 | tendon_scalar-1 | 305.5 | 551.3 | 9.6 | 419.4 | 0.5503 [0.5300, 0.5649] |
| 1 | tendon_scalar-2 | 306.9 | 547.0 | 11.1 | 470.9 | 0.5540 [0.5392, 0.5703] |
| 1 | tendon_chain_6-0 | 1495.4 | 1401.6 | 40.3 | 1956.0 | 1.0752 [1.0657, 1.0896] |
| 1 | tendon_chain_6-1 | 1485.2 | 1413.9 | 34.1 | 1936.1 | 1.0607 [1.0186, 1.0709] |
| 1 | tendon_chain_6-2 | 1481.5 | 1381.3 | 32.5 | 1919.8 | 1.0686 [1.0577, 1.0859] |
| 1 | tendon_branches_6-0 | 1138.5 | 1202.8 | 36.2 | 1545.3 | 0.9447 [0.9364, 0.9727] |
| 1 | tendon_branches_6-1 | 1130.2 | 1198.2 | 21.9 | 1494.5 | 0.9418 [0.9273, 0.9572] |
| 1 | tendon_branches_6-2 | 1123.5 | 1206.8 | 21.3 | 1502.3 | 0.9379 [0.9186, 0.9466] |
| 1 | tendon_nonlinear-0 | 1471.3 | 1387.3 | 21.9 | 1965.4 | 1.0631 [1.0501, 1.0743] |
| 1 | tendon_nonlinear-1 | 1480.3 | 1384.3 | 28.0 | 1940.7 | 1.0710 [1.0635, 1.0892] |
| 1 | tendon_nonlinear-2 | 1488.5 | 1387.4 | 35.2 | 1924.7 | 1.0718 [1.0509, 1.1024] |
| 1 | tendon_chain_24-0 | 9386.5 | 8375.2 | 268.0 | 12312.4 | 1.1260 [1.0995, 1.1464] |
| 1 | tendon_chain_24-1 | 9411.0 | 8361.5 | 289.2 | 12099.9 | 1.1183 [1.1046, 1.1333] |
| 1 | tendon_chain_24-2 | 9463.1 | 8464.3 | 272.9 | 12133.7 | 1.1168 [1.0949, 1.1367] |
| 1 | hinge_motor-0 | 329.2 | 473.3 | 7.1 | 387.4 | 0.6876 [0.6780, 0.7021] |
| 1 | hinge_motor-1 | 333.0 | 483.6 | 9.0 | 404.3 | 0.6848 [0.6771, 0.6933] |
| 1 | hinge_motor-2 | 331.1 | 480.7 | 9.3 | 483.9 | 0.6967 [0.6838, 0.7086] |
| 1 | branched_multijoint-0 | 1075.2 | 1070.0 | 20.7 | 1390.8 | 1.0086 [0.9959, 1.0164] |
| 1 | branched_multijoint-1 | 1071.6 | 1062.4 | 20.0 | 1403.6 | 1.0128 [1.0087, 1.0146] |
| 1 | branched_multijoint-2 | 1080.6 | 1066.9 | 28.3 | 1417.4 | 1.0165 [0.9985, 1.0335] |
| 1 | chain_24_without_tendons-0 | 6937.5 | 4779.4 | 192.5 | 9079.3 | 1.4506 [1.4290, 1.4714] |
| 1 | chain_24_without_tendons-1 | 7052.3 | 4854.8 | 198.7 | 9463.8 | 1.4563 [1.4405, 1.4736] |
| 1 | chain_24_without_tendons-2 | 7197.9 | 4869.4 | 331.5 | 9612.1 | 1.4613 [1.4436, 1.5054] |
| 2 | tendon_scalar-0 | 309.8 | 550.5 | 15.6 | 457.8 | 0.5558 [0.5452, 0.5773] |
| 2 | tendon_scalar-1 | 313.3 | 552.2 | 16.6 | 444.7 | 0.5657 [0.5554, 0.5817] |
| 2 | tendon_scalar-2 | 304.7 | 549.9 | 10.0 | 452.0 | 0.5502 [0.5220, 0.5612] |
| 2 | tendon_chain_6-0 | 1521.6 | 1414.2 | 56.4 | 2033.5 | 1.0825 [1.0505, 1.1012] |
| 2 | tendon_chain_6-1 | 1509.9 | 1428.0 | 48.2 | 2001.4 | 1.0621 [1.0434, 1.0822] |
| 2 | tendon_chain_6-2 | 1494.4 | 1389.2 | 39.4 | 2028.8 | 1.0767 [1.0680, 1.0877] |
| 2 | tendon_branches_6-0 | 1157.1 | 1219.6 | 46.2 | 1585.6 | 0.9495 [0.9214, 0.9698] |
| 2 | tendon_branches_6-1 | 1123.0 | 1183.4 | 18.3 | 1493.9 | 0.9516 [0.9426, 0.9539] |
| 2 | tendon_branches_6-2 | 1126.4 | 1198.6 | 27.1 | 1551.9 | 0.9475 [0.9411, 0.9558] |
| 2 | tendon_nonlinear-0 | 1510.5 | 1411.1 | 53.9 | 1989.6 | 1.0671 [1.0435, 1.0847] |
| 2 | tendon_nonlinear-1 | 1483.2 | 1384.2 | 32.8 | 1949.5 | 1.0669 [1.0557, 1.0821] |
| 2 | tendon_nonlinear-2 | 1504.8 | 1448.2 | 48.6 | 1977.7 | 1.0338 [0.9906, 1.0831] |
| 2 | tendon_chain_24-0 | 9647.9 | 8873.7 | 440.2 | 13182.3 | 1.0914 [1.0277, 1.1151] |
| 2 | tendon_chain_24-1 | 9606.7 | 8587.0 | 469.7 | 13393.0 | 1.1034 [1.0777, 1.1335] |
| 2 | tendon_chain_24-2 | 9556.9 | 8585.3 | 427.4 | 13445.2 | 1.1262 [1.0994, 1.1473] |
| 2 | hinge_motor-0 | 389.1 | 536.7 | 54.8 | 526.6 | 0.7169 [0.6800, 0.7455] |
| 2 | hinge_motor-1 | 376.2 | 517.1 | 50.1 | 541.1 | 0.7036 [0.6901, 0.8057] |
| 2 | hinge_motor-2 | 371.6 | 537.1 | 46.1 | 518.6 | 0.6700 [0.6260, 0.7780] |
| 2 | branched_multijoint-0 | 1157.0 | 1101.1 | 94.6 | 1525.1 | 1.0204 [1.0099, 1.0784] |
| 2 | branched_multijoint-1 | 1103.7 | 1078.3 | 51.4 | 1522.9 | 1.0081 [0.9952, 1.0267] |
| 2 | branched_multijoint-2 | 1074.2 | 1062.0 | 22.1 | 1391.3 | 1.0025 [0.9925, 1.0186] |
| 2 | chain_24_without_tendons-0 | 7154.0 | 4944.5 | 338.6 | 9584.0 | 1.4328 [1.3972, 1.4571] |
| 2 | chain_24_without_tendons-1 | 7074.9 | 4922.1 | 278.4 | 9173.3 | 1.4506 [1.4241, 1.4669] |
| 2 | chain_24_without_tendons-2 | 7017.0 | 4786.9 | 229.2 | 9163.7 | 1.4536 [1.4405, 1.4873] |

### Controls against the pre-change Ada baseline

Baseline/C is calculated directly from paired blocks, with a separate 2000-resample bootstrap. These are no-tendon workloads; they identify a pre-existing whole-pipeline gap, not the causal cost of individual tendon operations.

| Session | Case/state | Baseline/C [95% CI] | Current/baseline [95% CI] |
|---:|---|---|---|
| 1 | hinge_motor-0 | 0.6890 [0.6739, 0.6945] | 0.9997 [0.9888, 1.0205] |
| 1 | hinge_motor-1 | 0.6759 [0.6587, 0.6816] | 1.0245 [1.0065, 1.0429] |
| 1 | hinge_motor-2 | 0.6810 [0.6712, 0.7034] | 1.0217 [1.0023, 1.0355] |
| 1 | branched_multijoint-0 | 1.0024 [0.9955, 1.0103] | 1.0064 [0.9936, 1.0156] |
| 1 | branched_multijoint-1 | 1.0085 [0.9946, 1.0270] | 1.0030 [0.9986, 1.0139] |
| 1 | branched_multijoint-2 | 0.9969 [0.9823, 1.0154] | 1.0101 [1.0043, 1.0209] |
| 1 | chain_24_without_tendons-0 | 1.4774 [1.4564, 1.5028] | 0.9851 [0.9680, 0.9927] |
| 1 | chain_24_without_tendons-1 | 1.4919 [1.4740, 1.5496] | 0.9684 [0.9459, 0.9844] |
| 1 | chain_24_without_tendons-2 | 1.4801 [1.4546, 1.5177] | 0.9788 [0.9643, 1.0044] |
| 2 | hinge_motor-0 | 0.6322 [0.5989, 0.7027] | 1.1020 [1.0049, 1.1910] |
| 2 | hinge_motor-1 | 0.7089 [0.6628, 0.7478] | 0.9871 [0.9571, 1.0510] |
| 2 | hinge_motor-2 | 0.6871 [0.6496, 0.7667] | 0.9842 [0.9341, 1.0442] |
| 2 | branched_multijoint-0 | 0.9907 [0.9732, 1.0067] | 1.0429 [1.0199, 1.1068] |
| 2 | branched_multijoint-1 | 1.0032 [0.9818, 1.0128] | 1.0133 [0.9955, 1.0334] |
| 2 | branched_multijoint-2 | 1.0029 [0.9874, 1.0243] | 1.0095 [0.9932, 1.0150] |
| 2 | chain_24_without_tendons-0 | 1.4673 [1.4344, 1.5141] | 0.9789 [0.9527, 0.9849] |
| 2 | chain_24_without_tendons-1 | 1.4843 [1.4558, 1.4938] | 0.9832 [0.9550, 1.0063] |
| 2 | chain_24_without_tendons-2 | 1.4834 [1.4599, 1.4981] | 0.9865 [0.9731, 1.0042] |

## Formal proof status

Latest attempts per selected subprogram: `{'completed_no_unproved': 29, 'unproved_checks': 5, 'completed_no_proof_checks': 1, 'proof_timeout': 3}`. A timeout with zero reported checks is not a pass. A successful fragment is conditional on its preconditions and called contracts; zero-check expression functions are not counted as proved obligations.

| Unit/subprogram | Result | Checks | Unproved/flow |
|---|---|---:|---:|
| `mj-tendon_kernels.adb:Polynomial_First` | completed_no_unproved | 5 | 0 |
| `mj-tendon_kernels.adb:Polynomial_Second` | completed_no_unproved | 7 | 0 |
| `mj-tendon_kernels.adb:Poly_Value` | completed_no_unproved | 6 | 0 |
| `mj-tendon_kernels.adb:Spring_Damper` | completed_no_unproved | 7 | 0 |
| `mj-tendon_kernels.adb:Sum_Step` | unproved_checks | 11 | 1 |
| `mj-tendon_kernels.adb:Reduced_Bound` | completed_no_unproved | 8 | 0 |
| `mj-tendon_kernels.adb:Dot` | completed_no_unproved | 25 | 0 |
| `mj-tendon_kernels.adb:Combine` | completed_no_unproved | 20 | 0 |
| `mj-tendon_kernels.adb:Tail_Add` | completed_no_unproved | 13 | 0 |
| `mj-tendon_kernels.adb:Unfold_Lane` | completed_no_unproved | 17 | 0 |
| `mj-tendon_kernels.adb:Unfold_Sparse` | completed_no_unproved | 35 | 0 |
| `mj-tendon_kernels.adb:Advance_Lane` | unproved_checks | 29 | 1 |
| `mj-tendon_kernels.adb:Advance_Tail` | unproved_checks | 33 | 1 |
| `mj-tendon_kernels.adb:Tail_Bound` | completed_no_unproved | 10 | 0 |
| `mj-tendon_kernels.adb:Sparse_Dot` | unproved_checks | 56 | 1 |
| `mj-tendon_kernels.adb:Fixed_Kinematics` | completed_no_unproved | 10 | 0 |
| `mj-tendon_kernels.adb:Project` | completed_no_unproved | 5 | 0 |
| `mj-tendon_kernels.adb:Mass_Entry` | completed_no_unproved | 7 | 0 |
| `mj-tendon_kernels.adb:Accumulate_Mass` | completed_no_unproved | 4 | 0 |
| `mj-tendon_kernels.adb:Project_Small` | completed_no_unproved | 6 | 0 |
| `mj-tendon_kernels.ads:Displacement` | completed_no_unproved | 4 | 0 |
| `mj-tendon_kernels.ads:Spring_Model` | completed_no_unproved | 4 | 0 |
| `mj-tendon_kernels.ads:Damper_Model` | completed_no_unproved | 2 | 0 |
| `mj-tendon_kernels.ads:Valid_Row` | completed_no_proof_checks | 0 | 0 |
| `mj-tendon_kernels.ads:Reduction` | completed_no_unproved | 15 | 0 |
| `mj-tendon_kernels.ads:Lane_Value` | completed_no_unproved | 20 | 0 |
| `mj-tendon_kernels.ads:Sparse_Model` | completed_no_unproved | 38 | 0 |
| `mj-fixed_tendons.adb:Load` | proof_timeout | 0 | 0 |
| `mj-fixed_tendons.adb:Kinematics` | completed_no_unproved | 23 | 0 |
| `mj-fixed_tendons.adb:Project_Pair` | completed_no_unproved | 19 | 0 |
| `mj-fixed_tendons.adb:Project_Small_Pair` | completed_no_unproved | 15 | 0 |
| `mj-fixed_tendons.adb:Add_Passive` | proof_timeout | 0 | 0 |
| `mj-fixed_tendons.ads:Mass_Model` | completed_no_unproved | 14 | 0 |
| `mj-fixed_tendons.adb:Unfold_Mass` | completed_no_unproved | 13 | 0 |
| `mj-fixed_tendons.adb:Store_Mass_Pair` | completed_no_unproved | 35 | 0 |
| `mj-fixed_tendons.adb:Add_Mass` | completed_no_unproved | 22 | 0 |
| `mj-data-tendon_phase.adb:Inertia` | unproved_checks | 5 | 4 |
| `mj-data-tendon_phase.adb:Passive` | proof_timeout | 0 | 0 |

Functional scopes include rounded polynomial terms, ordered length/velocity models, scalar projection with frame preservation, and ordered mass additions with symmetry. Read the diagnostics in `proofs.zip` for the obligations still open.

**Still open:** loader proof; remaining kernel/driver obligations; a full functional fold for the passive driver; caller integration and creation/readiness proof closure after adding tendon ownership; the changed tendon CSR validator. These are unfinished proof engineering, not mathematical Silver exceptions. Old whole-pipeline proofs are not automatically inherited by this changed configuration.

Spatial paths, tendon actuation/inherited actuator contributions and constraints remain outside this implementation. Performance acceptance for them is therefore absent. The 24-DOF workload must be assessed from both sessions and their uncertainty; an interval containing one establishes neither a speedup nor guaranteed non-inferiority.

## Evidence

`build.json`, `proof-index.json`, `numerics.json` and `timings.json` provide summaries. Zip archives contain raw logs, structured proof output, fixtures, inputs and timing samples. `changed-sources.zip` holds complete changed files to apply on the recorded baseline; `tracked.patch` omits new files by design. Binaries and object directories are excluded. `SHA256SUMS` covers the evidence files.
