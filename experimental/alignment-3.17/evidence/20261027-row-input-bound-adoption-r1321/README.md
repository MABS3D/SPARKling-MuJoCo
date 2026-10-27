# Locally adopted proved Add_Row input-bound elision

The sole runtime owner is Solver_Kernels.adb. Add_Row replaces the checked
Add_Product runtime call with the identical Previous + Operand * Multiplier
expression on base Real values. Former operand/result bounds and exact equality
to the unchanged typed Add_Product model are proved Static facts. All public
specifications, admitted/null/nonzero-origin domains, full-row rejection, source
preservation and existing integer reduction/compiler workaround remain. No new
threshold, forced inline, pointer cast, assumption or suppression is introduced.

Both references close Add_Row37, whole kernel231 and actual solver CALLER
MINIMUM86. C17 Add_Prefix_Row14 also closes. Counts are not additive. Four kernel
and twelve caller warnings match prior diagnostics and identical source statements.
Generic runners report passed=false solely from their strict warning gate; complete
coverage, no open obligations and obligations_closed are reviewed explicitly.
The caller scope preserves safety/bounds and the clamp diagnostic; it does not
prove global factorization equations or close the entire inertia phase.

Both-reference/profile activation432 and integration1152 suites and all14 numerical
groups pass. The unchanged checked/release row corpus covers66306 cases per profile,
including every rejected SIMD/tail lane and maximum coefficients. New baseline/
candidate native-C comparisons cover7374 cases per role/profile: all output bits,
original rejection predicate and unchanged source bits must match, with null and
near-max/nonzero origins, signed zero, subnormal, cancellation and extreme inputs.
Test-only bit transport is outside production/proof trust. Normal strict release
flags and the existing per-file solver256 preference are retained; client inlining
uses ordinary native width as in production. Cases are not universal C equivalence.

Target9, independent repeat9 and full30 use six identical executable replicas per
role, balanced orders and normal native C3.17 SIMD/LTO. All numeric endpoints pass.
All nine chain24 state/run intervals are below1: targeted/repeat gains1.6-1.8%, full
run1.3-1.5%. Full-run ball medians are1.6-1.8% slower, with intervals above1. An
additional independent ball/spatial_ball followup6 has ball medians near unchanged
and intervals including1. The original regression is retained, not erased or
proved impossible. Other model uncertainties remain; no unweighted percentage
average or universal absence-of-regressions claim follows. Full-run chain time is
still1.82 times C; ball is1.24-1.26 times C in the full/dedicated measurements.

The actual owner is adopted only after these gates. Fresh actual C14/C17 sources
match qualified1299 contents completely; manifest ordering is normalized only
after every digest is checked. All eight Direct, eighteen Compact and twelve RNE
transitive source inputs remain identical to actual1294, with explicit bindings
for prior122/501/163 proofs. Full project manifests differ across the unrelated
solver-body delta and are not called identical for that reuse. Whole dynamics
Gold, full port/latest-engine migration and global C parity remain unfinished.
No commit or push is performed. Restore row-input-bound-adoption.zip through
tools/evidence_store.py.
