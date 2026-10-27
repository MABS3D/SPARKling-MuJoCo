# Refreshed current-runtime PC profile, not acceptance timing

The same actual1171, adopted final1274 and normal native C3.17 binaries from the
combined acceptance runs are sampled independently on chain24/state0. Complete
main-thread timer metadata is checked. Each role passes10000 numeric endpoints
and exactly matches its own uninstrumented six-replica output. Binary/provider
hashes, maps, raw PC/timestamp data, symbolization and instruction windows remain.

Current self-sample shares are about19.4% in Solve_Acceleration,15.7% in
Solve_Compatible_Buffers,11.2% in Add_Long_Row,8.6% in compact Fill and7.4% in
Try_Recursive. C's top symbols include addToScl/factorI/jac/solveLD. These are
full-process sample fractions, including setup, output, signal overhead and
substantial timer overruns. Unknown locations remain explicit; repeated work may
alias the sampling schedule. Do not turn fractions or profiled elapsed times into
exact phase costs, causal speedups or parity evidence. Inlining changes symbol
ownership between binaries, so isolated parent/child symbols are not comparable.

Instruction windows identify retained Work_Real input conversions in the Add_Row
scalar loop inside Solve_Compatible_Buffers, alongside the integer rejection
counter. The referenced constant decodes to -1e60. The original Add_Row Pre
already bounds both operands; private1299 tests an identical base-Real expression
with those former bounds proved as Static facts. Its proof/build/numerical/timing
qualification is separate, not a result of this profile. No production code,
complete dynamics Gold, full port/migration or C-parity claim follows here.
Restore current-pc-profile.zip through tools/evidence_store.py.
