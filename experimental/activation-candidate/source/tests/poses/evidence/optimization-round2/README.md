# Pose optimization follow-up — 2026-09-24

Baseline: commit `2c26e49b`, saved executable `baseline-main`, SHA-256
`7464724b9dad1f4b90c05134b430d969fd54d8b87bc2d2cba73e08b9fc01d21c`.
**No production optimization was accepted in this round.** Six source variants
were measured, two further source prototypes failed focused proof diagnostics,
and one compiler-flag probe produced no useful code-generation change. The
production sources and release flags were restored; the rebuilt executable is
byte-for-byte identical to the baseline hash above. The existing 694 proved /
zero unproved complete-unit receipts still match the restored source files.
They are existing baseline evidence, not new proof runs for the rejected variants.

## Baseline replication

[The baseline repeat](baseline-repeat.json) measured ten selected cases with
31 alternating C/Ada pairs and a 40 ms CPU-time target. This is a focused repeat,
not a replacement for the historical 70-case benchmark. Five selected cases
remain slower, four are inconclusive, and one is faster.

Two of the seven historical slowdown flags were **not confirmed in this session**:

| Case | Ada/C median | Individual 95% interval | Interpretation |
|---|---:|---:|---|
| Compose in-place, nonunit quaternion (4) | 1.0020 | 0.9906–1.0093 | Inconclusive; previous small slowdown not confirmed |
| Transform, tiny quaternion (5) | 1.0070 | 0.9995–1.0203 | Inconclusive; previous small slowdown not confirmed |

The other five historical flags persist in the focused repeat: compose in-place
tiny **+1.31%**; Transform general **+1.13%**, nonunit **+1.60%**, Tier0 extremes
**+0.94%**, and zero point/translation **+1.42%**. Their individual intervals
exclude parity in this session. These results support further investigation;
they neither establish an arbitrary 1.5% noise threshold nor prove that the two
inconclusive cases meet parity.

## Same-executable control and remaining priorities

[The A/A control](baseline-control.json) ran the **same immutable baseline
executable in both build slots**, with 32 balanced four-treatment blocks per
case and a 30 ms CPU-time target. All ten Ada/Ada and all ten C/C individual
CPU-time intervals include 1. No difference between the build slots was detected.
This is a useful sanity check, not proof that this benchmark detects every 1%
change or that an Ada/C interval containing 1 establishes equivalence.

The two interleaved Ada/C sample groups from that same executable are shown
separately; neither is selected as the preferred result.

| Case | Ada/C, baseline-labelled group | Ada/C, candidate-labelled group |
|---|---:|---:|
| Compose in-place, nonunit (4) | 1.0085 [0.9917, 1.0147] | 1.0053 [0.9874, 1.0215] |
| Compose in-place, tiny (5) | 1.0091 [1.0024, 1.0154] | 1.0058 [1.0023, 1.0154] |
| Transform, general (0) | 1.0061 [0.9979, 1.0113] | 1.0149 [1.0061, 1.0222] |
| Transform, nonunit (4) | 1.0081 [1.0034, 1.0169] | 1.0132 [1.0048, 1.0238] |
| Transform, tiny (5) | 1.0032 [0.9916, 1.0110] | 1.0003 [0.9951, 1.0073] |
| Transform, Tier0 limits (6) | 1.0122 [1.0064, 1.0164] | 1.0161 [1.0083, 1.0211] |
| Transform, zero point/translation (7) | 1.0106 [1.0025, 1.0219] | 1.0075 [0.9977, 1.0145] |
| Transform in-place, general (0) | 0.8355 [0.8310, 0.8404] | 0.8400 [0.8331, 0.8487] |
| Inverse in-place, general (0) | 0.7519 [0.7458, 0.7578] | 0.7498 [0.7473, 0.7546] |
| Transform, identity (1) | 0.8269 [0.8192, 0.8363] | 0.8337 [0.8272, 0.8355] |

The strongest repeated slowdown evidence concerns **tiny Compose in-place,
nonunit Transform and Tier0-limit Transform**: their intervals exclude parity
in the historical run, focused repeat and both control groups. General Transform
and zero-point Transform remain borderline: their classification changes between
the two interleaved control groups even though the executable is identical.
Nonunit Compose in-place and tiny Transform are inconclusive in both new
sessions. None of the seven historical flags is declared fixed.

The favorable controls remain substantial: general Transform in-place takes
about **16% less time**, and general Inverse in-place about **25% less time**,
than C. These are per-case time reductions, not aggregate workload speedups.
The focused ten-case sessions do not replace the original 70-case reference.

## Completed candidate screenings

