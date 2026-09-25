# Rejected Inline_Always probe

Only the public Transpose declaration adds Inline_Always; production sources
were never changed by this experiment. The dispatcher diagnostic proves 16
checks, and the native numeric probe passes 535 full-operation cases / 544,872
comparisons plus 40 transpose cases / 151,125 comparisons.

Twenty-two timing cases compare this variant directly against the retained
candidate, not against the published baseline. There are five improvements,
four slowdowns and thirteen inconclusive comparisons. Although 3x3 improves
about 36%, 4x4 costs about 24% more and 5x32 about 20% more. The empty-case
issue is not resolved. The variant is rejected; favorable cases do not cancel
those regressions.

Raw timing, diagnostic and build logs, generated source snapshot and its hashes
are preserved here. This is a small-subprogram diagnostic, not a complete-unit
proof receipt. Reproduction uses the parent standalone.gpr recipe and the
original workspace paths in proof.gpr/checks.gpr. No executable is stored.
