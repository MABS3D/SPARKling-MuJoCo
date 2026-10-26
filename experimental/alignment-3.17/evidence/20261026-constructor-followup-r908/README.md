# Private constructor follow-up

This follows the row-domain894 checkpoint. The905 constructor minimum completes
with the preserved report in summary.json. The body-frame invariant now closes
both initialization and preservation, using the previously proved two-field
setter, transitivity and array reflexivity helpers. Remaining obligations are
explicit; neither the constructor nor the whole parent Data unit is verified.
Semantic proof/flow counts exclude compiler informational loop-unrolling notes.

The906 source compares component lengths in Int64, preserving the full original
array/model domain while avoiding an implicit Natural conversion in pre/post
expressions. It is prepared only: a fresh minimum and caller chain remain to be
proved, followed by current-source C3.14/C3.17 validation/release numerical gates.
These private constructors are not part of the adopted runtime. No new public
filter, runtime scan, assumption, suppression or deallocator change is introduced.
All included jobs are terminal. Generated analysis caches are excluded; frozen
inputs, copied complete reports, logs and exact raw result counters are retained.
No commit or push is performed. Full port, whole dynamics Gold and C parity remain
unfinished. Restore constructor-followup.zip with tools/evidence_store.py restore.
