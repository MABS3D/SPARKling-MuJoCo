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
   --  Conjunction. Tasks 8b to 8d append clauses here, before Valid_Model.
   ----------------------------------------------------------------------------

   function Is_Valid (M : Model) return Boolean is
     (Sizes_OK (M)
      and then Refs_OK (M) and then Bools_OK (M) and then Reals_In_Tier0 (M)
      and then Parents_OK (M) and then Roots_OK (M) and then Welds_OK (M)
      and then Body_Joints_OK (M) and then Body_Dofs_OK (M) and then Body_Geoms_OK (M)
      and then Dof_Trees_OK (M) and then Tree_Dofs_OK (M) and then Body_Trees_OK (M)
      and then Jnt_Types_OK (M) and then Jnt_Adrs_OK (M) and then Dof_Joints_OK (M)
      and then Dof_Parents_OK (M) and then Dof_Parent_Ranges_OK (M)
      and then Madr_Range_OK (M) and then Madrs_OK (M) and then Simplenums_OK (M))
   with Pre => Valid_Layout (M);

   subtype Valid_Model is Model
     with Dynamic_Predicate => Valid_Layout (Valid_Model) and then Is_Valid (Valid_Model);

   pragma No_Inline (Sizes_OK, Owners_Sorted, Blocks_OK, Covered_OK, Parents_OK, Roots_OK, Welds_OK,
                     Body_Joints_OK, Body_Dofs_OK, Body_Geoms_OK, Dof_Trees_OK, Tree_Dofs_OK,
                     Body_Trees_OK, Jnt_Types_OK, Jnt_Adrs_OK, Dof_Joints_OK, Dof_Parents_OK,
                     Dof_Parent_Ranges_OK, Madr_Range_OK, Madrs_OK, Simplenums_OK, Is_Valid);

end MJ.Models.Validity;
