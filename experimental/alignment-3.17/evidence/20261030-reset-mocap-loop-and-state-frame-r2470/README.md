# Mocap reset loop and state-buffer preservation

The independent private Reset_Mocap_Poses scope closes52 checks on each
reference closure. Under explicit mapping/layout/bounded-input assumptions it
copies every mapped body's original position and raw quaternion, preserving
typed bounds. Its indexed traversal has the same body order and two copies as
C mj_resetData. This helper is not wired into production: its public caller and
constructor/state-invariant integration remain open.

The actual Clear_State body remains the same four buffer assignments with the
same existing Pre/Post. Additional Static contracts prove mocap nullity, values
and index ranges are preserved, using two Ghost queries. Fresh scopes close50
on both references. These contracts are adopted locally; no type invariant,
runtime field or scan is introduced. The3.14 body projection6, model loop26,
validity projection4 and wrapper10 also close their recorded private scopes.

Both actual-frame and private-lifecycle candidates pass1472 new C cases each:
368 per reference/profile,16 samples,100 steps and unchanged2e-10 tolerances.
All184 output files equal the previously verified baseline. Validation objects
emit neither Ghost state-image query; prototype invariant predicates also have
no emitted symbols. Clear_State is1782 bytes in each validation closure. Code
size and numerical checks are not a performance measurement.

The new private state invariant carries typed mocap inputs, raw-reference bounds
and mapping facts. Free5 closes on3.17. The helper's call inside Reset closes7
checks in an explicitly line-limited diagnostic; this does not prove Reset.
Full Reset attempts hit600-second watchdogs. New internal Initialize MC/clamp
postconditions support caller reasoning but remain unproved as a whole. Create
reports close26 with one compound postcondition open; no factory completion is
claimed. Failed quote qualification and incompatible scope-switch attempts are
preserved with their actual status.

Constructor-wide flow diagnosis finds an actuator-reference borrow across D
cleanup and an unrecognized Arms initialization. Canonical array range alone
does not close that flow warning. A Relaxed_Initialization prototype explicitly
tracks and requires Initialized without a zero-fill pass. The selected-line
Initialized assertion is proved; the complete builder attempt reaches its
watchdog. Both reports retain their actual scopes and outcomes.
Relaxed initialization is not accepted here as a whole-builder proof.

A concrete C3.17 fixture has one ball joint and three DOFs on the same body.
Copy_Manifold_Joints changes owned joint counts/addresses to DOF metadata, so
full Matches_Body is too strong for the later raw-reference projection. The
weakened precondition requires only the copied raw quaternion equality. This
broader projection closes28 per reference and its wrapper12 per reference,
with no change to the desired raw-bound postcondition or runtime behavior.

Next work is to remove the constructor borrow without copying actuator records,
carry the precise immutable component frames, and close whole Reset/constructor
proofs before adopting the private invariant or removing more guards. Whole
state/dynamics Gold, full features, latest ABI migration and integrated C
performance parity remain open. No new commit or push is performed.
