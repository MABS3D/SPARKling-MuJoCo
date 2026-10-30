# Mocap frames and trajectories with nonzero actuation

Exact source snapshots, proof reports, build flags, numerical providers and
failed/watchdog attempts are preserved in the reconstructable ZIP. Summary
records retain actual statuses, warnings, assumptions and source hashes.

The original mocap corpus passed 272 cases per run on both references, in
validation/release for baseline and private candidate. Its 68 output files are
byte-identical between baseline and candidate. Those original models have no
actuators, so activation preservation there only exercises an empty vector.

The expanded suite adds integrator, filter and filterexact actuator fixtures
with nonzero activation, control and generalized applied force. It explicitly
checks successful mocap setters preserve state/inputs/activation, rejected
updates remain atomic, and compares poses, accelerations, reset and 100-step
trajectories against the corresponding C reference. Existing fixtures, 16
samples and 2e-10 tolerances are retained. All 368 cases pass in each of the
eight reference/profile/role runs (2944 total), and 92 baseline/candidate output
files are byte-identical. Each reference/profile/role report
has its own source and binary hashes; these are numerical checks, not universal
equivalence proofs or performance measurements.

The first private state-frame prototype closes 80 obligations, with activation
preservation still open. Free closes 5 on each reference. Existing Zero_Array9,
Equal_State_Images4, Equal_Input_Images8, Equal_Activation_Images14 and
Equal_Transitive2 close their recorded scopes. Query helper precondition order
is corrected and both state/input helpers close13, activation helper5. Whole
setter variants retain their actual outcomes; watchdogs are not complete proofs.
The activation-postcondition-only diagnostic closes its three checks under the
current cut assertions; the input-postcondition diagnostic also closes three.
Both activation/input diagnostic reports are explicitly
limited to their selected source lines and cannot establish the complete setter
or its intermediate checks. The complete attempts hit their 600-second limits.
The duplicate allocator-contract experiment fails compilation and is retained.

The Static mocap invariant remains private: constructor/reset/all public state
operations still need lifecycle closure. Whole simulation/dynamics Gold,
latest ABI migration, full functionality and C performance parity remain open.
No runtime numerical optimization is adopted by this checkpoint.
