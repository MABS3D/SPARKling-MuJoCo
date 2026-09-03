--  Validity clauses of a Model (spec 5). Every clause is an executable
--  expression function; Is_Valid is their conjunction and Valid_Model carries
--  it as a predicate. Clauses are chained with "and then" so that each may
--  assume the ones before it, which is what their preconditions state.
--
--  Rule for arithmetic on array values: a range clause always precedes it in
--  the chain, so no expression here can overflow or index out of bounds.
--
--  Contracts here are proven by GNATprove and are not evaluated at run time:
--  the element predicates cite whole-model clauses in their preconditions, and
--  evaluating those made the GCC optimiser inline them at every call site
--  (gnat1 reached 65 GB on 2026-09-03). The whole-model clauses are also kept
--  out of line for the same reason.
pragma Assertion_Policy (Pre => Ignore, Post => Ignore, Loop_Invariant => Ignore,
                         Loop_Variant => Ignore, Assert => Check);
with Interfaces;            use type Interfaces.Unsigned_8;
with MJ.Models.Gen_Clauses; use MJ.Models.Gen_Clauses;
--  MJ.Types is use-visible through the parent MJ.Models.

package MJ.Models.Validity with SPARK_Mode is

   ----------------------------------------------------------------------------
   --  5.1 Sizes
   ----------------------------------------------------------------------------

   function Sizes_OK (M : Model) return Boolean is
     (M.S.Nbody >= 1 and then M.S.Nbody < 2**16
      and then M.S.Nplugin = 0 and then M.S.Nflex = 0
      and then M.S.Nbvhstatic + M.S.Nbvhdynamic = M.S.Nbvh
      and then M.S.Ntree <= M.S.Nv)
   with Pre => Valid_Layout (M);

   ----------------------------------------------------------------------------
   --  Contiguous ownership blocks. Owner (K) is the owner of object K; owner I
   --  holds exactly the objects Adr (I) .. Adr (I) + Num (I) - 1, and Adr (I)
   --  is -1 when Num (I) = 0. Used for body/joint, body/dof, body/geom,
   --  tree/dof (spec 5.3).
   ----------------------------------------------------------------------------

   function Owners_Sorted (Owner : Int_Array; N_Owner : Integer) return Boolean is
     ((for all K in Owner'Range => Owner (K) in 0 .. N_Owner - 1)
      and then (for all K in Owner'Range =>
                  (if K > Owner'First then Owner (K) >= Owner (K - 1))));

   function Block_At (Adr, Num, Owner : Int_Array; I : Integer) return Boolean is
     (Num (I) in 0 .. Owner'Length
      and then (if Num (I) = 0 then Adr (I) = -1
                else Adr (I) in 0 .. Owner'Length - Num (I)
                     and then Owner (Adr (I)) = I
                     and then Owner (Adr (I) + Num (I) - 1) = I
                     and then (Adr (I) = 0 or else Owner (Adr (I) - 1) /= I)
                     and then (Adr (I) + Num (I) = Owner'Length
                               or else Owner (Adr (I) + Num (I)) /= I)))
   with Pre => Adr'First = 0 and then Num'First = 0 and then Owner'First = 0
               and then Adr'Length = Num'Length and then I in Adr'Range;

   function Blocks_OK (Adr, Num, Owner : Int_Array) return Boolean is
     (for all I in Adr'Range => Block_At (Adr, Num, Owner, I))
   with Pre => Adr'First = 0 and then Num'First = 0 and then Owner'First = 0
               and then Adr'Length = Num'Length;

   function Covered_At (Adr, Num, Owner : Int_Array; K : Integer) return Boolean is
     (Owner (K) in Adr'Range
      and then Num (Owner (K)) > 0
      and then K in Adr (Owner (K)) .. Adr (Owner (K)) + Num (Owner (K)) - 1)
   with Pre => Adr'First = 0 and then Num'First = 0 and then Owner'First = 0
               and then Adr'Length = Num'Length
               and then Blocks_OK (Adr, Num, Owner) and then K in Owner'Range;

   function Covered_OK (Adr, Num, Owner : Int_Array) return Boolean is
     (for all K in Owner'Range => Covered_At (Adr, Num, Owner, K))
   with Pre => Adr'First = 0 and then Num'First = 0 and then Owner'First = 0
               and then Adr'Length = Num'Length and then Blocks_OK (Adr, Num, Owner);

   ----------------------------------------------------------------------------
   --  5.3 Body tree
   ----------------------------------------------------------------------------

   function Parent_At (M : Model; I : Integer) return Boolean is
     (if I = 0 then M.Bodies.Body_Parentid (0) = 0
      else M.Bodies.Body_Parentid (I) in 0 .. I - 1)
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then I in 0 .. M.S.Nbody - 1;

   function Parents_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nbody - 1 => Parent_At (M, I))
   with Pre => Valid_Layout (M) and then Sizes_OK (M);

   function Root_At (M : Model; I : Integer) return Boolean is
     (M.Bodies.Body_Rootid (I) in 0 .. I
      and then (if I = 0 then M.Bodies.Body_Rootid (0) = 0
                elsif M.Bodies.Body_Parentid (I) = 0 then M.Bodies.Body_Rootid (I) = I
                else M.Bodies.Body_Rootid (I) = M.Bodies.Body_Rootid (M.Bodies.Body_Parentid (I))))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Parents_OK (M)
               and then I in 0 .. M.S.Nbody - 1;

   function Roots_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nbody - 1 => Root_At (M, I))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Parents_OK (M);

   function Weld_At (M : Model; I : Integer) return Boolean is
     (M.Bodies.Body_Weldid (I) in 0 .. I
      and then (if I = 0 then M.Bodies.Body_Weldid (0) = 0
                elsif M.Bodies.Body_Jntnum (I) > 0 then M.Bodies.Body_Weldid (I) = I
                else M.Bodies.Body_Weldid (I) = M.Bodies.Body_Weldid (M.Bodies.Body_Parentid (I))))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Parents_OK (M)
               and then I in 0 .. M.S.Nbody - 1;

   function Welds_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nbody - 1 => Weld_At (M, I))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Parents_OK (M);

   function Body_Joints_OK (M : Model) return Boolean is
     (Owners_Sorted (M.Joints.Jnt_Bodyid.all, M.S.Nbody)
      and then Blocks_OK (M.Bodies.Body_Jntadr.all, M.Bodies.Body_Jntnum.all, M.Joints.Jnt_Bodyid.all)
      and then Covered_OK (M.Bodies.Body_Jntadr.all, M.Bodies.Body_Jntnum.all, M.Joints.Jnt_Bodyid.all))
   with Pre => Valid_Layout (M) and then Sizes_OK (M);

   function Body_Dofs_OK (M : Model) return Boolean is
     (Owners_Sorted (M.Dofs.Dof_Bodyid.all, M.S.Nbody)
      and then Blocks_OK (M.Bodies.Body_Dofadr.all, M.Bodies.Body_Dofnum.all, M.Dofs.Dof_Bodyid.all)
      and then Covered_OK (M.Bodies.Body_Dofadr.all, M.Bodies.Body_Dofnum.all, M.Dofs.Dof_Bodyid.all))
   with Pre => Valid_Layout (M) and then Sizes_OK (M);

   function Body_Geoms_OK (M : Model) return Boolean is
     (Owners_Sorted (M.Geoms.Geom_Bodyid.all, M.S.Nbody)
      and then Blocks_OK (M.Bodies.Body_Geomadr.all, M.Bodies.Body_Geomnum.all, M.Geoms.Geom_Bodyid.all)
      and then Covered_OK (M.Bodies.Body_Geomadr.all, M.Bodies.Body_Geomnum.all, M.Geoms.Geom_Bodyid.all))
   with Pre => Valid_Layout (M) and then Sizes_OK (M);

   --  Trees are numbered by root dofs: the tree id increases by one at every
   --  dof whose parent is -1 and nowhere else.
   function Dof_Tree_At (M : Model; D : Integer) return Boolean is
     (M.Dofs.Dof_Treeid (D) in 0 .. M.S.Ntree - 1
      and then (if D = 0 then M.Dofs.Dof_Treeid (0) = 0
                else M.Dofs.Dof_Treeid (D - 1) in 0 .. M.S.Ntree - 1
                     and then M.Dofs.Dof_Treeid (D) =
                       M.Dofs.Dof_Treeid (D - 1) + (if M.Dofs.Dof_Parentid (D) = -1 then 1 else 0)))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then D in 0 .. M.S.Nv - 1;

   function Dof_Trees_OK (M : Model) return Boolean is
     ((if M.S.Nv = 0 then M.S.Ntree = 0
       else M.Dofs.Dof_Parentid (0) = -1
            and then M.Dofs.Dof_Treeid (M.S.Nv - 1) = M.S.Ntree - 1)
      and then (for all D in 0 .. M.S.Nv - 1 => Dof_Tree_At (M, D)))
   with Pre => Valid_Layout (M) and then Sizes_OK (M);

   function Tree_Dofs_OK (M : Model) return Boolean is
     ((for all T in 0 .. M.S.Ntree - 1 => M.Trees.Tree_Dofnum (T) >= 1)
      and then Owners_Sorted (M.Dofs.Dof_Treeid.all, M.S.Ntree)
      and then Blocks_OK (M.Trees.Tree_Dofadr.all, M.Trees.Tree_Dofnum.all, M.Dofs.Dof_Treeid.all)
      and then Covered_OK (M.Trees.Tree_Dofadr.all, M.Trees.Tree_Dofnum.all, M.Dofs.Dof_Treeid.all))
   with Pre => Valid_Layout (M) and then Sizes_OK (M);

   --  A body's tree is the tree of its weld body's first dof; bodies whose weld
   --  body has no dofs (the world and everything welded to it) have tree -1.
   function Body_Tree_At (M : Model; I : Integer) return Boolean is
     (declare
        W : constant Integer := M.Bodies.Body_Weldid (I);
      begin
        (if M.Bodies.Body_Dofnum (W) = 0 then M.Bodies.Body_Treeid (I) = -1
         else M.Bodies.Body_Treeid (I) = M.Dofs.Dof_Treeid (M.Bodies.Body_Dofadr (W))))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Parents_OK (M)
               and then Welds_OK (M) and then Body_Dofs_OK (M) and then Dof_Trees_OK (M)
               and then I in 0 .. M.S.Nbody - 1;

   function Tree_Body_Range_At (M : Model; T : Integer) return Boolean is
     (M.Trees.Tree_Bodynum (T) in 1 .. M.S.Nbody
      and then M.Trees.Tree_Bodyadr (T) in 0 .. M.S.Nbody - M.Trees.Tree_Bodynum (T)
      and then (for all K in M.Trees.Tree_Bodyadr (T) ..
                             M.Trees.Tree_Bodyadr (T) + M.Trees.Tree_Bodynum (T) - 1 =>
                  M.Bodies.Body_Treeid (K) = T))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then T in 0 .. M.S.Ntree - 1;

   function Body_In_Tree_At (M : Model; I : Integer) return Boolean is
     (if M.Bodies.Body_Treeid (I) >= 0 then
        M.Bodies.Body_Treeid (I) in 0 .. M.S.Ntree - 1
        and then I in M.Trees.Tree_Bodyadr (M.Bodies.Body_Treeid (I)) ..
                      M.Trees.Tree_Bodyadr (M.Bodies.Body_Treeid (I))
                      + M.Trees.Tree_Bodynum (M.Bodies.Body_Treeid (I)) - 1)
   with Pre => Valid_Layout (M) and then Sizes_OK (M)
               and then (for all T in 0 .. M.S.Ntree - 1 => Tree_Body_Range_At (M, T))
               and then I in 0 .. M.S.Nbody - 1;

   function Body_Trees_OK (M : Model) return Boolean is
     ((for all I in 0 .. M.S.Nbody - 1 => Body_Tree_At (M, I))
      and then (for all T in 0 .. M.S.Ntree - 1 => Tree_Body_Range_At (M, T))
      and then (for all I in 0 .. M.S.Nbody - 1 => Body_In_Tree_At (M, I))
      and then (for all T in 0 .. M.S.Ntree - 1 => M.Trees.Tree_Sleep_Policy (T) in 0 .. 5))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Parents_OK (M)
               and then Welds_OK (M) and then Body_Dofs_OK (M) and then Dof_Trees_OK (M);

   ----------------------------------------------------------------------------
   --  5.4 Joints and dofs
   ----------------------------------------------------------------------------

   function Jnt_Types_OK (M : Model) return Boolean is
     (for all J in 0 .. M.S.Njnt - 1 => M.Joints.Jnt_Type (J) in 0 .. 3)
   with Pre => Valid_Layout (M);

   --  qpos and dof addresses are the running sums of the joint widths.
   function Jnt_Adr_At (M : Model; J : Integer) return Boolean is
     (M.Joints.Jnt_Qposadr (J) in 0 .. M.S.Nq
      and then M.Joints.Jnt_Dofadr (J) in 0 .. M.S.Nv
      and then (if J = 0 then M.Joints.Jnt_Qposadr (0) = 0 and then M.Joints.Jnt_Dofadr (0) = 0
                else M.Joints.Jnt_Qposadr (J - 1) in 0 .. M.S.Nq
                     and then M.Joints.Jnt_Dofadr (J - 1) in 0 .. M.S.Nv
                     and then M.Joints.Jnt_Qposadr (J) =
                       M.Joints.Jnt_Qposadr (J - 1) + Qpos_Width (M.Joints.Jnt_Type (J - 1))
                     and then M.Joints.Jnt_Dofadr (J) =
                       M.Joints.Jnt_Dofadr (J - 1) + Dof_Width (M.Joints.Jnt_Type (J - 1))))
   with Pre => Valid_Layout (M) and then Jnt_Types_OK (M) and then J in 0 .. M.S.Njnt - 1;

   function Jnt_Adrs_OK (M : Model) return Boolean is
     ((for all J in 0 .. M.S.Njnt - 1 => Jnt_Adr_At (M, J))
      and then (if M.S.Njnt = 0 then M.S.Nq = 0 and then M.S.Nv = 0
                else M.Joints.Jnt_Qposadr (M.S.Njnt - 1)
                       + Qpos_Width (M.Joints.Jnt_Type (M.S.Njnt - 1)) = M.S.Nq
                     and then M.Joints.Jnt_Dofadr (M.S.Njnt - 1)
                       + Dof_Width (M.Joints.Jnt_Type (M.S.Njnt - 1)) = M.S.Nv))
   with Pre => Valid_Layout (M) and then Jnt_Types_OK (M);

   function Dof_Joint_At (M : Model; D : Integer) return Boolean is
     (M.Dofs.Dof_Jntid (D) in 0 .. M.S.Njnt - 1
      and then D in M.Joints.Jnt_Dofadr (M.Dofs.Dof_Jntid (D)) ..
                    M.Joints.Jnt_Dofadr (M.Dofs.Dof_Jntid (D))
                    + Dof_Width (M.Joints.Jnt_Type (M.Dofs.Dof_Jntid (D))) - 1
      and then M.Dofs.Dof_Bodyid (D) = M.Joints.Jnt_Bodyid (M.Dofs.Dof_Jntid (D)))
   with Pre => Valid_Layout (M) and then Jnt_Types_OK (M) and then Jnt_Adrs_OK (M)
               and then D in 0 .. M.S.Nv - 1;

   function Dof_Joints_OK (M : Model) return Boolean is
     (for all D in 0 .. M.S.Nv - 1 => Dof_Joint_At (M, D))
   with Pre => Valid_Layout (M) and then Jnt_Types_OK (M) and then Jnt_Adrs_OK (M);

   --  Parent of the first dof of joint J: the last dof of the previous joint on
   --  the same body, else the last dof of the weld body of the parent body,
   --  else -1.
   function Expected_First_Parent (M : Model; J : Integer) return Integer is
     (declare
        B : constant Integer := M.Joints.Jnt_Bodyid (J);
      begin
        (if J > M.Bodies.Body_Jntadr (B) then M.Joints.Jnt_Dofadr (J) - 1
         else (declare
                 W : constant Integer := M.Bodies.Body_Weldid (M.Bodies.Body_Parentid (B));
               begin
                 (if M.Bodies.Body_Dofnum (W) = 0 then -1
                  else M.Bodies.Body_Dofadr (W) + M.Bodies.Body_Dofnum (W) - 1))))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Parents_OK (M)
               and then Welds_OK (M) and then Body_Joints_OK (M) and then Body_Dofs_OK (M)
               and then Jnt_Types_OK (M) and then Jnt_Adrs_OK (M)
               and then J in 0 .. M.S.Njnt - 1,
        Post => Expected_First_Parent'Result in -1 .. M.S.Nv - 1;

   function Dof_Parent_At (M : Model; D : Integer) return Boolean is
     (M.Dofs.Dof_Parentid (D) in -1 .. D - 1
      and then (if D > M.Joints.Jnt_Dofadr (M.Dofs.Dof_Jntid (D))
                then M.Dofs.Dof_Parentid (D) = D - 1
                else M.Dofs.Dof_Parentid (D) = Expected_First_Parent (M, M.Dofs.Dof_Jntid (D))))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Parents_OK (M)
               and then Welds_OK (M) and then Body_Joints_OK (M) and then Body_Dofs_OK (M)
               and then Jnt_Types_OK (M) and then Jnt_Adrs_OK (M) and then Dof_Joints_OK (M)
               and then D in 0 .. M.S.Nv - 1;

   function Dof_Parents_OK (M : Model) return Boolean is
     (for all D in 0 .. M.S.Nv - 1 => Dof_Parent_At (M, D))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Parents_OK (M)
               and then Welds_OK (M) and then Body_Joints_OK (M) and then Body_Dofs_OK (M)
               and then Jnt_Types_OK (M) and then Jnt_Adrs_OK (M) and then Dof_Joints_OK (M);

   --  Parent ranges alone, restated for the Madr preconditions.
   function Dof_Parent_Ranges_OK (M : Model) return Boolean is
     (for all K in 0 .. M.S.Nv - 1 => M.Dofs.Dof_Parentid (K) in -1 .. K - 1)
   with Pre => Valid_Layout (M);

   --  dof_Madr is the row layout of the sparse inertia: row D holds D and its
   --  ancestors, so its length is one more than its parent's.
   function Madr_Range_OK (M : Model) return Boolean is
     (for all D in 0 .. M.S.Nv - 1 => M.Dofs.Dof_Madr (D) in 0 .. M.S.Nm)
   with Pre => Valid_Layout (M);

   function Row_Len (M : Model; D : Integer) return Integer is
     ((if D = M.S.Nv - 1 then M.S.Nm else M.Dofs.Dof_Madr (D + 1)) - M.Dofs.Dof_Madr (D))
   with Pre => Valid_Layout (M) and then Madr_Range_OK (M) and then D in 0 .. M.S.Nv - 1;

   function Madr_At (M : Model; D : Integer) return Boolean is
     (Row_Len (M, D) >= 1
      and then (if M.Dofs.Dof_Parentid (D) = -1 then Row_Len (M, D) = 1
                else Row_Len (M, D) = Row_Len (M, M.Dofs.Dof_Parentid (D)) + 1))
   with Pre => Valid_Layout (M) and then Madr_Range_OK (M) and then Dof_Parent_Ranges_OK (M)
               and then D in 0 .. M.S.Nv - 1;

   function Madrs_OK (M : Model) return Boolean is
     ((if M.S.Nv = 0 then M.S.Nm = 0 else M.Dofs.Dof_Madr (0) = 0)
      and then (for all D in 0 .. M.S.Nv - 1 => Madr_At (M, D)))
   with Pre => Valid_Layout (M) and then Madr_Range_OK (M) and then Dof_Parent_Ranges_OK (M);

   function Simplenums_OK (M : Model) return Boolean is
     (for all D in 0 .. M.S.Nv - 1 => M.Dofs.Dof_Simplenum (D) in 0 .. M.S.Nv - D)
   with Pre => Valid_Layout (M);

   ----------------------------------------------------------------------------
   --  5.5 Sparse structures. A CSR triple is well formed when rows are
   --  contiguous, cover exactly nnz entries, and column indexes are in range
   --  and strictly increasing within each row.
   ----------------------------------------------------------------------------

   function CSR_OK (Rownnz, Rowadr, Colind : Int_Array; N, Nnz, Ncols : Integer) return Boolean is
     (Rownnz'First = 0 and then Rowadr'First = 0 and then Colind'First = 0
      and then Rownnz'Length = N and then Rowadr'Length = N and then Colind'Length = Nnz
      and then (for all I in 0 .. N - 1 =>
                  Rownnz (I) in 0 .. Nnz and then Rowadr (I) in 0 .. Nnz - Rownnz (I))
      and then (for all I in 0 .. N - 1 =>
                  Rowadr (I) = (if I = 0 then 0 else Rowadr (I - 1) + Rownnz (I - 1)))
      and then (if N = 0 then Nnz = 0 else Rowadr (N - 1) + Rownnz (N - 1) = Nnz)
      and then (for all K in 0 .. Nnz - 1 => Colind (K) in 0 .. Ncols - 1)
      and then (for all I in 0 .. N - 1 =>
                  (for all K in Rowadr (I) .. Rowadr (I) + Rownnz (I) - 2 =>
                     Colind (K) < Colind (K + 1))))
   with Pre => N >= 0 and then Nnz >= 0 and then Ncols >= 0;

   function Sparse_M_OK (M : Model) return Boolean is
     (CSR_OK (M.Sparse.M_Rownnz.all, M.Sparse.M_Rowadr.all, M.Sparse.M_Colind.all,
              M.S.Nv, M.S.Nm, M.S.Nv))
   with Pre => Valid_Layout (M);

   function Sparse_B_OK (M : Model) return Boolean is
     (CSR_OK (M.Sparse.B_Rownnz.all, M.Sparse.B_Rowadr.all, M.Sparse.B_Colind.all,
              M.S.Nbody, M.S.Nb, M.S.Nv))
   with Pre => Valid_Layout (M);

   function Sparse_D_OK (M : Model) return Boolean is
     (CSR_OK (M.Sparse.D_Rownnz.all, M.Sparse.D_Rowadr.all, M.Sparse.D_Colind.all,
              M.S.Nv, M.S.Nd, M.S.Nv))
   with Pre => Valid_Layout (M);

   function Sparse_Ten_J_OK (M : Model) return Boolean is
     (CSR_OK (M.Tendons.Ten_J_Rownnz.all, M.Tendons.Ten_J_Rowadr.all, M.Tendons.Ten_J_Colind.all,
              M.S.Ntendon, M.S.Njten, M.S.Nv))
   with Pre => Valid_Layout (M);

   --  Row I of the CSR inertia has the length dof_Madr dictates and holds the
   --  parent's row followed by I.
   function M_Rownnz_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nv - 1 => M.Sparse.M_Rownnz (I) = Row_Len (M, I))
   with Pre => Valid_Layout (M) and then Madr_Range_OK (M) and then Sparse_M_OK (M);

   function M_Row_At (M : Model; I : Integer) return Boolean is
     (M.Sparse.M_Colind (M.Sparse.M_Rowadr (I) + M.Sparse.M_Rownnz (I) - 1) = I
      and then (if M.Dofs.Dof_Parentid (I) >= 0 then
                  (for all K in 0 .. M.Sparse.M_Rownnz (I) - 2 =>
                     M.Sparse.M_Colind (M.Sparse.M_Rowadr (I) + K) =
                     M.Sparse.M_Colind (M.Sparse.M_Rowadr (M.Dofs.Dof_Parentid (I)) + K))))
   with Pre => Valid_Layout (M) and then Madr_Range_OK (M) and then Dof_Parent_Ranges_OK (M)
               and then Madrs_OK (M) and then Sparse_M_OK (M) and then M_Rownnz_OK (M)
               and then I in 0 .. M.S.Nv - 1;

   function M_Rows_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nv - 1 => M_Row_At (M, I))
   with Pre => Valid_Layout (M) and then Madr_Range_OK (M) and then Dof_Parent_Ranges_OK (M)
               and then Madrs_OK (M) and then Sparse_M_OK (M) and then M_Rownnz_OK (M);

   function D_Diag_At (M : Model; I : Integer) return Boolean is
     (M.Sparse.D_Diag (I) in 0 .. M.Sparse.D_Rownnz (I) - 1
      and then M.Sparse.D_Colind (M.Sparse.D_Rowadr (I) + M.Sparse.D_Diag (I)) = I)
   with Pre => Valid_Layout (M) and then Sparse_D_OK (M) and then I in 0 .. M.S.Nv - 1;

   function D_Diags_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nv - 1 => D_Diag_At (M, I))
   with Pre => Valid_Layout (M) and then Sparse_D_OK (M);

   function Maps_OK (M : Model) return Boolean is
     ((for all K in 0 .. M.S.Nc - 1 => M.Sparse.MapM2M (K) in 0 .. M.S.Nm - 1)
      and then (for all K in 0 .. M.S.Nd - 1 => M.Sparse.MapM2D (K) in 0 .. M.S.Nm - 1)
      and then (for all K in 0 .. M.S.Nm - 1 => M.Sparse.MapD2M (K) in 0 .. M.S.Nd - 1)
      and then (for all K in 0 .. M.S.Nm - 1 => M.Sparse.MapM2D (M.Sparse.MapD2M (K)) = K))
   with Pre => Valid_Layout (M);

   ----------------------------------------------------------------------------
   --  5.6 Geoms, meshes, heightfields, textures, bounding volume hierarchies
   ----------------------------------------------------------------------------

   function Geom_Type_At (M : Model; G : Integer) return Boolean is
     (M.Geoms.Geom_Type (G) in 0 .. 7            --  8 = SDF needs a plugin
      and then M.Geoms.Geom_Condim (G) in 1 | 3 | 4 | 6)
   with Pre => Valid_Layout (M) and then G in 0 .. M.S.Ngeom - 1;

   function Geom_Types_OK (M : Model) return Boolean is
     (for all G in 0 .. M.S.Ngeom - 1 => Geom_Type_At (M, G))
   with Pre => Valid_Layout (M);

   function Geom_Data_At (M : Model; G : Integer) return Boolean is
     (case M.Geoms.Geom_Type (G) is
        when 1      => M.Geoms.Geom_Dataid (G) in 0 .. M.S.Nhfield - 1,
        when 7      => M.Geoms.Geom_Dataid (G) in 0 .. M.S.Nmesh - 1,
        when others => M.Geoms.Geom_Dataid (G) = -1)
   with Pre => Valid_Layout (M) and then G in 0 .. M.S.Ngeom - 1;

   function Geom_Datas_OK (M : Model) return Boolean is
     (for all G in 0 .. M.S.Ngeom - 1 => Geom_Data_At (M, G))
   with Pre => Valid_Layout (M);

   function Sameframes_OK (M : Model) return Boolean is
     ((for all I in 0 .. M.S.Nbody - 1 => M.Bodies.Body_Sameframe (I) <= 4)
      and then (for all G in 0 .. M.S.Ngeom - 1 => M.Geoms.Geom_Sameframe (G) <= 4)
      and then (for all S in 0 .. M.S.Nsite - 1 => M.Sites.Site_Sameframe (S) <= 4))
   with Pre => Valid_Layout (M);

   --  Face vertex, normal, and texcoord indexes are local to the mesh.
   function Mesh_Faces_At (M : Model; I : Integer) return Boolean is
     (for all F in M.Meshes.Mesh_Faceadr (I) .. M.Meshes.Mesh_Faceadr (I) + M.Meshes.Mesh_Facenum (I) - 1 =>
        (for all K in 0 .. 2 =>
           M.Meshes.Mesh_Face (3 * F + K) in 0 .. M.Meshes.Mesh_Vertnum (I) - 1
           and then (if M.Meshes.Mesh_Normalnum (I) > 0 then
                       M.Meshes.Mesh_Facenormal (3 * F + K) in 0 .. M.Meshes.Mesh_Normalnum (I) - 1)
           and then (if M.Meshes.Mesh_Texcoordadr (I) >= 0 and then M.Meshes.Mesh_Texcoordnum (I) > 0 then
                       M.Meshes.Mesh_Facetexcoord (3 * F + K) in 0 .. M.Meshes.Mesh_Texcoordnum (I) - 1)))
   with Pre => Valid_Layout (M) and then Refs_OK (M) and then I in 0 .. M.S.Nmesh - 1;

   --  Polygon vertex lists index the mesh's vertices; the per-vertex polygon map
   --  indexes the mesh's polygons.
   function Mesh_Polys_At (M : Model; I : Integer) return Boolean is
     ((for all P in M.Meshes.Mesh_Polyadr (I) .. M.Meshes.Mesh_Polyadr (I) + M.Meshes.Mesh_Polynum (I) - 1 =>
         (for all K in M.Meshes.Mesh_Polyvertadr (P) ..
                       M.Meshes.Mesh_Polyvertadr (P) + M.Meshes.Mesh_Polyvertnum (P) - 1 =>
            M.Meshes.Mesh_Polyvert (K) in 0 .. M.Meshes.Mesh_Vertnum (I) - 1))
      and then (for all V in M.Meshes.Mesh_Vertadr (I) .. M.Meshes.Mesh_Vertadr (I) + M.Meshes.Mesh_Vertnum (I) - 1 =>
                  (for all K in M.Meshes.Mesh_Polymapadr (V) ..
                                M.Meshes.Mesh_Polymapadr (V) + M.Meshes.Mesh_Polymapnum (V) - 1 =>
                     M.Meshes.Mesh_Polymap (K) in 0 .. M.Meshes.Mesh_Polynum (I) - 1)))
   with Pre => Valid_Layout (M) and then Refs_OK (M) and then I in 0 .. M.S.Nmesh - 1;

   --  Convex hull graph block (user_mesh.cc MakeGraph): numvert, numface,
   --  vert_edgeadr[numvert], vert_globalid[numvert], edge_localid[numvert+3*numface]
   --  terminated by -1 runs, face_globalid[3*numface]. Blocks must fit before
   --  the end of mesh_graph; the engine walks edge lists until a -1, so the
   --  last edge entry must be -1.
   function Graph_Block_At (M : Model; I, A, Nv, Nf : Integer) return Boolean is
     (declare
        Ne : constant Integer := Nv + 3 * Nf;
      begin
        Int64 (A) + 2 + 3 * Int64 (Nv) + 6 * Int64 (Nf) <= Int64 (M.S.Nmeshgraph)
        and then (for all K in 0 .. Nv - 1 => M.Meshes.Mesh_Graph (A + 2 + K) in 0 .. Ne - 1)
        and then (for all K in 0 .. Nv - 1 =>
                    M.Meshes.Mesh_Graph (A + 2 + Nv + K) in 0 .. M.Meshes.Mesh_Vertnum (I) - 1)
        and then (for all K in 0 .. Ne - 1 => M.Meshes.Mesh_Graph (A + 2 + 2 * Nv + K) in -1 .. Nv - 1)
        and then (Ne = 0 or else M.Meshes.Mesh_Graph (A + 2 + 2 * Nv + Ne - 1) = -1)
        and then (for all K in 0 .. 3 * Nf - 1 =>
                    M.Meshes.Mesh_Graph (A + 2 + 3 * Nv + 3 * Nf + K) in 0 .. M.Meshes.Mesh_Vertnum (I) - 1))
   with Pre => Valid_Layout (M) and then I in 0 .. M.S.Nmesh - 1
               and then A in 0 .. M.S.Nmeshgraph - 2
               and then Nv in 0 .. M.Meshes.Mesh_Vertnum (I) and then Nf in 0 .. Max_Size / 6;

   function Mesh_Graph_At (M : Model; I : Integer) return Boolean is
     (if M.Meshes.Mesh_Graphadr (I) >= 0 then
        M.Meshes.Mesh_Graphadr (I) <= M.S.Nmeshgraph - 2
        and then M.Meshes.Mesh_Graph (M.Meshes.Mesh_Graphadr (I)) in 0 .. M.Meshes.Mesh_Vertnum (I)
        and then M.Meshes.Mesh_Graph (M.Meshes.Mesh_Graphadr (I) + 1) in 0 .. Max_Size / 6
        and then Graph_Block_At (M, I, M.Meshes.Mesh_Graphadr (I),
                                 M.Meshes.Mesh_Graph (M.Meshes.Mesh_Graphadr (I)),
                                 M.Meshes.Mesh_Graph (M.Meshes.Mesh_Graphadr (I) + 1)))
   with Pre => Valid_Layout (M) and then Refs_OK (M) and then I in 0 .. M.S.Nmesh - 1;

   function Meshes_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nmesh - 1 =>
        Mesh_Faces_At (M, I) and then Mesh_Polys_At (M, I) and then Mesh_Graph_At (M, I))
   with Pre => Valid_Layout (M) and then Refs_OK (M);

   function Hfield_At (M : Model; H : Integer) return Boolean is
     (M.Hfields.Hfield_Nrow (H) >= 1 and then M.Hfields.Hfield_Ncol (H) >= 1
      and then M.Hfields.Hfield_Adr (H) in 0 .. M.S.Nhfielddata
      and then Int64 (M.Hfields.Hfield_Adr (H))
               + Int64 (M.Hfields.Hfield_Nrow (H)) * Int64 (M.Hfields.Hfield_Ncol (H))
               <= Int64 (M.S.Nhfielddata)
      and then M.Hfields.Hfield_Size (4 * H) > 0.0 and then M.Hfields.Hfield_Size (4 * H + 1) > 0.0
      and then M.Hfields.Hfield_Size (4 * H + 2) > 0.0 and then M.Hfields.Hfield_Size (4 * H + 3) >= 0.0)
   with Pre => Valid_Layout (M) and then H in 0 .. M.S.Nhfield - 1;

   function Hfields_OK (M : Model) return Boolean is
     (for all H in 0 .. M.S.Nhfield - 1 => Hfield_At (M, H))
   with Pre => Valid_Layout (M);

   function Texture_At (M : Model; T : Integer) return Boolean is
     (M.Textures.Tex_Nchannel (T) in 1 .. 4
      and then M.Textures.Tex_Height (T) >= 0 and then M.Textures.Tex_Width (T) >= 0
      and then Int64 (M.Textures.Tex_Height (T)) * Int64 (M.Textures.Tex_Width (T))
               <= Int64 (Max_Size)
      and then M.Textures.Tex_Adr (T) in 0 .. Int64 (M.S.Ntexdata)
      and then M.Textures.Tex_Adr (T)
               + Int64 (M.Textures.Tex_Nchannel (T))
                 * (Int64 (M.Textures.Tex_Height (T)) * Int64 (M.Textures.Tex_Width (T)))
               <= Int64 (M.S.Ntexdata))
   with Pre => Valid_Layout (M) and then T in 0 .. M.S.Ntex - 1;

   function Textures_OK (M : Model) return Boolean is
     (for all T in 0 .. M.S.Ntex - 1 => Texture_At (M, T))
   with Pre => Valid_Layout (M);

   --  Texture references not covered by the C reference table.
   function Texids_OK (M : Model) return Boolean is
     ((for all K in M.Materials.Mat_Texid'Range => M.Materials.Mat_Texid (K) in -1 .. M.S.Ntex - 1)
      and then (for all L in 0 .. M.S.Nlight - 1 => M.Lights.Light_Texid (L) in -1 .. M.S.Ntex - 1))
   with Pre => Valid_Layout (M);

   --  BVH children are local indexes within the block and point forward;
   --  leaves (nodeid >= 0) have no children.
   function Bvh_Node_At (M : Model; Adr, Num, L : Integer) return Boolean is
     (declare
        N : constant Integer := Adr + L;
      begin
        M.Bvh.Bvh_Depth (N) in 0 .. Max_Tree_Depth
        and then M.Bvh.Bvh_Child (2 * N) in -1 .. Num - 1
        and then M.Bvh.Bvh_Child (2 * N + 1) in -1 .. Num - 1
        and then (M.Bvh.Bvh_Child (2 * N) = -1 or else M.Bvh.Bvh_Child (2 * N) > L)
        and then (M.Bvh.Bvh_Child (2 * N + 1) = -1 or else M.Bvh.Bvh_Child (2 * N + 1) > L)
        and then (M.Bvh.Bvh_Nodeid (N) >= 0) =
                 (M.Bvh.Bvh_Child (2 * N) = -1 and then M.Bvh.Bvh_Child (2 * N + 1) = -1))
   with Pre => Valid_Layout (M) and then Adr >= 0 and then Num >= 1
               and then Adr <= M.S.Nbvh - Num and then L in 0 .. Num - 1;

   function Body_Bvh_At (M : Model; B : Integer) return Boolean is
     (if M.Bodies.Body_Bvhnum (B) > 0 then
        (for all L in 0 .. M.Bodies.Body_Bvhnum (B) - 1 =>
           Bvh_Node_At (M, M.Bodies.Body_Bvhadr (B), M.Bodies.Body_Bvhnum (B), L)
           and then (if M.Bvh.Bvh_Nodeid (M.Bodies.Body_Bvhadr (B) + L) >= 0 then
                       M.Bvh.Bvh_Nodeid (M.Bodies.Body_Bvhadr (B) + L) in 0 .. M.S.Ngeom - 1
                       and then M.Geoms.Geom_Bodyid (M.Bvh.Bvh_Nodeid (M.Bodies.Body_Bvhadr (B) + L)) = B)))
   with Pre => Valid_Layout (M) and then Refs_OK (M) and then B in 0 .. M.S.Nbody - 1;

   function Mesh_Bvh_At (M : Model; I : Integer) return Boolean is
     (if M.Meshes.Mesh_Bvhnum (I) > 0 then
        (for all L in 0 .. M.Meshes.Mesh_Bvhnum (I) - 1 =>
           Bvh_Node_At (M, M.Meshes.Mesh_Bvhadr (I), M.Meshes.Mesh_Bvhnum (I), L)
           and then (if M.Bvh.Bvh_Nodeid (M.Meshes.Mesh_Bvhadr (I) + L) >= 0 then
                       M.Bvh.Bvh_Nodeid (M.Meshes.Mesh_Bvhadr (I) + L) in 0 .. M.Meshes.Mesh_Facenum (I) - 1)))
   with Pre => Valid_Layout (M) and then Refs_OK (M) and then I in 0 .. M.S.Nmesh - 1;

   function Bvhs_OK (M : Model) return Boolean is
     ((for all B in 0 .. M.S.Nbody - 1 => Body_Bvh_At (M, B))
      and then (for all I in 0 .. M.S.Nmesh - 1 => Mesh_Bvh_At (M, I)))
   with Pre => Valid_Layout (M) and then Refs_OK (M);

   --  Octree nodes (mesh SDF path of sub-project 8): block ranges and child
   --  indexes in range; finer structure is stated there.
   function Octs_OK (M : Model) return Boolean is
     ((for all I in 0 .. M.S.Nmesh - 1 =>
         M.Meshes.Mesh_Octnum (I) in 0 .. M.S.Noct
         and then (if M.Meshes.Mesh_Octnum (I) = 0 then M.Meshes.Mesh_Octadr (I) in -1 .. M.S.Noct
                   else M.Meshes.Mesh_Octadr (I) in 0 .. M.S.Noct - M.Meshes.Mesh_Octnum (I)))
      and then (for all N in 0 .. M.S.Noct - 1 =>
                  M.Bvh.Oct_Depth (N) in 0 .. Max_Tree_Depth
                  and then (for all K in 0 .. 7 => M.Bvh.Oct_Child (8 * N + K) in -1 .. M.S.Noct - 1)))
   with Pre => Valid_Layout (M);

   ----------------------------------------------------------------------------
   --  Conjunction. Tasks 8c and 8d append clauses here, before Valid_Model.
   ----------------------------------------------------------------------------

   function Is_Valid (M : Model) return Boolean is
     (Sizes_OK (M)
      and then Refs_OK (M) and then Bools_OK (M) and then Reals_In_Tier0 (M)
      and then Parents_OK (M) and then Roots_OK (M) and then Welds_OK (M)
      and then Body_Joints_OK (M) and then Body_Dofs_OK (M) and then Body_Geoms_OK (M)
      and then Dof_Trees_OK (M) and then Tree_Dofs_OK (M) and then Body_Trees_OK (M)
      and then Jnt_Types_OK (M) and then Jnt_Adrs_OK (M) and then Dof_Joints_OK (M)
      and then Dof_Parents_OK (M) and then Dof_Parent_Ranges_OK (M)
      and then Madr_Range_OK (M) and then Madrs_OK (M) and then Simplenums_OK (M)
      and then Sparse_M_OK (M) and then Sparse_B_OK (M) and then Sparse_D_OK (M)
      and then Sparse_Ten_J_OK (M) and then M_Rownnz_OK (M) and then M_Rows_OK (M)
      and then D_Diags_OK (M) and then Maps_OK (M)
      and then Geom_Types_OK (M) and then Geom_Datas_OK (M) and then Sameframes_OK (M)
      and then Meshes_OK (M) and then Hfields_OK (M) and then Textures_OK (M) and then Texids_OK (M)
      and then Bvhs_OK (M) and then Octs_OK (M))
   with Pre => Valid_Layout (M);

   subtype Valid_Model is Model
     with Dynamic_Predicate => Valid_Layout (Valid_Model) and then Is_Valid (Valid_Model);

   pragma No_Inline (Sizes_OK, Owners_Sorted, Blocks_OK, Covered_OK, Parents_OK, Roots_OK, Welds_OK,
                     Body_Joints_OK, Body_Dofs_OK, Body_Geoms_OK, Dof_Trees_OK, Tree_Dofs_OK,
                     Body_Trees_OK, Jnt_Types_OK, Jnt_Adrs_OK, Dof_Joints_OK, Dof_Parents_OK,
                     Dof_Parent_Ranges_OK, Madr_Range_OK, Madrs_OK, Simplenums_OK,
                     CSR_OK, Sparse_M_OK, Sparse_B_OK, Sparse_D_OK, Sparse_Ten_J_OK, M_Rownnz_OK,
                     M_Rows_OK, D_Diags_OK, Maps_OK, Geom_Types_OK, Geom_Datas_OK, Sameframes_OK,
                     Meshes_OK, Hfields_OK, Textures_OK, Texids_OK, Bvhs_OK, Octs_OK, Is_Valid);

end MJ.Models.Validity;
