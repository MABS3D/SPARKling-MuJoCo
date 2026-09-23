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
   --  holds exactly the objects Adr (I) .. (Adr (I) + Num (I)) - 1, and Adr (I)
   --  is -1 when Num (I) = 0. Used for body/joint, body/dof, body/geom,
   --  tree/dof (spec 5.3).
   ----------------------------------------------------------------------------

   function Owners_Sorted (Owner : Int_Array; N_Owner : Integer) return Boolean is
     (N_Owner >= 0
      and then (for all K in Owner'Range => Owner (K) in 0 .. N_Owner - 1)
      and then (for all K in Owner'Range =>
                  (if K > Owner'First then Owner (K) >= Owner (K - 1))));

   function Block_At (Adr, Num, Owner : Int_Array; I : Integer) return Boolean is
     (Int64 (Owner'Length) <= Int64 (Max_Size)
      and then Num (I) in 0 .. Owner'Length
      and then (if Num (I) = 0 then Adr (I) = -1
                else Adr (I) in 0 .. Owner'Length - Num (I)
                     and then Owner (Adr (I)) = I
                     and then Owner ((Adr (I) + Num (I)) - 1) = I
                     and then (Adr (I) = 0 or else Owner (Adr (I) - 1) /= I)
                     and then (Adr (I) + Num (I) = Owner'Length
                               or else Owner (Adr (I) + Num (I)) /= I)))
   with Pre => Adr'First = 0 and then Num'First = 0 and then Owner'First = 0
               and then Adr'Length = Num'Length and then I in Adr'Range;

   function Blocks_OK (Adr, Num, Owner : Int_Array) return Boolean is
     (Int64 (Owner'Length) <= Int64 (Max_Size)
      and then (for all I in Adr'Range => Block_At (Adr, Num, Owner, I)))
   with Pre => Adr'First = 0 and then Num'First = 0 and then Owner'First = 0
               and then Adr'Length = Num'Length;

   function Covered_At (Adr, Num, Owner : Int_Array; K : Integer) return Boolean is
     (Owner (K) in Adr'Range
      and then Num (Owner (K)) > 0
      and then K in Adr (Owner (K)) .. (Adr (Owner (K)) + Num (Owner (K))) - 1)
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

   --  A body is its own weld body when it has joints or is a mocap body (its pose
   --  is set from outside); otherwise it is welded to its parent's weld body.
   function Weld_At (M : Model; I : Integer) return Boolean is
     (M.Bodies.Body_Weldid (I) in 0 .. I
      and then (if I = 0 then M.Bodies.Body_Weldid (0) = 0
                elsif M.Bodies.Body_Jntnum (I) > 0 or else M.Bodies.Body_Mocapid (I) >= 0
                then M.Bodies.Body_Weldid (I) = I
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
        (W in 0 .. M.S.Nbody - 1
         and then (if M.Bodies.Body_Dofnum (W) = 0 then M.Bodies.Body_Treeid (I) = -1
                   else M.Bodies.Body_Dofadr (W) in 0 .. M.S.Nv - 1
                     and then M.Bodies.Body_Treeid (I) = M.Dofs.Dof_Treeid (M.Bodies.Body_Dofadr (W)))))
   with Pre => Valid_Layout (M) and then I in 0 .. M.S.Nbody - 1;

   function Tree_Body_Range_At (M : Model; T : Integer) return Boolean is
     (M.Trees.Tree_Bodynum (T) in 1 .. M.S.Nbody
      and then M.Trees.Tree_Bodyadr (T) in 0 .. M.S.Nbody - M.Trees.Tree_Bodynum (T)
      and then (for all K in M.Trees.Tree_Bodyadr (T) ..
                             (M.Trees.Tree_Bodyadr (T) + M.Trees.Tree_Bodynum (T)) - 1 =>
                  M.Bodies.Body_Treeid (K) = T))
   with Pre => Valid_Layout (M) and then T in 0 .. M.S.Ntree - 1;

   function Body_In_Tree_At (M : Model; I : Integer) return Boolean is
     (if M.Bodies.Body_Treeid (I) >= 0 then
        M.Bodies.Body_Treeid (I) in 0 .. M.S.Ntree - 1
        and then Int64 (I) in Int64 (M.Trees.Tree_Bodyadr (M.Bodies.Body_Treeid (I))) ..
                      (Int64 (M.Trees.Tree_Bodyadr (M.Bodies.Body_Treeid (I)))
                       + Int64 (M.Trees.Tree_Bodynum (M.Bodies.Body_Treeid (I)))) - 1)
   with Pre => Valid_Layout (M) and then I in 0 .. M.S.Nbody - 1;

   function Body_Trees_OK (M : Model) return Boolean is
     ((for all I in 0 .. M.S.Nbody - 1 => Body_Tree_At (M, I))
      and then (for all T in 0 .. M.S.Ntree - 1 => Tree_Body_Range_At (M, T))
      and then (for all I in 0 .. M.S.Nbody - 1 => Body_In_Tree_At (M, I))
      and then (for all T in 0 .. M.S.Ntree - 1 => M.Trees.Tree_Sleep_Policy (T) in 0 .. 5))
   with Pre => Valid_Layout (M);

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
                else Int64 (M.Joints.Jnt_Qposadr (M.S.Njnt - 1))
                       + Int64 (Qpos_Width (M.Joints.Jnt_Type (M.S.Njnt - 1))) = Int64 (M.S.Nq)
                     and then Int64 (M.Joints.Jnt_Dofadr (M.S.Njnt - 1))
                       + Int64 (Dof_Width (M.Joints.Jnt_Type (M.S.Njnt - 1))) = Int64 (M.S.Nv)))
   with Pre => Valid_Layout (M) and then Jnt_Types_OK (M);

   function Dof_Joint_At (M : Model; D : Integer) return Boolean is
     (M.Dofs.Dof_Jntid (D) in 0 .. M.S.Njnt - 1
      and then M.Joints.Jnt_Type (M.Dofs.Dof_Jntid (D)) in 0 .. 3
      and then Int64 (D) in Int64 (M.Joints.Jnt_Dofadr (M.Dofs.Dof_Jntid (D))) ..
                    (Int64 (M.Joints.Jnt_Dofadr (M.Dofs.Dof_Jntid (D)))
                     + Int64 (Dof_Width (M.Joints.Jnt_Type (M.Dofs.Dof_Jntid (D))))) - 1
      and then M.Dofs.Dof_Bodyid (D) = M.Joints.Jnt_Bodyid (M.Dofs.Dof_Jntid (D)))
   with Pre => Valid_Layout (M) and then D in 0 .. M.S.Nv - 1;

   function Dof_Joints_OK (M : Model) return Boolean is
     (for all D in 0 .. M.S.Nv - 1 => Dof_Joint_At (M, D))
   with Pre => Valid_Layout (M);

   --  Parent of the first dof of joint J: the last dof of the previous joint on
   --  the same body, else the last dof of the weld body of the parent body,
   --  else -1.
   --  The element predicate supplies the exact local bounds needed below.
   --  This avoids importing several quantified whole-model clauses merely
   --  to establish safe indexing and arithmetic in one parent computation.
   function First_Parent_Input_OK (M : Model; J : Integer) return Boolean is
     (M.Joints.Jnt_Bodyid (J) in 0 .. M.S.Nbody - 1
      and then (declare
        B : constant Integer := M.Joints.Jnt_Bodyid (J);
      begin
        (if J > M.Bodies.Body_Jntadr (B) then M.Joints.Jnt_Dofadr (J) in 0 .. M.S.Nv
         else M.Bodies.Body_Parentid (B) in 0 .. M.S.Nbody - 1
           and then M.Bodies.Body_Weldid (M.Bodies.Body_Parentid (B)) in 0 .. M.S.Nbody - 1
           and then (declare
             W : constant Integer := M.Bodies.Body_Weldid (M.Bodies.Body_Parentid (B));
           begin
             (M.Bodies.Body_Dofnum (W) = 0
              or else (Int64 (M.Bodies.Body_Dofadr (W)) + Int64 (M.Bodies.Body_Dofnum (W))) - 1
                      in -1 .. Int64 (M.S.Nv) - 1)))))
   with Pre => Valid_Layout (M) and then J in 0 .. M.S.Njnt - 1;

   function Expected_First_Parent (M : Model; J : Integer) return Integer is
     (declare
        B : constant Integer := M.Joints.Jnt_Bodyid (J);
      begin
        (if J > M.Bodies.Body_Jntadr (B) then M.Joints.Jnt_Dofadr (J) - 1
         else (declare
                 W : constant Integer := M.Bodies.Body_Weldid (M.Bodies.Body_Parentid (B));
               begin
                 (if M.Bodies.Body_Dofnum (W) = 0 then -1
                  else Integer ((Int64 (M.Bodies.Body_Dofadr (W))
                                 + Int64 (M.Bodies.Body_Dofnum (W))) - 1)))))
   with Pre => Valid_Layout (M) and then J in 0 .. M.S.Njnt - 1
               and then First_Parent_Input_OK (M, J),
        Post => Expected_First_Parent'Result in -1 .. M.S.Nv - 1;

   function Dof_Parent_At (M : Model; D : Integer) return Boolean is
     (M.Dofs.Dof_Parentid (D) in -1 .. D - 1
      and then M.Dofs.Dof_Jntid (D) in 0 .. M.S.Njnt - 1
      and then (if D > M.Joints.Jnt_Dofadr (M.Dofs.Dof_Jntid (D))
                then M.Dofs.Dof_Parentid (D) = D - 1
                else First_Parent_Input_OK (M, M.Dofs.Dof_Jntid (D))
                  and then M.Dofs.Dof_Parentid (D) = Expected_First_Parent (M, M.Dofs.Dof_Jntid (D))))
   with Pre => Valid_Layout (M) and then D in 0 .. M.S.Nv - 1;

   function Dof_Parents_OK (M : Model) return Boolean is
     (for all D in 0 .. M.S.Nv - 1 => Dof_Parent_At (M, D))
   with Pre => Valid_Layout (M);

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
      and then Int64 (Rownnz'Length) = Int64 (N)
      and then Int64 (Rowadr'Length) = Int64 (N)
      and then Int64 (Colind'Length) = Int64 (Nnz)
      and then (for all I in 0 .. N - 1 =>
                  Rownnz (I) in 0 .. Nnz and then Rowadr (I) in 0 .. Nnz - Rownnz (I))
      and then (for all I in 0 .. N - 1 =>
                  Rowadr (I) = (if I = 0 then 0 else Rowadr (I - 1) + Rownnz (I - 1)))
      and then (if N = 0 then Nnz = 0 else Rowadr (N - 1) + Rownnz (N - 1) = Nnz)
      and then (for all K in 0 .. Nnz - 1 => Colind (K) in 0 .. Ncols - 1)
      and then (for all I in 0 .. N - 1 =>
                  (for all K in Rowadr (I) .. (Rowadr (I) + Rownnz (I)) - 2 =>
                     Colind (K) < Colind (K + 1))))
   with Pre => N >= 0 and then Nnz >= 0 and then Ncols >= 0;

   --  The CSR inertia is the reduced form of mj_makeDofDofSparse: a simple dof
   --  (dof_simplenum > 0) keeps only its diagonal, every other dof keeps its
   --  ancestors and itself, and the total is nC (nM is the legacy chain layout).
   function Sparse_M_OK (M : Model) return Boolean is
     (CSR_OK (M.Sparse.M_Rownnz.all, M.Sparse.M_Rowadr.all, M.Sparse.M_Colind.all,
              M.S.Nv, M.S.Nc, M.S.Nv))
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

   --  Row I of the CSR inertia: one entry for a simple dof, else the length
   --  dof_Madr dictates, holding the parent's row followed by I. A simple dof
   --  never has non-simple descendants, so a non-simple dof's parent is not simple.
   function M_Rownnz_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nv - 1 =>
        M.Sparse.M_Rownnz (I) = (if M.Dofs.Dof_Simplenum (I) > 0 then 1 else Row_Len (M, I)))
   with Pre => Valid_Layout (M) and then Madr_Range_OK (M) and then Sparse_M_OK (M);

   function M_Row_At (M : Model; I : Integer) return Boolean is
     (M.Sparse.M_Rownnz (I) in 1 .. M.S.Nc
      and then M.Sparse.M_Rowadr (I) in 0 .. M.S.Nc - M.Sparse.M_Rownnz (I)
      and then M.Sparse.M_Colind ((M.Sparse.M_Rowadr (I) + M.Sparse.M_Rownnz (I)) - 1) = I
      and then (if M.Dofs.Dof_Simplenum (I) = 0 and then M.Dofs.Dof_Parentid (I) >= 0 then
                  M.Dofs.Dof_Parentid (I) < M.S.Nv
                  and then M.Dofs.Dof_Simplenum (M.Dofs.Dof_Parentid (I)) = 0
                  and then M.Sparse.M_Rownnz (M.Dofs.Dof_Parentid (I)) in 0 .. M.S.Nc
                  and then M.Sparse.M_Rowadr (M.Dofs.Dof_Parentid (I)) in
                    0 .. M.S.Nc - M.Sparse.M_Rownnz (M.Dofs.Dof_Parentid (I))
                  and then M.Sparse.M_Rownnz (I) - 1 <= M.Sparse.M_Rownnz (M.Dofs.Dof_Parentid (I))
                  and then (for all K in 0 .. M.Sparse.M_Rownnz (I) - 2 =>
                     M.Sparse.M_Colind (M.Sparse.M_Rowadr (I) + K) =
                     M.Sparse.M_Colind (M.Sparse.M_Rowadr (M.Dofs.Dof_Parentid (I)) + K))))
   with Pre => Valid_Layout (M) and then I in 0 .. M.S.Nv - 1;

   function M_Rows_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nv - 1 => M_Row_At (M, I))
   with Pre => Valid_Layout (M);

   function D_Diag_At (M : Model; I : Integer) return Boolean is
     (M.Sparse.D_Diag (I) in 0 .. M.Sparse.D_Rownnz (I) - 1
      and then M.Sparse.D_Colind (M.Sparse.D_Rowadr (I) + M.Sparse.D_Diag (I)) = I)
   with Pre => Valid_Layout (M) and then Sparse_D_OK (M) and then I in 0 .. M.S.Nv - 1;

   function D_Diags_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nv - 1 => D_Diag_At (M, I))
   with Pre => Valid_Layout (M) and then Sparse_D_OK (M);

   --  mapM2M: CSR entry (nC) -> legacy qM index; mapM2D: symmetric D entry (nD) ->
   --  CSR entry or -1; mapD2M: CSR entry (nC) -> D entry, inverse of mapM2D.
   function Maps_OK (M : Model) return Boolean is
     ((for all K in 0 .. M.S.Nc - 1 => M.Sparse.MapM2M (K) in 0 .. M.S.Nm - 1)
      and then (for all K in 0 .. M.S.Nd - 1 => M.Sparse.MapM2D (K) in -1 .. M.S.Nc - 1)
      and then (for all K in 0 .. M.S.Nc - 1 => M.Sparse.MapD2M (K) in 0 .. M.S.Nd - 1)
      and then (for all K in 0 .. M.S.Nc - 1 => M.Sparse.MapM2D (M.Sparse.MapD2M (K)) = K))
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

   --  MuJoCo 3.14 checks the mesh reference only for mesh sites, including
   --  the -1 sentinel. Other site types do not dereference this field.
   function Site_Data_At (M : Model; S : Integer) return Boolean is
     (if M.Sites.Site_Type (S) = 7 then
        M.Sites.Site_Dataid (S) in -1 .. M.S.Nmesh - 1)
   with Pre => Valid_Layout (M) and then S in 0 .. M.S.Nsite - 1;

   function Site_Datas_OK (M : Model) return Boolean is
     (for all S in 0 .. M.S.Nsite - 1 => Site_Data_At (M, S))
   with Pre => Valid_Layout (M);

   function Sameframes_OK (M : Model) return Boolean is
     ((for all I in 0 .. M.S.Nbody - 1 => M.Bodies.Body_Sameframe (I) <= 4)
      and then (for all G in 0 .. M.S.Ngeom - 1 => M.Geoms.Geom_Sameframe (G) <= 4)
      and then (for all S in 0 .. M.S.Nsite - 1 => M.Sites.Site_Sameframe (S) <= 4))
   with Pre => Valid_Layout (M);

   --  Face vertex, normal, and texcoord indexes are local to the mesh.
   function Mesh_Faces_At (M : Model; I : Integer) return Boolean is
     (Ref_Mesh_Faceadr_At (M, I)
      and then Ref_Mesh_Vertadr_At (M, I)
      and then Ref_Mesh_Normaladr_At (M, I)
      and then Ref_Mesh_Texcoordadr_At (M, I)
      and then (for all F in M.Meshes.Mesh_Faceadr (I) .. (M.Meshes.Mesh_Faceadr (I) + M.Meshes.Mesh_Facenum (I)) - 1 =>
        (for all K in 0 .. 2 =>
           M.Meshes.Mesh_Face (3 * F + K) in 0 .. M.Meshes.Mesh_Vertnum (I) - 1
           and then (if M.Meshes.Mesh_Normalnum (I) > 0 then
                       M.Meshes.Mesh_Facenormal (3 * F + K) in 0 .. M.Meshes.Mesh_Normalnum (I) - 1)
           and then (if M.Meshes.Mesh_Texcoordadr (I) >= 0 and then M.Meshes.Mesh_Texcoordnum (I) > 0 then
                       M.Meshes.Mesh_Facetexcoord (3 * F + K) in 0 .. M.Meshes.Mesh_Texcoordnum (I) - 1))))
   with Pre => Valid_Layout (M) and then I in 0 .. M.S.Nmesh - 1;

   --  Polygon vertex lists index the mesh's vertices; the per-vertex polygon map
   --  indexes the mesh's polygons.
   function Mesh_Polys_At (M : Model; I : Integer) return Boolean is
     (Ref_Mesh_Polyadr_At (M, I) and then Ref_Mesh_Vertadr_At (M, I)
      and then (for all P in M.Meshes.Mesh_Polyadr (I) .. (M.Meshes.Mesh_Polyadr (I) + M.Meshes.Mesh_Polynum (I)) - 1 =>
         Ref_Mesh_Polyvertadr_At (M, P)
         and then (for all K in M.Meshes.Mesh_Polyvertadr (P) ..
                       (M.Meshes.Mesh_Polyvertadr (P) + M.Meshes.Mesh_Polyvertnum (P)) - 1 =>
            M.Meshes.Mesh_Polyvert (K) in 0 .. M.Meshes.Mesh_Vertnum (I) - 1))
      and then (for all V in M.Meshes.Mesh_Vertadr (I) .. (M.Meshes.Mesh_Vertadr (I) + M.Meshes.Mesh_Vertnum (I)) - 1 =>
                  Ref_Mesh_Polymapadr_At (M, V)
                  and then (for all K in M.Meshes.Mesh_Polymapadr (V) ..
                                (M.Meshes.Mesh_Polymapadr (V) + M.Meshes.Mesh_Polymapnum (V)) - 1 =>
                     M.Meshes.Mesh_Polymap (K) in 0 .. M.Meshes.Mesh_Polynum (I) - 1)))
   with Pre => Valid_Layout (M) and then I in 0 .. M.S.Nmesh - 1;

   --  Convex hull graph block (user_mesh.cc MakeGraph): numvert, numface,
   --  vert_edgeadr[numvert], vert_globalid[numvert], edge_localid[numvert+3*numface]
   --  terminated by -1 runs, face_globalid[3*numface]. Blocks must fit before
   --  the end of mesh_graph; the engine walks edge lists until a -1, so the
   --  last edge entry must be -1.
   function Graph_Block_At (M : Model; I, A, Nv, Nf : Integer) return Boolean is
     (((Int64 (A) + 2) + 3 * Int64 (Nv)) + 6 * Int64 (Nf) <= Int64 (M.S.Nmeshgraph)
      and then (declare
        Ne : constant Integer := Nv + 3 * Nf;
      begin
        (for all K in 0 .. Nv - 1 => M.Meshes.Mesh_Graph ((A + 2) + K) in 0 .. Ne - 1)
        and then (for all K in 0 .. Nv - 1 =>
                    M.Meshes.Mesh_Graph (((A + 2) + Nv) + K) in 0 .. M.Meshes.Mesh_Vertnum (I) - 1)
        and then (for all K in 0 .. Ne - 1 => M.Meshes.Mesh_Graph (((A + 2) + 2 * Nv) + K) in -1 .. Nv - 1)
        and then (Ne = 0 or else M.Meshes.Mesh_Graph ((((A + 2) + 2 * Nv) + Ne) - 1) = -1)
        and then (for all K in 0 .. 3 * Nf - 1 =>
                    M.Meshes.Mesh_Graph ((((A + 2) + 3 * Nv) + 3 * Nf) + K) in 0 .. M.Meshes.Mesh_Vertnum (I) - 1)))
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
   with Pre => Valid_Layout (M) and then I in 0 .. M.S.Nmesh - 1;

   function Meshes_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nmesh - 1 =>
        Mesh_Faces_At (M, I) and then Mesh_Polys_At (M, I) and then Mesh_Graph_At (M, I))
   with Pre => Valid_Layout (M);

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

   --  With nonnegative sizes and positive channels, this division is exactly
   --  equivalent to Adr + Channels * Height * Width <= Length. It avoids
   --  forming the larger product while checking an untrusted texture.
   function Texture_Block_OK
     (Adr : Int64; Channels, Height, Width : Integer; Length : Size_Type) return Boolean is
     (Channels in 1 .. 4 and then Height >= 0 and then Width >= 0
      and then Adr in 0 .. Int64 (Length)
      and then Int64 (Height) * Int64 (Width) <= (Int64 (Length) - Adr) / Int64 (Channels))
   with Global => null;

   function Texture_At (M : Model; T : Integer) return Boolean is
     (Texture_Block_OK (M.Textures.Tex_Adr (T), M.Textures.Tex_Nchannel (T),
                        M.Textures.Tex_Height (T), M.Textures.Tex_Width (T), M.S.Ntexdata))
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
     (Ref_Body_Bvhadr_At (M, B)
      and then (if M.Bodies.Body_Bvhnum (B) > 0 then
        (for all L in 0 .. M.Bodies.Body_Bvhnum (B) - 1 =>
           Bvh_Node_At (M, M.Bodies.Body_Bvhadr (B), M.Bodies.Body_Bvhnum (B), L)
           and then (if M.Bvh.Bvh_Nodeid (M.Bodies.Body_Bvhadr (B) + L) >= 0 then
                       M.Bvh.Bvh_Nodeid (M.Bodies.Body_Bvhadr (B) + L) in 0 .. M.S.Ngeom - 1
                       and then M.Geoms.Geom_Bodyid (M.Bvh.Bvh_Nodeid (M.Bodies.Body_Bvhadr (B) + L)) = B))))
   with Pre => Valid_Layout (M) and then B in 0 .. M.S.Nbody - 1;

   function Mesh_Bvh_At (M : Model; I : Integer) return Boolean is
     (Ref_Mesh_Bvhadr_At (M, I) and then Ref_Mesh_Faceadr_At (M, I)
      and then (if M.Meshes.Mesh_Bvhnum (I) > 0 then
        (for all L in 0 .. M.Meshes.Mesh_Bvhnum (I) - 1 =>
           Bvh_Node_At (M, M.Meshes.Mesh_Bvhadr (I), M.Meshes.Mesh_Bvhnum (I), L)
           and then (if M.Bvh.Bvh_Nodeid (M.Meshes.Mesh_Bvhadr (I) + L) >= 0 then
                       M.Bvh.Bvh_Nodeid (M.Meshes.Mesh_Bvhadr (I) + L) in 0 .. M.Meshes.Mesh_Facenum (I) - 1))))
   with Pre => Valid_Layout (M) and then I in 0 .. M.S.Nmesh - 1;

   function Bvhs_OK (M : Model) return Boolean is
     ((for all B in 0 .. M.S.Nbody - 1 => Body_Bvh_At (M, B))
      and then (for all I in 0 .. M.S.Nmesh - 1 => Mesh_Bvh_At (M, I)))
   with Pre => Valid_Layout (M);

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
   --  5.7 Pairs, excludes, equalities, tendons, wraps
   ----------------------------------------------------------------------------

   function Pair_Dim_At (M : Model; P : Integer) return Boolean is
     (M.Pairs.Pair_Dim (P) in 1 | 3 | 4 | 6)
   with Pre => Valid_Layout (M) and then P in 0 .. M.S.Npair - 1;

   --  Interpret the signed storage as unsigned 32-bit bits, without an
   --  unchecked conversion. MuJoCo 3.14 uses an unsigned upper-body shift.
   function Signature_Bits (Signature : Integer) return Int64 is
     (if Signature < 0 then Int64 (Signature) + 2**32 else Int64 (Signature))
   with Post => Signature_Bits'Result in 0 .. 2**32 - 1
                and then Signature_Bits'Result mod 2**32 = Int64 (Signature) mod 2**32;

   function Signature_Low (Signature : Integer) return Integer is
     (Integer (Signature_Bits (Signature) mod 2**16))
   with Post => Signature_Low'Result in 0 .. 2**16 - 1;

   function Signature_High (Signature : Integer) return Integer is
     (Integer (Signature_Bits (Signature) / 2**16))
   with Post => Signature_High'Result in 0 .. 2**16 - 1
                and then Int64 (Signature_High'Result) * 2**16
                  + Int64 (Signature_Low (Signature)) = Signature_Bits (Signature);

   --  The compiler packs body(geom1) in the high half and body(geom2) in
   --  the low half. Retain the port's stronger check against the actual geoms.
   function Pair_Signature_At (M : Model; P : Integer) return Boolean is
     (M.Pairs.Pair_Geom1 (P) in 0 .. M.S.Ngeom - 1
      and then M.Pairs.Pair_Geom2 (P) in 0 .. M.S.Ngeom - 1
      and then M.Geoms.Geom_Bodyid (M.Pairs.Pair_Geom1 (P)) in 0 .. M.S.Nbody - 1
      and then M.Geoms.Geom_Bodyid (M.Pairs.Pair_Geom2 (P)) in 0 .. M.S.Nbody - 1
      and then Signature_High (M.Pairs.Pair_Signature (P)) =
        M.Geoms.Geom_Bodyid (M.Pairs.Pair_Geom1 (P))
      and then Signature_Low (M.Pairs.Pair_Signature (P)) =
        M.Geoms.Geom_Bodyid (M.Pairs.Pair_Geom2 (P)))
   with Pre => Valid_Layout (M) and then P in 0 .. M.S.Npair - 1;

   function Pairs_OK (M : Model) return Boolean is
     ((for all P in 0 .. M.S.Npair - 1 => Pair_Dim_At (M, P))
      and then (for all P in 0 .. M.S.Npair - 1 => Pair_Signature_At (M, P)))
   with Pre => Valid_Layout (M);

   function Exclude_At (M : Model; E : Integer) return Boolean is
     (Signature_High (M.Excludes.Exclude_Signature (E)) in 0 .. M.S.Nbody - 1
      and then Signature_Low (M.Excludes.Exclude_Signature (E)) in 0 .. M.S.Nbody - 1
      and then Signature_High (M.Excludes.Exclude_Signature (E)) /=
        Signature_Low (M.Excludes.Exclude_Signature (E)))
   with Pre => Valid_Layout (M) and then E in 0 .. M.S.Nexclude - 1;

   function Excludes_OK (M : Model) return Boolean is
     (for all E in 0 .. M.S.Nexclude - 1 => Exclude_At (M, E))
   with Pre => Valid_Layout (M);

   function Eq_Types_OK (M : Model) return Boolean is
     (for all E in 0 .. M.S.Neq - 1 => M.Equalities.Eq_Type (E) in 0 .. 3)   --  flex kinds need nflex > 0
   with Pre => Valid_Layout (M);

   function Eq_Obj_At (M : Model; E : Integer) return Boolean is
     (case M.Equalities.Eq_Type (E) is
        when 0 | 1 =>
          (M.Equalities.Eq_Objtype (E) = 1
             and then M.Equalities.Eq_Obj1id (E) in 0 .. M.S.Nbody - 1
             and then M.Equalities.Eq_Obj2id (E) in 0 .. M.S.Nbody - 1)
          or else
          (M.Equalities.Eq_Objtype (E) = 6
             and then M.Equalities.Eq_Obj1id (E) in 0 .. M.S.Nsite - 1
             and then M.Equalities.Eq_Obj2id (E) in 0 .. M.S.Nsite - 1),
        when 2 =>
          M.Equalities.Eq_Obj1id (E) in 0 .. M.S.Njnt - 1
          and then M.Equalities.Eq_Obj2id (E) in -1 .. M.S.Njnt - 1,
        when others =>
          M.Equalities.Eq_Obj1id (E) in 0 .. M.S.Ntendon - 1
          and then M.Equalities.Eq_Obj2id (E) in -1 .. M.S.Ntendon - 1)
   with Pre => Valid_Layout (M) and then Eq_Types_OK (M) and then E in 0 .. M.S.Neq - 1;

   function Eq_Objs_OK (M : Model) return Boolean is
     (for all E in 0 .. M.S.Neq - 1 => Eq_Obj_At (M, E))
   with Pre => Valid_Layout (M) and then Eq_Types_OK (M);

   function Wrap_At (M : Model; W : Integer) return Boolean is
     (M.Wraps.Wrap_Type (W) in 0 .. 5
      and then (case M.Wraps.Wrap_Type (W) is
                  when 1      => M.Wraps.Wrap_Objid (W) in 0 .. M.S.Njnt - 1,
                  when 3      => M.Wraps.Wrap_Objid (W) in 0 .. M.S.Nsite - 1,
                  when 4 | 5  => M.Wraps.Wrap_Objid (W) in 0 .. M.S.Ngeom - 1,
                  when others => True))
   with Pre => Valid_Layout (M) and then W in 0 .. M.S.Nwrap - 1;

   function Wraps_OK (M : Model) return Boolean is
     (for all W in 0 .. M.S.Nwrap - 1 => Wrap_At (M, W))
   with Pre => Valid_Layout (M);

   --  A tendon is spatial (site and geom wraps, pulleys allowed) or fixed
   --  (joint wraps only), decided by its first wrap.
   function Tendon_At (M : Model; T : Integer) return Boolean is
     (Ref_Tendon_Adr_At (M, T)
      and then M.Tendons.Tendon_Num (T) >= 1
      and then M.Tendons.Tendon_Actuatorid (T) in -1 .. M.S.Nactuator - 1
      and then M.Tendons.Tendon_Treenum (T) >= 0   --  counts every tree on the path; only two ids are stored
      and then (if M.Wraps.Wrap_Type (M.Tendons.Tendon_Adr (T)) = 3 then
                  (for all W in M.Tendons.Tendon_Adr (T) .. (M.Tendons.Tendon_Adr (T) + M.Tendons.Tendon_Num (T)) - 1 =>
                     M.Wraps.Wrap_Type (W) in 2 .. 5)
                else
                  (for all W in M.Tendons.Tendon_Adr (T) .. (M.Tendons.Tendon_Adr (T) + M.Tendons.Tendon_Num (T)) - 1 =>
                     M.Wraps.Wrap_Type (W) = 1)))
   with Pre => Valid_Layout (M) and then T in 0 .. M.S.Ntendon - 1;

   function Tendons_OK (M : Model) return Boolean is
     (for all T in 0 .. M.S.Ntendon - 1 => Tendon_At (M, T))
   with Pre => Valid_Layout (M);

   ----------------------------------------------------------------------------
   --  5.8 Actuators and sensors
   ----------------------------------------------------------------------------

   function Actuator_Type_At (M : Model; A : Integer) return Boolean is
     ((M.Actuators.Actuator_Trntype (A) in 0 .. 6 or else M.Actuators.Actuator_Trntype (A) = 1000)
      and then M.Actuators.Actuator_Dyntype (A) in 0 .. 7
      and then M.Actuators.Actuator_Gaintype (A) in 0 .. 6
      and then M.Actuators.Actuator_Biastype (A) in 0 .. 5)
   with Pre => Valid_Layout (M) and then A in 0 .. M.S.Nactuator - 1;

   function Actuator_Types_OK (M : Model) return Boolean is
     (for all A in 0 .. M.S.Nactuator - 1 => Actuator_Type_At (M, A))
   with Pre => Valid_Layout (M);

   function Actuator_Trnid_At (M : Model; A : Integer) return Boolean is
     (case M.Actuators.Actuator_Trntype (A) is
        when 0 | 1 => M.Actuators.Actuator_Trnid (2 * A) in 0 .. M.S.Njnt - 1,
        when 2     => M.Actuators.Actuator_Trnid (2 * A) in 0 .. M.S.Nsite - 1
                      and then M.Actuators.Actuator_Trnid (2 * A + 1) in 0 .. M.S.Nsite - 1,
        when 3     => M.Actuators.Actuator_Trnid (2 * A) in 0 .. M.S.Ntendon - 1,
        when 4     => M.Actuators.Actuator_Trnid (2 * A) in 0 .. M.S.Nsite - 1,
        when 5     => M.Actuators.Actuator_Trnid (2 * A) in 0 .. M.S.Nbody - 1,
        when 6     => (if M.Actuators.Actuator_Trnid (2 * A + 1) = -1
                       then M.Actuators.Actuator_Trnid (2 * A) in 0 .. M.S.Njnt - 1
                       else M.Actuators.Actuator_Trnid (2 * A) in 0 .. M.S.Nsite - 1
                            and then M.Actuators.Actuator_Trnid (2 * A + 1) in 0 .. M.S.Nsite - 1),
        when others => True)
   with Pre => Valid_Layout (M) and then Actuator_Types_OK (M) and then A in 0 .. M.S.Nactuator - 1;

   function Actuator_Trnids_OK (M : Model) return Boolean is
     (for all A in 0 .. M.S.Nactuator - 1 => Actuator_Trnid_At (M, A))
   with Pre => Valid_Layout (M) and then Actuator_Types_OK (M);

   --  Stateless actuators have no activation slot; every actuator has at least
   --  one control and one force output.
   function Actuator_Act_At (M : Model; A : Integer) return Boolean is
     ((M.Actuators.Actuator_Actnum (A) > 0) = (M.Actuators.Actuator_Dyntype (A) /= 0)
      and then M.Actuators.Actuator_Ctrlnum (A) >= 1
      and then M.Actuators.Actuator_Outnum (A) >= 1)
   with Pre => Valid_Layout (M) and then A in 0 .. M.S.Nactuator - 1;

   function Actuator_Acts_OK (M : Model) return Boolean is
     (for all A in 0 .. M.S.Nactuator - 1 => Actuator_Act_At (M, A))
   with Pre => Valid_Layout (M);

   --  Control limits are indexed by channel (nu), unlike force/activation
   --  limits which are indexed by actuator (nactuator).
   function Control_Range_At (M : Model; C : Integer) return Boolean is
     (if M.Actuators.Actuator_Ctrllimited (C) /= 0 then
         M.Actuators.Actuator_Ctrlrange (2 * C) <= M.Actuators.Actuator_Ctrlrange (2 * C + 1))
   with Pre => Valid_Layout (M) and then C in 0 .. M.S.Nu - 1;

   function Actuator_Range_At (M : Model; A : Integer) return Boolean is
     ((if M.Actuators.Actuator_Forcelimited (A) /= 0 then
                  M.Actuators.Actuator_Forcerange (2 * A) <= M.Actuators.Actuator_Forcerange (2 * A + 1))
      and then (if M.Actuators.Actuator_Actlimited (A) /= 0 then
                  M.Actuators.Actuator_Actrange (2 * A) <= M.Actuators.Actuator_Actrange (2 * A + 1)))
   with Pre => Valid_Layout (M) and then A in 0 .. M.S.Nactuator - 1;

   function Actuator_Ranges_OK (M : Model) return Boolean is
     ((for all C in 0 .. M.S.Nu - 1 => Control_Range_At (M, C))
      and then (for all A in 0 .. M.S.Nactuator - 1 => Actuator_Range_At (M, A)))
   with Pre => Valid_Layout (M);

   --  sensorSize in engine_io.c, by mjtSensor code.
   function Sensor_Size (Sensor_Type, Dim : Integer) return Integer is
     (case Sensor_Type is
        when 0 | 7 | 9 .. 17 | 20 .. 25 | 38 | 39 | 43 .. 45 => 1,
        when 8                                               => 2,
        when 1 .. 6 | 19 | 26 | 28 .. 37 | 40                => 3,
        when 18 | 27                                         => 4,
        when 41                                              => 6,
        when 42 | 46 | 48                                    => Dim,
        when others                                          => -1);

   --  numObjects in engine_io.c: -1 means "no object check", -2 an invalid type.
   function Num_Objects (M : Model; Obj_Type : Integer) return Integer is
     (case Obj_Type is
        when 0 | 100 | 101 | 102 => -1,
        when 1 | 2 => M.S.Nbody,   when 3  => M.S.Njnt,      when 4  => M.S.Nv,
        when 5  => M.S.Ngeom,      when 6  => M.S.Nsite,     when 7  => M.S.Ncam,
        when 8  => M.S.Nlight,     when 9  => M.S.Nflex,     when 10 => M.S.Nmesh,
        when 11 => M.S.Nskin,      when 12 => M.S.Nhfield,   when 13 => M.S.Ntex,
        when 14 => M.S.Nmat,       when 15 => M.S.Npair,     when 16 => M.S.Nexclude,
        when 17 => M.S.Neq,        when 18 => M.S.Ntendon,   when 19 => M.S.Nactuator,
        when 20 => M.S.Nsensor,    when 21 => M.S.Nnumeric,  when 22 => M.S.Ntext,
        when 23 => M.S.Ntuple,     when 24 => M.S.Nkey,      when 25 => M.S.Nplugin,
        when others => -2);

   function Sensor_Type_At (M : Model; S : Integer) return Boolean is
     ((M.Sensors.Sensor_Type (S) in 0 .. 46 or else M.Sensors.Sensor_Type (S) = 48)   --  47 = plugin
      and then M.Sensors.Sensor_Datatype (S) in 0 .. 3
      and then M.Sensors.Sensor_Needstage (S) in 0 .. 3)
   with Pre => Valid_Layout (M) and then S in 0 .. M.S.Nsensor - 1;

   function Sensor_Types_OK (M : Model) return Boolean is
     (for all S in 0 .. M.S.Nsensor - 1 => Sensor_Type_At (M, S))
   with Pre => Valid_Layout (M);

   function Sensor_Obj_At (M : Model; S : Integer) return Boolean is
     (Num_Objects (M, M.Sensors.Sensor_Objtype (S)) /= -2
      and then (if Num_Objects (M, M.Sensors.Sensor_Objtype (S)) /= -1 then
                  M.Sensors.Sensor_Objid (S) in 0 .. Num_Objects (M, M.Sensors.Sensor_Objtype (S)) - 1)
      and then Num_Objects (M, M.Sensors.Sensor_Reftype (S)) /= -2
      and then (if Num_Objects (M, M.Sensors.Sensor_Reftype (S)) /= -1 then
                  M.Sensors.Sensor_Refid (S) in -1 .. Num_Objects (M, M.Sensors.Sensor_Reftype (S)) - 1)
      --  tactile sensors reference a geom whose body has a collision geom
      and then (if M.Sensors.Sensor_Type (S) = 46 then
                  M.Sensors.Sensor_Reftype (S) = 5
                  and then M.Sensors.Sensor_Refid (S) in 0 .. M.S.Ngeom - 1
                  and then (declare
                              B : constant Integer := M.Geoms.Geom_Bodyid (M.Sensors.Sensor_Refid (S));
                            begin
                              (for some K in M.Bodies.Body_Geomadr (B) ..
                                             (M.Bodies.Body_Geomadr (B) + M.Bodies.Body_Geomnum (B)) - 1 =>
                                 M.Geoms.Geom_Contype (K) /= 0 or else M.Geoms.Geom_Conaffinity (K) /= 0))))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Body_Geoms_OK (M)
               and then S in 0 .. M.S.Nsensor - 1;

   function Sensor_Objs_OK (M : Model) return Boolean is
     (for all S in 0 .. M.S.Nsensor - 1 => Sensor_Obj_At (M, S))
   with Pre => Valid_Layout (M) and then Sizes_OK (M) and then Body_Geoms_OK (M);

   function Sensor_Dims_OK (M : Model) return Boolean is
     (for all S in 0 .. M.S.Nsensor - 1 =>
        M.Sensors.Sensor_Dim (S) in 0 .. M.S.Nsensordata
        and then M.Sensors.Sensor_Dim (S) = Sensor_Size (M.Sensors.Sensor_Type (S), M.Sensors.Sensor_Dim (S)))
   with Pre => Valid_Layout (M) and then Sensor_Types_OK (M);

   function Sensor_Adr_At (M : Model; S : Integer) return Boolean is
     (M.Sensors.Sensor_Adr (S) in 0 .. M.S.Nsensordata
      and then (if S = 0 then M.Sensors.Sensor_Adr (0) = 0
                else M.Sensors.Sensor_Adr (S - 1) in 0 .. M.S.Nsensordata
                     and then M.Sensors.Sensor_Adr (S) = M.Sensors.Sensor_Adr (S - 1) + M.Sensors.Sensor_Dim (S - 1)))
   with Pre => Valid_Layout (M) and then Sensor_Types_OK (M) and then Sensor_Dims_OK (M)
               and then S in 0 .. M.S.Nsensor - 1;

   function Sensor_Adrs_OK (M : Model) return Boolean is
     ((for all S in 0 .. M.S.Nsensor - 1 => Sensor_Adr_At (M, S))
      and then (if M.S.Nsensor = 0 then M.S.Nsensordata = 0
                else M.Sensors.Sensor_Adr (M.S.Nsensor - 1) + M.Sensors.Sensor_Dim (M.S.Nsensor - 1) = M.S.Nsensordata))
   with Pre => Valid_Layout (M) and then Sensor_Types_OK (M) and then Sensor_Dims_OK (M);

   ----------------------------------------------------------------------------
   --  5.9 Tuples, names, paths (numeric and text blocks are covered by Refs_OK)
   ----------------------------------------------------------------------------

   function Tuples_OK (M : Model) return Boolean is
     (for all K in 0 .. M.S.Ntupledata - 1 =>
        Num_Objects (M, M.Tuples.Tuple_Objtype (K)) /= -2
        and then (if Num_Objects (M, M.Tuples.Tuple_Objtype (K)) /= -1 then
                    M.Tuples.Tuple_Objid (K) in 0 .. Num_Objects (M, M.Tuples.Tuple_Objtype (K)) - 1))
   with Pre => Valid_Layout (M);

   --  names is a sequence of NUL-terminated strings ending with NUL, so every
   --  address the reference table allows (0 .. nnames - 1) reaches a NUL.
   function Names_OK (M : Model) return Boolean is
     (M.S.Nnames >= 1 and then M.Names.Names (M.S.Nnames - 1) = 0)
   with Pre => Valid_Layout (M);

   function Paths_OK (M : Model) return Boolean is
     (M.S.Npaths = 0 or else M.Names.Paths (M.S.Npaths - 1) = 0)
   with Pre => Valid_Layout (M);

   ----------------------------------------------------------------------------
   --  5.10 Parameter sanity. Only facts the compiler guarantees and a later
   --  proof needs: signs of masses, inertias, damping and friction; unit
   --  quaternions and axes; positive timestep and statistics. Solver
   --  impedance and reference parameters are clamped by the engine at use, as
   --  in C, so they are not constrained here.
   ----------------------------------------------------------------------------

   function In_Tier0 (X : Real) return Boolean is (X in Tier0_Real);

   function Squared_Norm4 (A, B, C, D : Tier0_Real) return Tier1_Real is
     (((A * A + B * B) + C * C) + D * D)
   with Global => null;

   function Squared_Norm3 (A, B, C : Tier0_Real) return Tier1_Real is
     ((A * A + B * B) + C * C)
   with Global => null;

   function Unit_Quat (Q : Real_Array; Pos : Integer) return Boolean is
     ((for all K in Pos .. Pos + 3 => Q (K) in Tier0_Real)
      and then abs (Squared_Norm4 (Q (Pos), Q (Pos + 1), Q (Pos + 2), Q (Pos + 3)) - 1.0)
      <= 1.0e-6)
   with Pre => Pos in Q'Range and then Pos <= Q'Last - 3;

   function Unit_Vec3 (V : Real_Array; Pos : Integer) return Boolean is
     ((for all K in Pos .. Pos + 2 => V (K) in Tier0_Real)
      and then abs (Squared_Norm3 (V (Pos), V (Pos + 1), V (Pos + 2)) - 1.0) <= 1.0e-6)
   with Pre => Pos in V'Range and then Pos <= V'Last - 2;

   --  mj_checkDiscrete constraints for the supported non-flex model subset.
   --  Positive modulus extracts each bit even from signed flag storage.
   function Discrete_Options_OK (M : Model) return Boolean is
     ((if M.Opt.Enableflags mod (2 * Enbl_Ipc) >= Enbl_Ipc then
         M.Opt.Integrator = Integrator_Kind'Pos (Int_Discrete)
         and then M.Opt.Solver = Solver_Kind'Pos (Sol_Cg)
         and then M.Opt.Enableflags mod (2 * Enbl_Fwdinv) < Enbl_Fwdinv
         and then M.Opt.Enableflags mod (2 * Enbl_Sleep) < Enbl_Sleep)
      and then (if M.Opt.Integrator = Integrator_Kind'Pos (Int_Discrete)
                   and then M.Opt.Enableflags mod (2 * Enbl_Sleep) >= Enbl_Sleep
                then M.Opt.Disableflags mod (2 * Dsbl_Island) < Dsbl_Island));

   function Option_OK (M : Model) return Boolean is
     (In_Tier0 (M.Opt.Timestep) and then M.Opt.Timestep > 0.0
      and then In_Tier0 (M.Opt.Impratio) and then M.Opt.Impratio > 0.0
      and then In_Tier0 (M.Opt.Tolerance) and then M.Opt.Tolerance >= 0.0
      and then In_Tier0 (M.Opt.Ls_Tolerance) and then M.Opt.Ls_Tolerance >= 0.0
      and then In_Tier0 (M.Opt.Noslip_Tolerance) and then M.Opt.Noslip_Tolerance >= 0.0
      and then In_Tier0 (M.Opt.Ccd_Tolerance) and then M.Opt.Ccd_Tolerance >= 0.0
      and then In_Tier0 (M.Opt.Sleep_Tolerance) and then M.Opt.Sleep_Tolerance >= 0.0
      and then (for all K in 0 .. 2 => In_Tier0 (M.Opt.Gravity (K)))
      and then (for all K in 0 .. 2 => In_Tier0 (M.Opt.Wind (K)))
      and then (for all K in 0 .. 2 => In_Tier0 (M.Opt.Magnetic (K)))
      and then In_Tier0 (M.Opt.Density) and then M.Opt.Density >= 0.0
      and then In_Tier0 (M.Opt.Viscosity) and then M.Opt.Viscosity >= 0.0
      and then In_Tier0 (M.Opt.O_Margin)
      and then (for all K in 0 .. 1 => In_Tier0 (M.Opt.O_Solref (K)))
      and then (for all K in 0 .. 4 => In_Tier0 (M.Opt.O_Solimp (K)))
      and then (for all K in 0 .. 4 => In_Tier0 (M.Opt.O_Friction (K)))
      and then M.Opt.Integrator in 0 .. Integrator_Kind'Pos (Integrator_Kind'Last)
      and then Discrete_Options_OK (M)
      and then M.Opt.Cone in 0 .. 1
      and then M.Opt.Jacobian in 0 .. 2 and then M.Opt.Solver in 0 .. 2
      and then M.Opt.Iterations >= 0 and then M.Opt.Ls_Iterations >= 0
      and then M.Opt.Noslip_Iterations >= 0 and then M.Opt.Ccd_Iterations >= 0
      and then M.Opt.Sdf_Initpoints >= 0 and then M.Opt.Sdf_Iterations >= 0);

   function Stat_OK (M : Model) return Boolean is
     (In_Tier0 (M.Stat.Meaninertia) and then M.Stat.Meaninertia > 0.0
      and then In_Tier0 (M.Stat.Meanmass) and then M.Stat.Meanmass > 0.0
      and then In_Tier0 (M.Stat.Meansize) and then M.Stat.Meansize > 0.0
      and then In_Tier0 (M.Stat.Extent) and then M.Stat.Extent > 0.0
      and then (for all K in 0 .. 2 => In_Tier0 (M.Stat.Center (K))));

   function Body_Param_At (M : Model; I : Integer) return Boolean is
     (M.Bodies.Body_Mass (I) >= 0.0
      and then M.Bodies.Body_Subtreemass (I) >= M.Bodies.Body_Mass (I)
      and then (for all K in 0 .. 2 => M.Bodies.Body_Inertia (3 * I + K) >= 0.0)
      and then M.Bodies.Body_Invweight0 (2 * I) >= 0.0 and then M.Bodies.Body_Invweight0 (2 * I + 1) >= 0.0
      and then Unit_Quat (M.Bodies.Body_Quat.all, 4 * I)
      and then Unit_Quat (M.Bodies.Body_Iquat.all, 4 * I))
   with Pre => Valid_Layout (M) and then I in 0 .. M.S.Nbody - 1;

   function Body_Params_OK (M : Model) return Boolean is
     (for all I in 0 .. M.S.Nbody - 1 => Body_Param_At (M, I))
   with Pre => Valid_Layout (M);

   function Jnt_Param_At (M : Model; J : Integer) return Boolean is
     ((if M.Joints.Jnt_Type (J) in 2 | 3 then Unit_Vec3 (M.Joints.Jnt_Axis.all, 3 * J))
      and then M.Joints.Jnt_Margin (J) >= 0.0)
   with Pre => Valid_Layout (M) and then Jnt_Types_OK (M)
               and then J in 0 .. M.S.Njnt - 1;

   function Jnt_Params_OK (M : Model) return Boolean is
     (for all J in 0 .. M.S.Njnt - 1 => Jnt_Param_At (M, J))
   with Pre => Valid_Layout (M) and then Jnt_Types_OK (M);

   function Geom_Param_At (M : Model; G : Integer) return Boolean is
     ((for all K in 0 .. 2 =>
         (if M.Geoms.Geom_Type (G) /= 0 or else K = 2 then
            M.Geoms.Geom_Size (3 * G + K) >= 0.0))
      and then M.Geoms.Geom_Rbound (G) >= 0.0
      and then M.Geoms.Geom_Margin (G) >= 0.0 and then M.Geoms.Geom_Gap (G) >= 0.0
      and then Unit_Quat (M.Geoms.Geom_Quat.all, 4 * G))
   with Pre => Valid_Layout (M) and then G in 0 .. M.S.Ngeom - 1;

   function Geom_Params_OK (M : Model) return Boolean is
     ((for all G in 0 .. M.S.Ngeom - 1 => Geom_Param_At (M, G))
      and then (for all S in 0 .. M.S.Nsite - 1 => Unit_Quat (M.Sites.Site_Quat.all, 4 * S))
      and then (for all C in 0 .. M.S.Ncam - 1 => Unit_Quat (M.Cameras.Cam_Quat.all, 4 * C))
      and then (for all I in 0 .. M.S.Nmesh - 1 => Unit_Quat (M.Meshes.Mesh_Quat.all, 4 * I)))
   with Pre => Valid_Layout (M);

   function Dof_Params_OK (M : Model) return Boolean is
     (for all D in 0 .. M.S.Nv - 1 =>
        M.Dofs.Dof_Armature (D) >= 0.0 and then M.Dofs.Dof_Damping (D) >= 0.0
        and then M.Dofs.Dof_Frictionloss (D) >= 0.0 and then M.Dofs.Dof_Invweight0 (D) >= 0.0
        and then M.Dofs.Dof_M0 (D) >= 0.0)
   with Pre => Valid_Layout (M);

   function Tendon_Params_OK (M : Model) return Boolean is
     (for all T in 0 .. M.S.Ntendon - 1 =>
        M.Tendons.Tendon_Stiffness (T) >= 0.0 and then M.Tendons.Tendon_Damping (T) >= 0.0
        and then M.Tendons.Tendon_Frictionloss (T) >= 0.0 and then M.Tendons.Tendon_Armature (T) >= 0.0
        and then M.Tendons.Tendon_Width (T) >= 0.0 and then M.Tendons.Tendon_Margin (T) >= 0.0)
   with Pre => Valid_Layout (M);

   function Actuator_Params_OK (M : Model) return Boolean is
     ((for all O in 0 .. M.S.Nout - 1 => M.Actuators.Actuator_Acc0 (O) >= 0.0)
      and then (for all A in 0 .. M.S.Nactuator - 1 =>
                  M.Actuators.Actuator_Cranklength (A) >= 0.0))
   with Pre => Valid_Layout (M);

   ----------------------------------------------------------------------------
   --  5.11 Capacity consistency, 5.12 adhesion flag
   ----------------------------------------------------------------------------

   --  Bound the dense Jacobian size independently of the whole model.
   function Jacobian_Capacity (Efc : Cap_Type; Nv : Size_Type) return Size_Type is
     (Size_Type (Int64'Min (Int64 (Efc) * Int64 (Nv), Int64 (Max_Size))))
   with Global => null;

   function Caps_OK (M : Model) return Boolean is
     (Int64 (M.Caps.Efc_Cap) =
        ((Int64 (M.Caps.Ne_Max) + Int64 (M.Caps.Nf_Max)) + Int64 (M.Caps.Nl_Max))
        + 10 * Int64 (M.Caps.Contact_Cap)
      --  the dense bound saturates at Max_Size: large sparse models (100 humanoids) exceed it,
      --  and the constraint assembler checks nJ against the allocated capacity dynamically
      and then M.Caps.NJ_Cap = Jacobian_Capacity (M.Caps.Efc_Cap, M.S.Nv)
      and then M.Caps.NIsland_Cap = M.S.Ntree
      and then M.Caps.NIdof_Cap = M.S.Nv);

   function Has_Positive (Values : Real_Array) return Boolean is
     (for some Value of Values => Value > 0.0)
   with Global => null;

   function Adhesion_OK (M : Model) return Boolean is
     (M.Flg_Adhesion = (Has_Positive (M.Geoms.Geom_Adhesion.all)
                       or else Has_Positive (M.Pairs.Pair_Adhesion.all)))
   with Pre => Valid_Layout (M);

   ----------------------------------------------------------------------------
   --  Conjunction, complete for version one.
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
      and then Geom_Types_OK (M) and then Geom_Datas_OK (M) and then Site_Datas_OK (M) and then Sameframes_OK (M)
      and then Meshes_OK (M) and then Hfields_OK (M) and then Textures_OK (M) and then Texids_OK (M)
      and then Bvhs_OK (M) and then Octs_OK (M)
      and then Pairs_OK (M) and then Excludes_OK (M) and then Eq_Types_OK (M) and then Eq_Objs_OK (M)
      and then Wraps_OK (M) and then Tendons_OK (M)
      and then Actuator_Types_OK (M) and then Actuator_Trnids_OK (M) and then Actuator_Acts_OK (M)
      and then Actuator_Ranges_OK (M)
      and then Sensor_Types_OK (M) and then Sensor_Objs_OK (M) and then Sensor_Dims_OK (M)
      and then Sensor_Adrs_OK (M)
      and then Tuples_OK (M) and then Names_OK (M) and then Paths_OK (M)
      and then Option_OK (M) and then Stat_OK (M)
      and then Body_Params_OK (M) and then Jnt_Params_OK (M) and then Geom_Params_OK (M)
      and then Dof_Params_OK (M) and then Tendon_Params_OK (M) and then Actuator_Params_OK (M)
      and then Caps_OK (M) and then Adhesion_OK (M))
   with Pre => Valid_Layout (M);

   --  Compose the callee contracts; every clause body is proved separately.
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sizes_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Refs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Bools_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Reals_In_Tier0);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Parents_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Roots_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Welds_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Joints_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Dofs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Geoms_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Trees_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Tree_Dofs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Trees_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Jnt_Types_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Jnt_Adrs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Joints_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Parents_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Parent_Ranges_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Madr_Range_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Madrs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Simplenums_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_M_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_B_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_D_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_Ten_J_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", M_Rownnz_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", M_Rows_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", D_Diags_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Maps_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Geom_Types_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Geom_Datas_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Site_Datas_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sameframes_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Meshes_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Hfields_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Textures_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Texids_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Bvhs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Octs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Pairs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Excludes_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Eq_Types_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Eq_Objs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Wraps_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Tendons_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Types_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Trnids_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Acts_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Ranges_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sensor_Types_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sensor_Objs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sensor_Dims_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sensor_Adrs_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Tuples_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Names_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Paths_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Option_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stat_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Params_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Jnt_Params_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Geom_Params_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Params_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Tendon_Params_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Params_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Caps_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Adhesion_OK);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);

   subtype Valid_Model is Model
     with Dynamic_Predicate => Valid_Layout (Valid_Model) and then Is_Valid (Valid_Model);

   pragma No_Inline (Sizes_OK, Owners_Sorted, Blocks_OK, Covered_OK, Parents_OK, Roots_OK, Welds_OK,
                     Body_Joints_OK, Body_Dofs_OK, Body_Geoms_OK, Dof_Trees_OK, Tree_Dofs_OK,
                     Body_Trees_OK, Jnt_Types_OK, Jnt_Adrs_OK, Dof_Joints_OK, Dof_Parents_OK,
                     Dof_Parent_Ranges_OK, Madr_Range_OK, Madrs_OK, Simplenums_OK,
                     CSR_OK, Sparse_M_OK, Sparse_B_OK, Sparse_D_OK, Sparse_Ten_J_OK, M_Rownnz_OK,
                     M_Rows_OK, D_Diags_OK, Maps_OK, Geom_Types_OK, Geom_Datas_OK, Site_Datas_OK, Sameframes_OK,
                     Meshes_OK, Hfields_OK, Textures_OK, Texids_OK, Bvhs_OK, Octs_OK,
                     Pairs_OK, Excludes_OK, Eq_Types_OK, Eq_Objs_OK, Wraps_OK, Tendons_OK,
                     Actuator_Types_OK, Actuator_Trnids_OK, Actuator_Acts_OK, Actuator_Ranges_OK,
                     Sensor_Types_OK, Sensor_Objs_OK, Sensor_Dims_OK, Sensor_Adrs_OK,
                     Tuples_OK, Names_OK, Paths_OK, Option_OK, Stat_OK, Body_Params_OK,
                     Jnt_Params_OK, Geom_Params_OK, Dof_Params_OK, Tendon_Params_OK,
                     Actuator_Params_OK, Caps_OK, Adhesion_OK, Is_Valid);

end MJ.Models.Validity;
