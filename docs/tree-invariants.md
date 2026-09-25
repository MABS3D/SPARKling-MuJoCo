# Pose-tree proof closure and integrated performance

Recorded on 2026-09-25 against MuJoCo C 3.14.0 and repository baseline
`4c6c39f22f9a484ddb09ffc08662fef22c381fe2`.

The pose traversal now composes contracts for a single joint, a single body,
the processed body prefix and joint coverage. Motion copying specifies the
exact four replaced fields and preserves every other body field. Both
`Update_Poses` and `Ensure_Cartesian_Motion` close their existing public-state,
configuration and cache-validity guarantees. Separate postcondition clauses
retain the original conjunction while making diagnostics local.

Two representation requirements are explicit: each joint lies in its owner's
joint segment, and the allocated joint array has the canonical upper bound
`Nj - 1`, including the empty case. `First = 0` and `Length = 0` alone do not
imply `Last = -1` in Ada. The historical readiness equivalence lemma declares
this additional premise rather than claiming equivalence for noncanonical
states. Creation and the remaining lifecycle proofs still require closure.

Successful arithmetic expressions and their evaluation order are retained.
A failed build may leave different contents in invalidated private buffers;
the public state remains preserved by the specified failure contract. No
assumptions, trusted bodies or check suppressions were added to obtain proofs.

## Formal evidence

| Scope | Proof checks | Flow checks |
| --- | ---: | ---: |
| 21 pose-tree, copy and representation helpers | 285 | 44 |
| Complete `MJ.Smooth_Math` | 718 | 58 |
| Complete `MJ.Pose_Arithmetic` | 156 | 36 |
| Complete ghost `MJ.Tree_Error_Budgets` | 177 | 15 |
| Eight `MJ.Smooth_Dynamics` arithmetic helpers | 108 | 15 |
| `Update_Poses` | 133 | 11 |
| `Ensure_Cartesian_Motion` | 40 | 5 |
| **Disjoint total** | **1,617** | **184** |

No open checks or analysis errors remain in these runs. The motion caller has
one retained warning: the temporary joint array is written by the builder and
not subsequently used. Its runner status is `completed_with_warnings`, with
a nonzero exit code; this is explicitly distinguished from an unproved check.

The [evidence directory](../tests/tree_invariants/evidence) retains raw proof
logs and structured obligations, exact source objects indexed by hash, and a
continuity audit. Earlier helper snapshots differ only in the two pipeline
files: the proved helper text is unchanged, as are the other dependencies.
The final caller runs cover the changed callers. The external recovery package
also preserves unsuccessful and interrupted attempts; they are not counted.

These are modular proofs of the specified properties, using called contracts.
They do **not** establish complete-unit `MJ.Data.Pipeline`, whole-simulator Gold,
a complete functional model of ideal poses, or the remaining dynamics and
lifetime properties. Timeouts and missing invariants remain pending work,
not mathematical Silver exceptions.

## Numerical validation and error bounds

The final checked binary passes **624 scenarios and 168,192 scalar comparisons
per policy**, Compatible and Strict, on 26 models, with `atol = rtol = 2e-10`.
Seven normalization edge cases and 14 status/policy cases also pass; the policy
edge suite explicitly uses Strict in both invocations. Refusals include public
state preservation. The probe SHA-256 is
`5977fcad106ce619c7fb4861572a7a641e4cc686127983f004d7d5af5d7d19c3`.
The build receipt links these reused-probe tests to the exact source and checked
compiler project; tests are not universal equivalence proofs.

Six Gappa certificates and ten SMT checks were replayed successfully. The
[accepted-product derivation](../tests/tree_invariants/numerical/accepted-product.md)
uses the existing acceptance threshold to remove the earlier extra lower bound
on the factor norm. The directional bound `512 u m`, with `u = 2^-53`, is relative
to exact normalizations of the factors actually supplied by the program.
Trigonometric and model-input errors remain separate terms, and radial error
is treated separately. The local certificates, documented geometric argument
and conditional ghost induction are not an automatically verified translation
from the full simulator to a real-arithmetic model. See the derivation for the
binary64, rounding, subnormal, square-root and evaluation-order assumptions.

