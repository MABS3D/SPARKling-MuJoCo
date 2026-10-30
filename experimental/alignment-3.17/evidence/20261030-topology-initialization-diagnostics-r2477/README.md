# Explicit initialization diagnostics for Arms

The final Initialized assertion and both initialization/preservation obligations
of the Initialized loop invariant are proved in separate selected-line3.17
reports. The latter has3 proof checks, while the final assertion has1. Their
explicit layout/input assumptions and earlier check cuts remain part of scope;
this is not a complete builder runtime-safety or functional proof. No zero-fill
pass is added, and the Relaxed_Initialization prototype is not adopted.

An earlier filter selected the pragma line and generated0 proof checks. Its
report is retained as a mis-scoped diagnostic, never as proof of the invariant.
The corrected filter selects the quantified expression. Exact source closure
and the first assertion report are in the verified parent archive referenced
by context.json; the new report, log, runner and complete scoped Spark JSON are
preserved here. Whole constructor/state proofs and C performance parity remain
open. No commit or push is performed.
