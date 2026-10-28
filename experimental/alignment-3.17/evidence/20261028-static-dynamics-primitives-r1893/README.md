# Static bounds in dynamics primitives

The adopted incremental change replaces 29 temporary subtype constraints with
proved Static assertions in ten Smooth_Dynamics bodies. Two private scalar
helpers also replace their return subtypes with explicit proved range
postconditions and Static result checks. All public signatures, return subtypes,
contracts and required input domains remain unchanged. The exact inverse-edit
audit reconstructs the original file and proves that no other numerical body
or public specification changed. Expressions and floating-point evaluation
order are preserved. No assumption, suppressed check, new trusted port body or
forced inline directive is introduced.

Each of the ten scoped bodies closes on both reference source closures, with
zero warnings: Config_Dot18, Apply_Config17, Cross_Component12, Cross_Local17,
Cross_Transport17, Dot_Motion16, Center_Acceleration35, Mass_Contribution25,
Prepared_Mass_Contribution21 and Bias_Contribution17. Counts describe separate
scopes and are not added into a whole-unit claim. Complete Smooth_Dynamics
attempts retain their actual outcomes in summary.json; neither the scope proofs
nor the numerical tests establish complete state/dynamics/factorization Gold.

Both standard profiles/reference closures pass the existing activation and
supported integration suites. The exact-bit harness passes 34,304 cases per
build in eight profile/reference/role builds. It calls actual public operations
on full-domain extremes, signed zeros, subnormals and deterministic random data;
inputs travel as integer bits. Native C directly checks the four elementary
operations; composites compare actual baseline outputs rather than a mirrored
formula. Test-only unchecked conversions remain outside the port. All 30 actual
movement endpoints equal previous Ada and satisfy the unchanged native C oracle.

The baseline is the locally adopted1838 math optimization, not the older1319
checkpoint. Strict release flags and native C3.17 SIMD/LTO remain unchanged.
Six-replica full30 timing ran with this task's other heavy jobs idle. The new
incremental gain is0.91–1.26 percent on chain_24,1.74–2.09 percent on branches_24
and5.32–6.19 percent on free, with each per-state95-percent interval below
previous Ada. Ball and free_ball have lower medians but intervals include parity;
those apparent gains are inconclusive. No final case has an interval wholly
above previous Ada. Raw timings, same-code replicas and uncertainty are retained;
no percentage average or faster-case count is an acceptance metric. Direct
Ada/C medians remain1.75–1.76 on chain_24,1.37–1.38 on branches_24 and about1.21
on free. These results justify incremental local adoption, not C parity.

The first audit script failed because substring counting confused Y and XY;
the corrected exact-name audit passes. That failure and the source-bound proof
receipts are retained. Full-port features, coordinated latest ABI migration,
whole state/dynamics/factorization Gold and C parity remain open. The current
math gains remain adopted. A refreshed flat PC profile on chain_24 state0 is archived, and all10,000
profiled endpoints per role equal the uninstrumented result. Many timer overruns
limit precision: the received-sample fractions identify candidate functions,
not exact phase costs or causal slowdown fractions. Current Solve_Acceleration
(external-force projection) is about20 percent of received PCs, the compatible
solver15 percent and Add_Long_Row11 percent. Inspect those guards and compact-row
paths against C before selecting further inertia work. Profile CPU/elapsed
values include instrumentation and are not replicated performance evidence. This work remains local, without an
additional commit or push. Restore the exact ZIP with tools/evidence_store.py.

The two hottest current PCs are inspected in solve-acceleration.asm and
profile-address-audit.json: they occur at the final range check after a
six-component external-force contribution. The enclosing function also includes
other inlined phases; its entire sample share is not assigned to those checks.