Unless stated otherwise, screenings used 11 alternating pairs per case and a
25 ms CPU-time target. Ratios in this table are **candidate Ada / C in its own
executable**, not a direct comparison with baseline Ada. Each of these six
screened candidates passed the release numerical suite: 9,404 inputs and
357,352 finite scalar comparisons, with anchors, in-place consistency and input
frame checks. Signed-zero bit equality is outside that numerical claim.
The listed focused proof logs are diagnostics, not fresh complete-unit receipts.

| Candidate | Purpose | Focused proof / measured evidence | Decision |
|---|---|---|---|
| `guard321` | Reverse the scalar-quaternion guard from component order 1–2–3 to 3–2–1, testing branch/load scheduling. | [Transform diagnostics](proof-guard321.log); [16 cases](guard321-performance.json). Transform general 1.0267 [1.0134, 1.0346]; nonunit 1.0172 [1.0045, 1.0402]. | Reject for promotion: target slowdowns remain; no confirmed baseline improvement. |
| `position-first` | Compute translated position before quaternion multiplication/normalization in Compose. | [Compose diagnostics](proof-position-first.log); [16 cases](position-first-performance.json). Nonunit Compose 1.3031 [1.2306, 1.3535]; in-place 1.2893 [1.2752, 1.3129]. | Reject: large regressions against C on nonunit composition. |
| `q-snapshot` | Give Transform a local quaternion snapshot to change load scheduling. | [Transform diagnostics](proof-q-snapshot.log); [8 cases](q-snapshot-performance.json). Tiny Transform 1.0487 [1.0127, 1.0857]; general result inconclusive, 1.0314 [0.9945, 1.0753]. | Reject for promotion: no confirmed gain and an adverse tiny-case signal. |
| `vector-norm` | Implement Norm through the existing proved Squared_Norm helper, encouraging packed square operations while retaining reduction order. | [Squared_Norm/Norm diagnostics](proof-vector-norm.log); [12-case screening](vector-norm-performance.json), followed by the direct four-treatment comparison below. | Reject: direct comparison confirms substantial tiny-input regressions. |
| `deferred-q` | Normalize a local result quaternion and defer its output store until after Transform. | [Compose diagnostics](proof-deferred-q.log); [16 cases](deferred-q-performance.json). General Compose 1.0464 [1.0353, 1.0720]; nonunit 1.0281 [1.0072, 1.0389]; tiny in-place 1.0223 [1.0053, 1.0375]. | Reject: does not resolve the tiny in-place deficit and introduces adverse composition signals. |
| `point-snapshot` | Give Transform a local point snapshot to influence load scheduling. | [Transform diagnostics](proof-point-snapshot.log); [8 cases](point-snapshot-performance.json). General Transform 1.0085 [0.9740, 1.0236], nonunit 1.0117 [0.9791, 1.0249]. | Do not promote: broad intervals and no demonstrated improvement over baseline; fewer slowdown flags alone are insufficient. |
| `zero-point` | Return Position directly for a zero Point, subject to equality with the existing ordered floating-point model. | [Small lemma diagnostic](proof-zero-point-lemma.log): three intermediate-zero assertions and two final-coordinate assertions proved; the third final-coordinate assertion hit prover limits. | Not accepted and **not benchmarked**. This is unfinished proof engineering, not a mathematical exception or a reason to weaken Gold. |

The two unmeasured source prototypes were rejected before timing:

- `zero-point` also left the quantified result postcondition unproved; no
  exception to Gold was introduced.
- `w-one` split Transform into a private general helper and a public branch for
  a quaternion scalar component equal to one. The private helper's postcondition
  hit the prover time limit ([diagnostic](proof-w-one.log)); generated code also
  added loads and eagerly computed arithmetic before the guards. This prototype
  was **not benchmarked** and was not accepted.

A separate build-only probe used `-fno-signed-zeros` for both Ada and C and the
LTO link ([invocation](no-signed-zero-build.json)). Its release numerical suite
passed, but normalized instructions in the relevant Transform and Compose hot
loops were unchanged, including the square-root zero check. It was not timed;
no build-flag change was adopted. The [restoration build](restored-build.log)
used the original release settings.

Candidate source snapshots, build logs, release numerical logs and raw timing
samples are retained beside this report. Full experimental executables and
full disassemblies remain local in the task's `work/poses-round2` directory;
they are not part of this repository evidence package. Binary hashes bind the
recorded comparisons. Screenings and focused proof diagnostics do not confer
complete-unit Gold status on rejected variants.

## Direct confirmation: vector-norm

