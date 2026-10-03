# Signed shell state and owned endpoint

Use the source files listed in this directory's `manifest.json`, from the frozen
`/var/tmp/sparkling-recovery-shell-endpoint2-20261003/source` closure. The FS hook
is a delta from state3; it is not applied to the live FS files. New shell kernels
have independent proof receipts. The manifest records their exact dependency
match to this build, rather than extending proof results to other common code.

The delta contains the two FS files, the separate Shell_Contacts child and three
kernel pairs: Flex_Shell_Weights, Flex_Shell_Geometry and
Flex_Shell_Node_Weights. Positive interpolation retains Nodal_Contacts and its
27-body endpoint. Shell_Contacts returns a distinct signed endpoint of capacity
729. Ordinary contacts retain their existing route. New files do not themselves
admit shell forces or dynamics.

FS now owns an integer interpolation order in -2..2 and checks negative compiled
body IDs before storing them as Natural. Update reconstructs interior shell
nodes from boundary nodes with the C position evaluation order before evaluating
vertices. It writes a temporary vector before assigning an interior node,
preserving the existing delayed publication of vertex and node positions.
Shell weights use absolute vertex coefficients for lookup, the sign of the first
coefficient, and basis cutoff before TFI expansion. Signed and zero terms remain;
duplicate bodies update their first existing entry. There is no renormalization.

The whole Shell_Contacts proof closes 59 proof and 11 flow checks, with seven
retained warnings. It establishes safety under called contracts, empty output on
rejection, and valid body references on success. The exact ordered floating-point
fold is specified and proved in the dedicated kernels. Whole FS proof, physical
accuracy, full C equivalence and dynamics are separate open obligations.

Validation and release each pass 3,228 bitwise owned shell endpoint cases,
816 positive endpoint cases, and 14 admission checks for each negative order.
The geometry replay reproduces all 141 accepted model records byte for byte,
covering 936 samples (432 positive, 312 ordinary, 192 shell). FS/adapter flow
closes 102 checks; its warnings remain in the receipt. Cross-API refusals and
the renewed positive adapter proof are recorded separately in the manifest.
The source Model is freed before owned endpoint queries in both probes.

Before movement integration, provide a dedicated signed endpoint producer and
Jacobian path; the current four-body interface cannot represent this endpoint.
Preserve the C body ordering and signed linear diagonal inverse-weight sum.
Do not replace it with absolute or squared coefficients. Mixed ordinary flexes
must still execute their existing force/contact/equality processing. Shell
elasticity, damping, edge and bending data, equality admission and core capacity
limits require their own compiled-field checks and integration tests. These
receipts do not authorize a generic FE bypass or a performance claim.

The C reference remains unmodified MuJoCo 3.14.0 at
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. The known mesh/SDF native abort is
unrelated to the shell endpoint corpus and remains a baseline failure in the
separate SDF receipt.
