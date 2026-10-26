# Checked row windows and explicit coefficient domains

The working packed-row update now passes a single checked constrained array
formal with origin zero. Ordinary Ada parameter sliding avoids widened vector
index arithmetic; there are no pointers, unchecked conversions, copies,
suppressed checks or assumptions. Original generic origins/counts, ordered
floating expression, complete rejection predicate and untouched frame remain.
Scale input/output and row coefficients use base Real with their original
admitted ranges as explicit proved Pre/Post. The local solver coefficient also
uses Real so an automatic constraint check is not merely moved to that local.
The inverse subtype, pivot behavior, deallocators and backend threshold remain.

Proof diagnosis starts with scalar and nested helper minima, then the wrapper,
whole kernel and solver caller. Fresh exact C3.14 and C3.17 closures each close
all222 whole-kernel checks and86 checks of Solve_Compatible_Buffers. The latter
is a subprogram minimum, not a complete inertia-phase proof or a global L'DL
functional theorem. Four inherited kernel and twelve inherited caller warnings
remain separate from closed obligations; strict warning-free passed is false.
The previous kernel had five warnings. Replacing its source-index expression
removes one reassociation warning; the four retained warnings match exact new
lines. The original fresh gate rejected the successful222-check reports because
it expected five warnings. That failed driver and completed reports are retained;
the correction validates the exact diagnostic delta and completes caller proofs.
Earlier private timing qualification text saying five warnings is obsolete.

All14 numerical groups pass on the supported reference closures. Both checked
and release profiles pass6140 exact native C scalar-multiplication bit cases and
59621 exact row/frame/rejection cases, including high origins,65535/65536 and
numeric limits. The initial input-only Scale trial did not establish a gain;
the complete scalar chain showed only partial confirmation. Neither precursor
was independently adopted. Failed flow attempts and their ghost correction
are preserved without narrowing the runtime domain.

Three six-copy integrated comparisons use the latest adopted external-load
baseline, normal native C3.17 SIMD/LTO and matching floating flags: nine targeted
scenarios, an independent three-state chain24 repeat, and all30 supported
movement scenarios. Every numeric endpoint passes. All nine chain24 state/run
estimates take about1.7-2.6% less time, each95% interval below one. Full-run
chain24 takes about2.4-2.6% less time and remains2.01-2.04 times C's time.
Other workload intervals often include no change; no slowdown is confirmed.
There is no unweighted aggregate, every-case gain or C-parity claim. Fixtures
include applied body loads; a separate no-body-load timing claim is not made.

The actual final timed binaries retain YMM multiplication/addition and remove
four vector-index widening sites in Add_Long_Row. All call sites in this helper
are ordinary language-check handlers; no data-copy/allocation call appears.
The new diagnostic instruction count excludes objdump byte continuation lines;
older precursor counts included those lines. Counts do not establish speedup.
Pinned C mj_factorI and its AVX row update use the same packed row operation.

Fresh actual working manifests exactly match the verified C3.14/C3.17 sources.
Full port, whole dynamics Gold, coordinated production migration and overall
C parity remain unfinished. Production is still pinned to3.14. This adoption
remains local, with no new commit/push. Restore row-window.zip with
tools/evidence_store.py restore using its repository-relative path.
