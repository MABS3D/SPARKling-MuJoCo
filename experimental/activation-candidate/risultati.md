# Activation dynamics: verification and performance, 2026-09-27

This isolated candidate implements integrator, filter and filterexact. Numerical tests pass; full Gold composition and C performance parity remain incomplete. Main repository and Git state were not changed.

## Formal evidence

Counts below are emitted proof checks in the named bounded invocation, not a global count of independent theorems. Every listed invocation completed with zero unproved/flow diagnostics and zero errors. Snapshots and commands are archived separately; the results apply to their exact source snapshots and called contracts. Later edits to unrelated scopes are not a whole-project reproof.

| Scope | Checks | Evidence directory |
| --- | ---: | --- |
| `Next_Value` | 2 | `kernel-v4` |
| `Derivative` | 4 | `kernel-v4` |
| `Raw_Next` | 7 | `kernel-v4` |
| `Prepare` | 5 | `prepare-proofs` |
| `Force_For` | 6 | `actuation-proofs` |
| `Compute` | 80 | `compute-paths` |
| `Compute_Activated` | 81 | `fused-final-proof` |
| `Equal_State_Images` | 3 | `setter-state-images` |
| `Equal_Activation_Images` | 13 | `setter-complete` |
| `Set_Activation` | 43 | `setter-complete` |
| **Sum of closed scoped checks** | **244** | |

Open work:

- `Exact_Factor`: one runtime-library overflow-model obligation at `Exp`, in `factor-proof`. The saved VC declares `exp_no_overflow` without a defining axiom for the nonpositive bounded argument. Its factor has a range contract, not a proven mathematical exponential postcondition. No suppression or new trusted assumption closes this gap.
- `Actuation_Phase.Compute_Ready`: final proof invocation timed out at 240 seconds; timeout is not a pass.
- Creation/validation, reset, Euler and the strengthened phase frame conditions still need complete composition proofs on the activation representation. This is unfinished proof engineering, not a Silver mathematical exception.

## Checked tests

| Suite | Scenarios | Result / evidence |
| --- | ---: | --- |
| Activation, Compatible | 432 | PASS; `functional-v4`, 3,456 comparisons |
| Activation, Strict | 432 | PASS; `strict-functional`, 3,456 comparisons |
| Stateless regression | 624 | PASS; `regression-v4`, 168,192 comparisons |
| Edge and capacity, final checked binary | 46 | PASS; `edges-delivery` |
| Failure atomicity, final checked binary | 4 | PASS; `failures-delivery` |

The two 432-case suites have bit-identical `act` and `act_dot` to C in their sampled cases. Maximum acceleration difference is 3.56e-15. This is sampled compatibility, not a universal equality proof. Edges cover mixed stateful/stateless indexing, external loads, tau flooring, 1/6/24 DOFs and up to 1,024 activation states. Failure tests check the finite-domain API policy and preservation of qpos/qvel/time/activation; they do not assert that C rejects the same input.

Final checked build: `checked-delivery`. Full numerical/regression suites were run before the final ghost proof helper and frame-only edits; edges and failure cases were repeated on the final checked binary. The final release binary was rebuilt and timed twice because its machine-code hash differed from the earlier release. Earlier timings are retained as historical evidence, not relabeled as final-binary results.

## Integrated performance

