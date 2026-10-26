# Locally adopted proved static bounds for spatial Dot

The six Dot products now use base Real constants. Their former subtype limits
are retained as Static assertions, proved from the original complete input Pre.
Original API, Pre/Post, output bound, admitted domains and exact floating-point
addition tree are unchanged. The tree matches the actual C3.17 mji_dot6 source.
Contract-respecting calls retain the former intermediate bounds; invalid calls
outside Pre do not inherit a claim of identical old subtype-exception behavior.
No assumption, suppression, new inline directive or other private candidate is
included. Other spatial product helpers and reviewed deallocators are unchanged.

Both references independently close Dot39, Spatial_Kernels whole459, immediate
Projected9, Assemble_Row37 and Compact_Inertia whole377 semantic checks. Counts
are not additive. Spatial math is warning-free; the compact unit retains six
reviewed warnings on unchanged declarations/bodies. Initial low-resource Dot
return-bound and compact Assemble_Row postcondition timeouts are preserved.
More resources/per_path close them on the same sources. The whole compact runs
report success for all377 obligations, despite generic runner passed=false and
exit1 from its strict warning gate. obligations_closed=true, complete SPARK
coverage and no open obligations are verified explicitly; warnings are retained.

Both profiles/references pass the13 broader numerical groups: raw mass and
derivatives, C17 reverse-layout derivatives, compact cache, direct CRB and exact
Dot bits. Additional existing activation432 and integration1152 scenarios pass
per profile/reference.6720 scalar cases per role/profile match native C3.17
mju_dot(n=6), including signed zero, subnormal, extrema and cancellation inputs.
Test-only unchecked bit transport is outside production/proof trust. These tests
do not prove universal C equivalence or real-arithmetic error bounds.

Targeted9, independent chain3 and full30 supported movement scenarios use six
identical replicas per role, balanced orders, common fixtures, normal native
C3.17 SIMD/LTO and strict matched FP. All numeric endpoints pass. All nine
chain24 state/run estimates have95% intervals below1, with about1.4-2.2% less
time than actual893. Full-run chain24 still takes about1.90-1.91 times C's time.
Free_ball improves about3.1-3.9% in the full run, while targeted intervals include
no change; that result is not presented as independently replicated. No interval
proves a slowdown, but wide intervals on other models do not guarantee absence
of regressions. No unweighted aggregate speedup or overall C-parity claim follows.
Static compact-fill FP comparison sites fall50 to38; timing evidence is separate.

The single owner is locally adopted as1171 only after proof, numeric and timing
gates pass. Fresh actual C14/C17 source manifests exactly equal verified frozen
manifests. The previous893 solver implementation is retained. No commit or push
is performed. Complete port, full dynamics Gold, coordinated engine migration
and overall C performance parity remain unfinished. Restore spatial-dot-adoption.zip
through tools/evidence_store.py. Every failed budget and raw control is retained.
