# Manifold topology and proved Arms initialization

The actual manifold topology path now has three small verified stages. The
fused DOF pass copies armatures and retains the compiled dof_M0 diagonal for
simple DOFs in the same order as C mj_crb. The raw-array cache builder preserves
the original body-mass traversal, reverse parent accumulation and cache-building
call order. Its thin wrapper supplies the owned/model arrays. Mechanical source
comparison verifies those runtime statements and traversal against baseline2528.
No zero-fill pass, record copy or runtime validation scan is added.

| Final scope | Reported checks per reference | Functional scope |
| --- | ---: | --- |
| Prepare_Manifold_Dofs | 56 | Exact success/rejection criterion, armature copies, simple/fixed/effective-parent values and frame |
| Build_Manifold_Cache | 67 | Safety, initialized Arms reads, cache dimensions and DOF metadata correspondence |
| Build_Manifold_Topology | 49 | Complete wrapper safety/contracts and supplied metadata correspondence |

All three scopes close on both pinned3.17/3.14 closures. Counts include their
informational flow checks; proof_checks and existing warnings remain separate
in each receipt. Gold here concerns the stated output properties under explicit
inputs/callee contracts. It is not a proof of full physical dynamics or every
cache field's mathematical meaning. No assumption, suppression or new trusted
body is introduced.

Relaxed_Initialization tracks the array while it is filled; it does not bypass
initialization safety. The56-check scope proves that Ok implies every armature
entry is initialized. The67-check scope separately proves initialization at
both consumers. Both actual whole-unit MJ.Data flow runs now have no open
messages, including the formerly reported Arms gap. Flow-only receipts contain
zero safety/functional proof VCs and are not whole-unit Gold proofs.

The first monolithic topology proofs hit240-second watchdogs. Hiding unrelated
predicates alone did not close them. Separating the cache algorithm from the
large Model/Simulation records closes its67-check scope. The initial wrapper
then has48 checks closed and one open last-index precondition. Length equality
with the same first index is the required relation; it also handles empty arrays.
Broadening those internal shapes closes all49 wrapper checks, without narrowing
supported public inputs. The earlier selected Initialize call reaches a
240-second watchdog without a fresh report. Its precondition propagation and
the complete factory/lifecycle proof remain open.

The added mixed_dof_tree has19 position coordinates and16 velocity DOFs: a free
parent with ball/hinge children, an independent simple free body and nonzero
armatures throughout. The C3.17 simple counts are0 for the first10 DOFs and
6,5,4,3,2,1 for the final6. Together with the earlier fixtures it gives15 models
and29 valid model/mode combinations. Final candidate2574 passes464 cases per
reference/profile at16 samples,100 steps and unchanged2e-10 C tolerances.
The old2528 binaries also pass the expanded suite; all116 final output files
match those baselines byte-for-byte. Fresh native objects contain none of the
listed Ghost projection/state-image symbols. Earlier candidate variants retain
their own frozen sources and results.

The initialization/cache refactor is adopted locally. Complete Initialize,
Create_Dynamics, Reset and state/dynamics Gold, the private mocap invariant,
feature completion, latest ABI migration and integrated performance parity
remain open. Existing reviewed warnings/deallocators are preserved. No timing,
complete-port, commit or push claim follows from this checkpoint.