Pinned native C MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`; native Ada/GNAT 16.1. See build manifests for all flags, executable/library/source hashes, CPU and C++ runtime. Normal C SIMD is enabled. Matching models, states and controls; all final trajectories checked against the saved C reference.

Each session uses 24 alternating Ada/C blocks, four samples of 100 Euler steps, two warmups, CPU 12. Input setup and I/O are outside timing. Shared-host concurrent workloads add noise. Bootstrap intervals describe these observations, not quiet-host guarantees.

Percentages below are **time change** `(Ada/C - 1)*100`, using median paired ratios. Negative is less time. Do not average these percentages into an overall speedup.

| Case | Session 1 change [95% CI] | Session 2 change [95% CI] | Session 2 Ada / C, µs |
| --- | ---: | ---: | ---: |
| integrator-1dof-1act | -21.3% [-25.5, -20.5] | -34.2% [-36.6, -29.2] | 0.492 / 0.749 |
| filter-1dof-1act | -24.0% [-30.5, -19.8] | -25.2% [-36.6, -22.6] | 0.476 / 0.685 |
| filterexact-1dof-1act | -24.3% [-28.3, -23.3] | -25.1% [-34.2, -16.9] | 0.503 / 0.566 |
| integrator-6dof-6act | +7.2% [+5.6, +9.4] | +5.0% [+0.5, +20.3] | 1.849 / 1.569 |
| filter-6dof-6act | +5.3% [-2.1, +7.2] | +1.3% [-2.0, +7.9] | 1.844 / 1.910 |
| filterexact-6dof-6act | +1.8% [-2.1, +3.3] | -4.8% [-11.4, -1.1] | 1.968 / 2.113 |
| integrator-24dof-24act | +29.8% [+13.5, +68.9] | +35.5% [+25.3, +40.9] | 7.920 / 5.937 |
| filter-24dof-24act | +27.4% [+12.4, +44.1] | +27.8% [+18.7, +32.6] | 7.998 / 6.560 |
| filterexact-24dof-24act | +19.6% [+11.6, +32.3] | +30.6% [+23.6, +35.0] | 9.164 / 6.863 |
| integrator-1dof-64act | -65.8% [-67.6, -63.0] | -64.7% [-68.4, -60.9] | 0.884 / 2.486 |
| filter-1dof-64act | -63.1% [-66.6, -57.2] | -63.8% [-67.8, -59.2] | 0.962 / 2.710 |
| filterexact-1dof-64act | -71.5% [-72.3, -70.2] | -71.1% [-73.7, -67.6] | 0.970 / 3.069 |
| integrator-6dof-192act | -57.8% [-60.7, -55.0] | -57.8% [-61.2, -56.7] | 2.468 / 5.609 |
| filter-6dof-192act | -56.5% [-60.0, -55.7] | -57.3% [-59.1, -55.8] | 2.999 / 5.647 |
| filterexact-6dof-192act | -68.2% [-71.6, -65.4] | -69.7% [-71.3, -67.0] | 2.856 / 8.958 |
| integrator-24dof-192act | -11.4% [-14.8, -9.8] | -14.1% [-19.9, -6.5] | 8.544 / 9.268 |
| filter-24dof-192act | -6.5% [-15.1, +4.7] | -19.8% [-22.7, -13.6] | 11.295 / 14.010 |
| filterexact-24dof-192act | -23.0% [-27.3, -20.7] | -32.4% [-38.6, -26.0] | 11.357 / 16.820 |

**Performance parity is not achieved across the full workload set.** 24-DOF/24-actuator chains remain roughly 20–36% slower. Integrator at 6 DOFs also has a small measured regression. The 1-DOF and actuator-heavy workloads use less time; some small differences have intervals crossing parity.

`cost-attribution` compares zero-control/zero-activation trajectories with and without dynamics on the earlier frozen binary. It shows a baseline 24-DOF gap without activation dynamics as well. Small incremental estimates are noisy (some are negative); it is diagnostic evidence, not exact stage-cost attribution. It does not excuse the unmet integrated target.

## Next acceptance gates

1. Close loader/reset/phase/Euler composition and the elementary-function proof model without hiding obligations.
2. Profile the final 24-DOF baseline and active models by phase; reduce the shared dynamics bottleneck, and recheck 6-DOF integrator.
3. Repeat matched nonzero trajectory and performance tests on a quiet host before declaring C parity.
4. Merge this isolated patch against the current main working tree with conflict review; the snapshot includes pre-existing external-force work and must not overwrite newer edits.
