# Numerical-guard cost after scan parity

Commit `677e75474f81e76cc0c99dd7eeb2edb22d5f6af9`. Diagnostic only; no runtime source changes or new proof claims.

Two sessions, CPU 12, 20 balanced blocks per case; 11 models × 3 initial states, 10 variants including C. Each invocation: 2 warmups, 4 timed trajectories of 100 steps. Preparation and I/O excluded. Checks: qpos/qvel/time against C reference, atol=rtol=2e-10; diagnostic Ada values must equal baseline serialized values. Ratios use paired blocks and bootstrap 95% confidence intervals (10,000 resamples). Ranges below cover 3 states × 2 sessions, not confidence intervals.

| Model | Baseline / C | All selected guards removed / C | Step-time saving | CI95 entirely below baseline |
|---|---:|---:|---:|---:|
| hinge_motor | 0.699–0.705 | 0.718–0.723 | -3.396–-2.587% | 0/6 |
| branched_multijoint | 1.003–1.013 | 0.851–0.865 | 14.449–15.707% | 6/6 |
| chain_12 | 1.375–1.409 | 1.115–1.140 | 18.272–19.198% | 6/6 |
| crb_no_damping | 1.269–1.277 | 1.076–1.084 | 14.563–15.361% | 6/6 |
| crb_chain_24 | 1.467–1.526 | 1.158–1.192 | 21.070–21.742% | 6/6 |
| ancestor_star_24 | 1.669–1.688 | 1.376–1.411 | 16.774–18.263% | 6/6 |
| ancestor_forest_24 | 1.549–1.586 | 1.293–1.315 | 16.155–18.073% | 6/6 |
| ancestor_branches_24 | 1.556–1.597 | 1.290–1.302 | 17.376–18.444% | 6/6 |
| simple_hinges_6 | 1.483–1.496 | 1.342–1.349 | 9.213–9.901% | 6/6 |
| simple_sliders_6 | 0.842–0.858 | 0.688–0.698 | 17.580–18.677% | 6/6 |
| simple_mixed_8 | 0.963–0.971 | 0.758–0.771 | 20.471–21.555% | 6/6 |

## Isolated families

Effects cannot be added: branch removal changes generated code and can interact with vectorization. A negative saving is a slowdown.

| Family | Saving range across all cases | CI95 below baseline |
|---|---:|---:|
| pose_guards | -2.201–4.716% | 42/66 |
| spatial_guards | -0.557–5.968% | 38/66 |
| force_guards | 0.031–13.600% | 60/66 |
| inertia_guards | -6.838–5.235% | 41/66 |
| row_guards | -3.421–10.651% | 29/66 |
| reduction_guards | -2.150–2.928% | 19/66 |
| all_guards | -3.396–21.742% | 60/66 |
| no_vector | -30.923–5.647% | 10/66 |

Scope: selected Bounded/Within_Work/Division_Bounded checks and solver rejection reductions, including checks moved into MJ.Fused_RNE. Time/state-integration guards, normalisation, pivot clamping and other algorithmic branches remain. Strict-only changes in the diagnostic patch do not establish a measured benefit on the Compatible movement path. no_vector disables tree/SLP vectorization; it measures the benefit of existing vectorization, not a missing optimization. Compact mass assembly and gravity/bias fusion were not remeasured; their old costs must not be treated as current.

Maximum C-reference error: 3.8913317013111737e-14. Maximum diagnostic-Ada difference: 0.

Raw data retain block timings, medians, MAD, p95 and confidence intervals. p95 concerns trajectory-average step times, not individual-step latency. Diagnostic patches and hashes are archived for reproduction.