## Full-step performance

Two independent sessions use 24 balanced process-order blocks each, 11 models,
three states per model, CPU affinity 12, four measured samples of 100 steps and
two warmups per process. No proofs or builds ran concurrently. The final runs
contain **4,752 timed processes and 1,900,800 measured steps**; every measured
result was compared numerically. Maximum observed absolute error against C was
`3.8913317013111737e-14`.

The frozen prior Ada and current Ada use identical optimized build flags;
the C executable and library hashes are pinned in the build receipt. An initial
six-block pilot suggested a 1–4% refactoring cost. Inlining `Fixed_Position`
eliminated the extra call and reduced the compiled traversal without removing
checks or changing arithmetic. Only the two full sessions below support the
final comparison.

Positive percentages mean less elapsed time than the prior Ada implementation.
Ranges span the three states and both sessions.

| Model | Time reduction vs prior Ada | Current / C |
| --- | ---: | ---: |
| `hinge_motor` | 1.5–2.3% | 1.43–1.44x |
| `branched_multijoint` | -0.1–1.3% | 1.77–1.80x |
| `chain_12` | 0.6–2.1% | 2.23–2.26x |
| `crb_no_damping` | -0.6–1.0% | 2.28–2.32x |
| `crb_chain_24` | -0.4–0.9% | 2.19–2.21x |
| `ancestor_star_24` | -1.2–-0.3% | 2.96–2.97x |
| `ancestor_forest_24` | -1.5–-0.1% | 2.55–2.62x |
| `ancestor_branches_24` | -0.8–0.2% | 2.56–2.57x |
| `simple_hinges_6` | 1.1–1.7% | 2.97–3.01x |
| `simple_sliders_6` | -1.2–-0.7% | 1.95–1.96x |
| `simple_mixed_8` | 1.5–3.0% | 1.94–1.96x |

The equal-weight geometric mean of the 33 current/prior ratios is **0.99519**
and **0.99553**, about 0.48% and 0.45% less time. This is a balanced suite summary,
not a measured distribution of the user's workload. Some case medians are
slower by up to 1.5%; no same case has its entire 95% interval above parity in
both sessions. Ten cases have intervals below parity in both sessions.
Intervals are within-session paired bootstraps, unadjusted for multiplicity.
This evidence neither rules out all regressions nor establishes parity with C:
the measured remaining C gap is **1.43–3.01x**.

## Reproduction

Proofs use GNAT/GNATprove 16.1. Start with the smallest subprogram or assertion;
use `--steps 0` explicitly. A selector that emits no proof checks is not a pass.
Exact prover commands and source hashes are retained in `evidence/proofs.zip`.

```sh
python experimental/smooth/tools/prove_fragments.py \
  --repo "$PWD" --report-dir /tmp/tree-motion-new \
  --toolchain-root /path/to/toolchains \
  --unit mj-data-pipeline.adb --name Ensure_Cartesian_Motion \
  --provers cvc5,z3,altergo --steps 0 --prover-seconds 20 \
  --prover-mb 800 --jobs 2 --wall-seconds 420 --total-seconds 450

python experimental/smooth/tools/compare_numerics.py \
  --repo "$PWD" --report-dir /tmp/tree-numeric-new \
  --toolchain-root /path/to/toolchains --samples 24 --policy Strict \
  --extra-fixtures tests/tree_invariants/fixtures
```

Use Python with `mujoco==3.14.0` and NumPy for numerical comparisons. The
mathematical replays are `tests/tree_invariants/numerical/check.py` and
`accepted-product.py`, with Gappa and Z3 paths supplied explicitly.

The [performance experiment](../tests/movement_performance/tree_proof) retains
the frozen prior sources, builder, exact build receipt, summary, timings and
numerical outputs. Build with `build.py --out ... --toolchain-root ...
--reference-build ...`, pointing to a verified C build receipt, then run the
existing `tests/movement_performance/c_parity_six/compare.py` with the new build
and a new output directory. Run repeated sessions sequentially, without prover
or compiler load, and retain their individual confidence intervals.