[The four-treatment comparison](vector-norm-comparison.json) used the immutable
baseline and candidate executables, 16 balanced blocks per case, 25 ms target,
and identical repetition counts across baseline C/Ada and candidate C/Ada.
Treatment order rotates through a Williams design; all raw samples are retained.

| Case | Candidate Ada / baseline Ada | Individual 95% interval | Candidate C / baseline C |
|---|---:|---:|---:|
| Compose, tiny (5) | **1.2209** | **1.1850–1.2473** | 1.0008 [0.9969, 1.0316] |
| Compose in-place, tiny (5) | **1.1044** | **1.0958–1.1152** | 0.9948 [0.9832, 1.0071] |
| Compose, nonunit (4) | 0.9957 | 0.9736–1.0022 | 1.0004 [0.9836, 1.0120] |
| Compose in-place, nonunit (4) | 0.9896 | 0.9719–1.0160 | 1.0027 [0.9909, 1.0212] |

The tiny-input Ada regressions are approximately **22.1%** and **10.4%** versus
baseline Ada. All four C-control intervals include parity; no corresponding C
shift was detected. The nonunit Ada comparisons remain inconclusive. This
direct comparison is stronger rejection evidence than an isolated candidate/C
screening ratio or an assembly instruction count.

## Interpretation and acceptance limits

- The percentile-bootstrap intervals describe the within-session median of
  paired ratios. They are individual per-case intervals, without correction for
  multiple comparisons; they do not cover independent-session drift or prove
  equivalence when they include 1. Do not cherry-pick the interval or session
  with the preferred classification.
- CPU pinning and balanced order reduce some noise. WSL host scheduling,
  frequency, cache state and code layout can still matter at the 1% scale.
  Switch counts include preparation/checksum as well as timed work, so they
  cannot identify exactly which timed batches were interrupted. Retain both
  CPU and wall measurements and all samples rather than filtering by outcome.
- Candidate changes can alter C code layout in a linked binary even when C
  source is unchanged. The direct comparison therefore reports candidate C /
  baseline C alongside both Ada/C ratios and candidate Ada / baseline Ada.
- Fewer instructions, extra SIMD instructions or fewer loads are hypotheses for
  improvement, not measurements of execution time. Dependencies, instruction
  scheduling, branches and memory behavior determine whether the change helps.
- The historical baseline already has material favorable cases, including about
  **16.2% less time for general Transform in-place** and **25.1% less time for
  general inverse in-place**. Preserve these gains. The historical 43 faster /
  20 inconclusive / 7 slower count is not a workload speedup; do not add or
  average unweighted percentage gains to offset a slower operation. An end-to-end
  claim requires representative operation frequencies and measured integration.
- The acceptance target remains Gold plus parity within measured uncertainty
  against normal MuJoCo C SIMD. No arbitrary slowdown allowance, weakened
  contract, new trusted body or assumption is introduced by this investigation.
  Fresh full-unit verification and a complete performance regression run are
  required before promoting an eventual candidate.

## Reusable comparison and reproduction

[compare_builds.py](../../compare_builds.py) is the reusable confirmation tool.
It compares candidate Ada directly with baseline Ada, retains both Ada/C
comparisons and uses candidate C/baseline C as an additional control. Position
and adjacent-treatment order are balanced in groups of four blocks. Raw samples,
CPU and wall clocks, context switches, checksums, treatment order, seed and
binary/script hashes are retained; incomplete runs are marked explicitly.
The exact earlier script used for the vector-norm comparison is preserved as
[compare_builds-v1.py](compare_builds-v1.py); its hash matches that result.

From the project root, after building and saving immutable release executables
and passing focused proofs and numerical checks for a candidate:

```sh
python3 tests/poses/compare_builds.py \
  --baseline /absolute/path/baseline-main \
  --candidate /absolute/path/candidate-main \
  --cases 2:4,2:5,5:0,5:4,5:5,5:6,5:7,6:0,4:0,5:1 \
  --pairs 32 --ms 30 --cpu 0 --seed 20260925 \
  --output /absolute/path/comparison.json
```

Choose an allowed CPU on the host. Omit `--cases` to cover all 70 cases.
For the same-executable control, supply the baseline path to both binary options.
Exit status 2 means a completed run detected at least one candidate Ada/C
slowdown; consult `complete` and `error` in the JSON to distinguish execution
failure. This comparator records executable hashes, not the source/build recipe
for each executable; retain those separately as in the screening artifacts.
Binary timing checksums are a guard against mismatched workloads, not a
substitute for the numerical differential suite.

[summary.json](summary.json) records the final restoration checks and decisions.
The performance gate remains **OPEN**; this round strengthens the evidence and
rejects unsuccessful alternatives without replacing the best verified kernel.
