# Small, bounded proof jobs

`prove_fragments.py` runs GNATprove separately for each package-level subprogram
body and each expression-function body in the smooth draft. It does not change
the Ada sources, their contracts, or the main project's proof configuration.

By default each job selects one subprogram with `--limit-subp=file:line`.
GNATprove performs flow analysis and per-check proof at level 0, with a short
prover time and step budget. `--level`, `--provers`, `--jobs` and `--steps 0`
allow stronger budgets. These are effort settings, not SPARK assurance levels.
The repository's Linux watchdog bounds the whole job, including
frontend preparation, and cleans up only that job's process group. Jobs run
sequentially with one prover worker by default and a 2 GB memory cap.

The runner copies the source files into a temporary directory, records SHA-256
hashes, and generates small GPR projects containing each unit's local dependency
closure, including Ada separate subunits. Source units remain intact. This avoids repeatedly discovering the
entire main library when checking a small mathematical helper. These projects
use the draft's checked development compiler switches. They are diagnostic
projects, not a replacement for eventual verification of `smooth.gpr` itself.
Mathematical helpers have their own project/cache; runtime children share a
stable project/cache so their common dependencies are not rebuilt at every job.
The first job for each project receives a separate preparation allowance
(`--prepare-seconds`, default 60). Later jobs use the ordinary wall limit.
Before each job, the runner removes only previous `.spark` diagnostic records
and the aggregate summary in its own temporary project. Compiled contracts are
retained. This prevents an earlier fragment's failure from contaminating a later
fragment's exit code. The fresh structured diagnostics are archived per job.

From the repository root, list available fragments:

```sh
python3 experimental/smooth/tools/prove_fragments.py --list
```

Run a sweep, writing reports to a new directory:

```sh
python3 experimental/smooth/tools/prove_fragments.py \
  --report-dir /tmp/smooth-proof-results-1 \
  --wall-seconds 15 --total-seconds 600
```

If the native tools are not on `PATH`, add `--toolchain-root /path/to/toolchains`,
where that directory contains `gnat/`, `gprbuild/` and `gnatprove/`, each with its
versioned installation and `bin/` directory.

Repeat just one unit or subprogram with a fresh report directory:

```sh
python3 experimental/smooth/tools/prove_fragments.py \
  --report-dir /tmp/smooth-proof-dot-1 \
  --unit mj-smooth_math --match dot --wall-seconds 30
```

`--match` also accepts a fragment ID from `--list`, distinguishing overloaded
operators and normalization procedures. The default prover timeout is one
second per check and the default step limit is 200; use `--prover-seconds` and
`--steps` to investigate a specific inconclusive fragment with a larger budget.

Use repeatable exact names to check a chosen group on one immutable snapshot
and shared frontend cache, for example `--unit mj-data --name Set_State
--name Get_State --name Reset`. Names are case-insensitive; use `--list` first
to inspect the selection. `--name` cannot be combined with line or whole-unit
selectors. Each selected subprogram still gets its own bounded job and result.

For a subprogram that still times out, isolate an individual source line:

```sh
python3 experimental/smooth/tools/prove_fragments.py \
  --report-dir /tmp/smooth-proof-euler-line-1 \
  --line mj-data-euler.adb:32 --wall-seconds 15
```

Repeat `--line` to check several locations separately. Line numbers must refer
to the current source; use the report or the source file to select them. A line
without generated checks is reported as such, not as a proof of its function.

Reports are saved after every job:

- `report.md`: table of fragments, durations and selected diagnostics;
- `results.json`: all parsed diagnostics, commands, exit codes and statuses;
- `manifest.json`: source hashes, snapshot location and generated project text;
- `logs/`: complete output for each individual job.

`logs/` also contains each job's fresh `.spark.json` records and aggregate
summary, when generated. The table distinguishes proof-check counts from flow
diagnostics; a fragment with no generated proof checks is explicitly labelled.

Interpret statuses conservatively:

| Status | Meaning |
| --- | --- |
| `completed_no_unproved` | The selected analysis completed without reported unproved checks or warnings |
| `completed_no_proof_checks` | Completed without diagnostics, but generated no proof checks; inspect flow results and inlining |
| `completed_with_warnings` | Completed, but warnings still need examination |
| `unproved_checks` | Unproved checks or flow diagnostics were reported; inspect the log |
| `analysis_error` | The frontend/analysis reported an error |
| `preparation_timeout` | The budget expired before the flow/proof phase |
| `proof_timeout` | The budget expired after entering the flow/proof phase; not a pass or counterexample |
| `resource_blocked` / `resource_limit` | The machine or process could not stay within the resource policy |
| `tool_error` | Another nonzero tool exit; inspect the log |
| `not_run*` | No result; the sweep is still running or exhausted its budget |
| `interrupted` | The runner was interrupted during this job |

The table counts medium/high/low diagnostics separately from errors. A check
that the prover cannot discharge within 200 steps is not evidence of a concrete
runtime failure. A successful fragment is also not evidence that its callers
establish every contract or that the simulator is physically equivalent to
MuJoCo. Bounds, ownership, loop invariants, interprocedural integration and
numerical comparisons still require their own review.

## Whole-unit integration and numerical comparisons

After focused proofs, use `--whole-unit mj-smooth_math` to check the complete
unit and its contracts, without a line or subprogram filter. For example:

```sh
python3 experimental/smooth/tools/prove_fragments.py \
  --whole-unit mj-smooth_math --report-dir /tmp/smooth-math-unit-new \
  --provers altergo,cvc5 --level 2 --steps 0 --prover-seconds 5 \
  --jobs 2 --wall-seconds 600 --prepare-seconds 600 --total-seconds 610
```

Add `--toolchain-root` when needed. Whole-unit proof is stronger evidence than
combining isolated successes, but still depends on the recorded assumptions and
callee contracts. Do not call a timed-out run a pass.

`compare_numerics.py` builds a checked probe in its own immutable snapshot and
compares it with the official MuJoCo 3.14.0 C library. See
[verification scope](../verification.md) for the command, fixtures, tolerances
and boundaries. The numerical report is independent of GNATprove results.

### Focused proof diagnostics

`prove_fragments.py --proof-mode progressive` enables progressive splitting;
the default remains `per_check`. The mode is recorded with the commands and
source hashes. Prefer `--name` for a subprogram's postconditions: a specification
line may select no generated obligation, even when its body is analyzed.
A run reporting `completed_no_proof_checks` now exits nonzero. A zero exit status
requires every selected target to complete with proof checks and none unproved.
