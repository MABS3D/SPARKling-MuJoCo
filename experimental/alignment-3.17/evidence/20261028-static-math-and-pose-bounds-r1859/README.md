# Proved static math bounds and pose-bound prototypes

The adopted local change removes 63 redundant subtype checks from temporary
values in Apply, Apply_Transpose, Multiply and Rotation. Every original bound
remains an explicit proved Static assertion. Public preconditions/postconditions,
input domains, expressions and floating-point evaluation order are unchanged.
An exact inverse-edit audit recovers the previous file; no assumptions, suppressed
checks, new trusted port bodies or forced inline directives are introduced.

Apply and Apply_Transpose each close 68 checks; Multiply closes 116 on each
reference closure. Rotation closes 157 in the isolated1821 source; that proof is
reused only after checking its exact body, types and public dependent contracts.
The ten existing unrelated elementary-math warnings remain visible. Counts are
separate scopes, not additive. Complete-unit attempts retain their actual
results in summary.json; they do not establish whole Smooth_Math completion.

Both standard profiles and both reference closures pass the existing activation
and supported integration suites. All 30 movement endpoints equal published Ada
exactly and match native C with unchanged2e-10 tolerance. The new three-operation
bit corpus passes 31,776 admitted extreme/random cases per each of eight
profile/reference/role builds, including signed zeros and subnormals. The test
transports input bits as integers after exposing decimal-parser rounding on
subnormal values; original failed harness attempts are retained. Test-only
unchecked conversions are outside the port. The separate Rotation corpus passes
14,927 cases in eight profiles; native C numerical comparisons use2e-15.

The first Rotation-only full30 six-replica run improves ball, leaves other gains
uncertain and has a hinge-state regression interval; it was not adopted alone.
The final combined change improves chain_24 by3.65–3.88 percent and branches_24
by5.29–5.65 percent, with all three per-state95-percent intervals below parity
against previous Ada. Free_ball improves2.38–2.91 percent beyond its uncertainty.
Other lower medians with intervals crossing parity are not established speedups.
No final case has an interval wholly above previous Ada. C remains faster:
chain_24 takes about1.77x native C time and branches_24 about1.40x. All raw
measurements, same-code replicas, uncertainty and exact source/binary bindings
are preserved. Timing ran with this task's other heavy jobs idle. No unweighted
percentage average or faster-case count is used as an acceptance metric.

Separately, the private Pose_Bounds unit proves146 checks on both references.
It bounds the exact rounded position increments using power-of-two budgets.
Pose_Rounding proves34 checks on3.17 using the existing reviewed SPARK
Long_Float_Arithmetic lemma boundary; no fresh Coq replay is claimed. Its small
lemmas show that adding a bounded pose offset to a Work-bounded coordinate cannot
escape Work under the actual rounded expression. The complete pose-frame kernel
still times out; its short diagnostic retains open obligations. Capture/expose
position lemmas close8 checks each, but do not close the kernel. The global pose
producer budget and removal of the Jacobian/external-force scans are unfinished.
None of these pose prototypes is adopted into production.

Whole state/dynamics/factorization Gold, coordinated latest ABI migration, full
feature coverage and C performance parity remain open. This checkpoint and the
math implementation are local; no additional commit/push is performed. Restore
the exact ZIP through tools/evidence_store.py when needed.
