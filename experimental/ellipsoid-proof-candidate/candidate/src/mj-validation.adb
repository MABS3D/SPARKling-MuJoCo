--  Contracts and loop invariants in this body are proven by GNATprove and are
--  not evaluated at run time (see MJ.Models.Validity for why).
pragma Assertion_Policy (Pre => Ignore, Post => Ignore, Loop_Invariant => Ignore,
                         Loop_Variant => Ignore, Assert_And_Cut => Ignore, Assert => Check);
with Interfaces;            use type Interfaces.Unsigned_8;
with MJ.Models.Gen_Clauses; use MJ.Models.Gen_Clauses;

package body MJ.Validation with SPARK_Mode is

   ----------------------------------------------------------------------------
   --  Capacities (spec 5.11). Counts are computed defensively because the
   --  arrays are not yet known to be valid.
   ----------------------------------------------------------------------------

   function Count_Equality_Rows (Kinds : Int_Array) return Int64 with
     Global => null,
     Post => Count_Equality_Rows'Result in 0 .. 6 * Int64 (Kinds'Length);

   function Count_Equality_Rows (Kinds : Int_Array) return Int64 is
      Count : Int64 := 0;
   begin
      for I in Kinds'Range loop
         Count := Count + (case Kinds (I) is
                            when 0 => 3, when 1 => 6, when 2 | 3 => 1, when others => 0);
         pragma Loop_Invariant (Count in 0 .. 6 * (Int64 (I) - Int64 (Kinds'First) + 1));
      end loop;
      return Count;
   end Count_Equality_Rows;

   function Count_Positive (Values : Real_Array) return Int64 with
     Global => null,
     Post => Count_Positive'Result in 0 .. Int64 (Values'Length);

   function Count_Positive (Values : Real_Array) return Int64 is
      Count : Int64 := 0;
   begin
      for I in Values'Range loop
         if Values (I) > 0.0 then
            Count := Count + 1;
         end if;
         pragma Loop_Invariant (Count in 0 .. Int64 (I) - Int64 (Values'First) + 1);
      end loop;
      return Count;
   end Count_Positive;

   function Count_Enabled (Flags : Byte_Array) return Int64 with
     Global => null,
     Post => Count_Enabled'Result in 0 .. Int64 (Flags'Length);

   function Count_Enabled (Flags : Byte_Array) return Int64 is
      Count : Int64 := 0;
   begin
      for I in Flags'Range loop
         if Flags (I) /= 0 then
            Count := Count + 1;
         end if;
         pragma Loop_Invariant (Count in 0 .. Int64 (I) - Int64 (Flags'First) + 1);
      end loop;
      return Count;
   end Count_Enabled;

   function Count_Limit_Rows (Flags : Byte_Array; Kinds : Int_Array) return Int64 with
     Global => null,
     Pre => Flags'First = Kinds'First and then Flags'Length = Kinds'Length,
     Post => Count_Limit_Rows'Result in 0 .. 2 * Int64 (Flags'Length);

   function Count_Limit_Rows (Flags : Byte_Array; Kinds : Int_Array) return Int64 is
      Count : Int64 := 0;
   begin
      for I in Flags'Range loop
         if Flags (I) /= 0 then
            Count := Count + (if Kinds (I) = 1 then 1 else 2);
         end if;
         pragma Loop_Invariant (Count in 0 .. 2 * (Int64 (I) - Int64 (Flags'First) + 1));
      end loop;
      return Count;
   end Count_Limit_Rows;

   procedure Compute_Caps (M : in out Model; Options : Validate_Options; Overflow : out Boolean) with
     Pre  => Valid_Layout (M),
     Post => Valid_Layout (M) and then M.S = M.S'Old
             and then (if not Overflow then Caps_OK (M) and then Adhesion_OK (M))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Jacobian_Capacity);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Has_Positive);
      Adhesion   : Boolean;
      Ne, Nf, Nl : Int64;
      Contact    : Int64;
      Efc        : Int64;
      NJ         : Size_Type;
   begin
      Adhesion := Has_Positive (M.Geoms.Geom_Adhesion.all)
                  or else Has_Positive (M.Pairs.Pair_Adhesion.all);
      Ne := Count_Equality_Rows (M.Equalities.Eq_Type.all);
      Nf := Count_Positive (M.Dofs.Dof_Frictionloss.all)
            + Count_Positive (M.Tendons.Tendon_Frictionloss.all);
      Nl := Count_Limit_Rows (M.Joints.Jnt_Limited.all, M.Joints.Jnt_Type.all)
            + 2 * Count_Enabled (M.Tendons.Tendon_Limited.all);

      Contact := (if Options.Contact_Cap > 0 then Int64 (Options.Contact_Cap)
                  elsif M.S.Nconmax >= 0 then Int64 (M.S.Nconmax)
                  else 64 + 16 * Int64 (M.S.Ngeom));
      Contact := Int64'Min (Contact, Int64 (Max_Cap));

      Efc := Ne + Nf + Nl + 10 * Contact;
      Overflow := Efc > Int64 (Max_Cap);
      M.Flg_Adhesion := Adhesion;
      if Overflow then
         return;
      end if;
      NJ := Jacobian_Capacity (Cap_Type (Efc), M.S.Nv);
      M.Caps := (Contact_Cap => Integer (Contact),
                 Ne_Max      => Integer (Ne),
                 Nf_Max      => Integer (Nf),
                 Nl_Max      => Integer (Nl),
                 Efc_Cap     => Integer (Efc),
                 NJ_Cap      => NJ,
                 NIsland_Cap => M.S.Ntree,
                 NIdof_Cap   => M.S.Nv);
   end Compute_Caps;

   ----------------------------------------------------------------------------
   --  Diagnostics: each procedure re-walks one clause family in Is_Valid order
   --  and reports the first failing element. Only absence of runtime errors is
   --  proven here; the postconditions let Diagnose chain them.
   ----------------------------------------------------------------------------

   --  Expose array shapes at proof boundaries, keeping Valid_Layout opaque at
   --  repeated predicate calls. This lemma is proved from its precondition;
   --  it has no state changes and introduces no trusted assumption.
   procedure Reveal_Layout (M : Model) with
     Ghost, Global => null,
     Pre => Valid_Layout (M),
     Post => (Sizes_In_Range (M.S)
      and then Body_Layout_OK (M.S, M.Bodies)
      and then Joint_Layout_OK (M.S, M.Joints)
      and then Dof_Layout_OK (M.S, M.Dofs)
      and then Tree_Layout_OK (M.S, M.Trees)
      and then Geom_Layout_OK (M.S, M.Geoms)
      and then Site_Layout_OK (M.S, M.Sites)
      and then Camera_Layout_OK (M.S, M.Cameras)
      and then Light_Layout_OK (M.S, M.Lights)
      and then Flex_Layout_OK (M.S, M.Flexes)
      and then Mesh_Layout_OK (M.S, M.Meshes)
      and then Skin_Layout_OK (M.S, M.Skins)
      and then Hfield_Layout_OK (M.S, M.Hfields)
      and then Texture_Layout_OK (M.S, M.Textures)
      and then Material_Layout_OK (M.S, M.Materials)
      and then Pair_Layout_OK (M.S, M.Pairs)
      and then Exclude_Layout_OK (M.S, M.Excludes)
      and then Equality_Layout_OK (M.S, M.Equalities)
      and then Tendon_Layout_OK (M.S, M.Tendons)
      and then Actuator_Layout_OK (M.S, M.Actuators)
      and then Sensor_Layout_OK (M.S, M.Sensors)
      and then Qpos_Layout_OK (M.S, M.Qpos)
      and then Bvh_Layout_OK (M.S, M.Bvh)
      and then Wrap_Layout_OK (M.S, M.Wraps)
      and then Plugin_Layout_OK (M.S, M.Plugins)
      and then Numeric_Layout_OK (M.S, M.Numerics)
      and then Text_Layout_OK (M.S, M.Texts)
      and then Tuple_Layout_OK (M.S, M.Tuples)
      and then Key_Layout_OK (M.S, M.Keys)
      and then Name_Layout_OK (M.S, M.Names)
      and then Sparse_Layout_OK (M.S, M.Sparse))
   is
   begin
      null;
   end Reveal_Layout;

   procedure Diagnose_Refs (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M),
     Post => (if Result.Status = OK then Refs_OK (M));
   procedure Diagnose_Refs (M : Model; Result : out Load_Result) is separate;

   procedure Diagnose_Reals (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M),
     Post => (if Result.Status = OK then Reals_In_Tier0 (M));
   procedure Diagnose_Reals (M : Model; Result : out Load_Result) is separate;

   procedure Diagnose_Bools (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M),
     Post => (if Result.Status = OK then Bools_OK (M));
   procedure Diagnose_Bools (M : Model; Result : out Load_Result) is separate;

   procedure Diagnose_Blocks
     (Adr, Num, Owner : Int_Array; N_Owner : Integer;
      Adr_Field, Owner_Field : Field_Id; Result : out Load_Result) with
     Pre  => Adr'First = 0 and then Num'First = 0 and then Owner'First = 0
             and then Adr'Length = Num'Length,
     Post => (if Result.Status = OK then
                Owners_Sorted (Owner, N_Owner) and then Blocks_OK (Adr, Num, Owner)
                and then Covered_OK (Adr, Num, Owner))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Block_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Covered_At);
   begin
      Result := OK_Result;
      if Int64 (Owner'Length) > Int64 (Max_Size) then
         Result := (Invalid_Tree, Owner_Field, -1);
         return;
      end if;
      if not Owners_Sorted (Owner, N_Owner) then
         Result := (Invalid_Tree, Owner_Field, -1);
         return;
      end if;
      for I in Adr'Range loop
         if not Block_At (Adr, Num, Owner, I) then
            Result := (Invalid_Tree, Adr_Field, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => Block_At (Adr, Num, Owner, K));
      end loop;
      pragma Assert (Blocks_OK (Adr, Num, Owner));
      for K in Owner'Range loop
         if not Covered_At (Adr, Num, Owner, K) then
            Result := (Invalid_Tree, Owner_Field, K);
            return;
         end if;
         pragma Loop_Invariant (for all J in 0 .. K => Covered_At (Adr, Num, Owner, J));
      end loop;
   end Diagnose_Blocks;

   procedure Diagnose_Dof_Trees (M : Model; Result : out Load_Result) with
     Pre => Valid_Layout (M) and then Sizes_OK (M),
     Post => (if Result.Status = OK then Dof_Trees_OK (M) and then Tree_Dofs_OK (M))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sizes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Tree_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Owners_Sorted);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Blocks_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Covered_OK);
   begin
      Reveal_Layout (M);
      if M.S.Nv = 0 then
         if M.S.Ntree /= 0 then
            Result := (Invalid_Tree, Tree_Dofadr, -1);
            return;
         end if;
      else
         if M.Dofs.Dof_Parentid (0) /= -1 then
            Result := (Invalid_Tree, Dof_Parentid, 0);
            return;
         end if;
         if M.Dofs.Dof_Treeid (M.S.Nv - 1) /= M.S.Ntree - 1 then
            Result := (Invalid_Tree, Dof_Treeid, M.S.Nv - 1);
            return;
         end if;
      end if;
      for D in 0 .. M.S.Nv - 1 loop
         if not Dof_Tree_At (M, D) then
            Result := (Invalid_Tree, Dof_Treeid, D);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. D => Dof_Tree_At (M, K));
      end loop;
      pragma Assert (Dof_Trees_OK (M));

      for T in 0 .. M.S.Ntree - 1 loop
         if M.Trees.Tree_Dofnum (T) < 1 then
            Result := (Invalid_Tree, Tree_Dofnum, T);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. T => M.Trees.Tree_Dofnum (K) >= 1);
      end loop;
      --  Keep the established facts while discarding the preceding paths.
      pragma Assert_And_Cut
        (Valid_Layout (M) and then Sizes_OK (M) and then Dof_Trees_OK (M)
         and then (for all T in 0 .. M.S.Ntree - 1 => M.Trees.Tree_Dofnum (T) >= 1));
      Reveal_Layout (M);
      Diagnose_Blocks (M.Trees.Tree_Dofadr.all, M.Trees.Tree_Dofnum.all, M.Dofs.Dof_Treeid.all,
                       M.S.Ntree, Tree_Dofadr, Dof_Treeid, Result);
      if Result.Status /= OK then
         return;
      end if;
      pragma Assert (Tree_Dofs_OK (M));
   end Diagnose_Dof_Trees;

   procedure Diagnose_Tree (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M) and then Sizes_OK (M),
     Post => (if Result.Status = OK then
                Parents_OK (M) and then Roots_OK (M) and then Welds_OK (M)
                and then Body_Joints_OK (M) and then Body_Dofs_OK (M) and then Body_Geoms_OK (M)
                and then Dof_Trees_OK (M) and then Tree_Dofs_OK (M) and then Body_Trees_OK (M))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Parent_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Root_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Weld_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Tree_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Tree_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Tree_Body_Range_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_In_Tree_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Owners_Sorted);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Blocks_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Covered_OK);
   begin
      Reveal_Layout (M);
      for I in 0 .. M.S.Nbody - 1 loop
         if not Parent_At (M, I) then
            Result := (Invalid_Tree, Body_Parentid, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => Parent_At (M, K));
      end loop;
      for I in 0 .. M.S.Nbody - 1 loop
         if not Root_At (M, I) then
            Result := (Invalid_Tree, Body_Rootid, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => Root_At (M, K));
      end loop;
      for I in 0 .. M.S.Nbody - 1 loop
         if not Weld_At (M, I) then
            Result := (Invalid_Tree, Body_Weldid, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => Weld_At (M, K));
      end loop;

      Diagnose_Blocks (M.Bodies.Body_Jntadr.all, M.Bodies.Body_Jntnum.all, M.Joints.Jnt_Bodyid.all,
                       M.S.Nbody, Body_Jntadr, Jnt_Bodyid, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Blocks (M.Bodies.Body_Dofadr.all, M.Bodies.Body_Dofnum.all, M.Dofs.Dof_Bodyid.all,
                       M.S.Nbody, Body_Dofadr, Dof_Bodyid, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Blocks (M.Bodies.Body_Geomadr.all, M.Bodies.Body_Geomnum.all, M.Geoms.Geom_Bodyid.all,
                       M.S.Nbody, Body_Geomadr, Geom_Bodyid, Result);
      if Result.Status /= OK then
         return;
      end if;

      Diagnose_Dof_Trees (M, Result);
      if Result.Status /= OK then
         return;
      end if;

      for I in 0 .. M.S.Nbody - 1 loop
         if not Body_Tree_At (M, I) then
            Result := (Invalid_Tree, Body_Treeid, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => Body_Tree_At (M, K));
      end loop;
      for T in 0 .. M.S.Ntree - 1 loop
         if not Tree_Body_Range_At (M, T) then
            Result := (Invalid_Tree, Tree_Bodyadr, T);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. T => Tree_Body_Range_At (M, K));
      end loop;
      for I in 0 .. M.S.Nbody - 1 loop
         if not Body_In_Tree_At (M, I) then
            Result := (Invalid_Tree, Body_Treeid, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => Body_In_Tree_At (M, K));
      end loop;
      for T in 0 .. M.S.Ntree - 1 loop
         if M.Trees.Tree_Sleep_Policy (T) not in 0 .. 5 then
            Result := (Invalid_Enum, Tree_Sleep_Policy, T);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. T => M.Trees.Tree_Sleep_Policy (K) in 0 .. 5);
      end loop;
      pragma Assert (Body_Trees_OK (M));
   end Diagnose_Tree;

   procedure Diagnose_Joints (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M),
     Post => (if Result.Status = OK then
                Jnt_Types_OK (M) and then Jnt_Adrs_OK (M) and then Dof_Joints_OK (M)
                and then Dof_Parents_OK (M) and then Dof_Parent_Ranges_OK (M)
                and then Madr_Range_OK (M) and then Madrs_OK (M) and then Simplenums_OK (M))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Jnt_Adrs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Joints_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Parents_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Parent_Ranges_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Madr_Range_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Madrs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Simplenums_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Jnt_Adr_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Joint_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Parent_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Madr_At);
   begin
      Reveal_Layout (M);
      Result := OK_Result;
      if not Jnt_Types_OK (M) then
         for J in 0 .. M.S.Njnt - 1 loop
            if M.Joints.Jnt_Type (J) not in 0 .. 3 then
               Result := (Invalid_Enum, Jnt_Type, J);
               return;
            end if;
         end loop;
         Result := (Invalid_Enum, Jnt_Type, -1);
         return;
      end if;
      if not Jnt_Adrs_OK (M) then
         for J in 0 .. M.S.Njnt - 1 loop
            if not Jnt_Adr_At (M, J) then
               Result := (Invalid_Joint_Layout, Jnt_Qposadr, J);
               return;
            end if;
         end loop;
         if M.S.Njnt = 0 then
            Result := (Invalid_Joint_Layout, Jnt_Qposadr, -1);
         elsif Int64 (M.Joints.Jnt_Qposadr (M.S.Njnt - 1))
           + Int64 (Qpos_Width (M.Joints.Jnt_Type (M.S.Njnt - 1))) /= Int64 (M.S.Nq)
         then
            Result := (Invalid_Joint_Layout, Jnt_Qposadr, M.S.Njnt - 1);
         else
            Result := (Invalid_Joint_Layout, Jnt_Dofadr, M.S.Njnt - 1);
         end if;
         return;
      end if;
      if not Dof_Joints_OK (M) then
         for D in 0 .. M.S.Nv - 1 loop
            if not Dof_Joint_At (M, D) then
               Result := (Invalid_Dof_Chain, Dof_Jntid, D);
               return;
            end if;
         end loop;
         Result := (Invalid_Dof_Chain, Dof_Jntid, -1);
         return;
      end if;
      if not Dof_Parents_OK (M) then
         for D in 0 .. M.S.Nv - 1 loop
            if not Dof_Parent_At (M, D) then
               Result := (Invalid_Dof_Chain, Dof_Parentid, D);
               return;
            end if;
         end loop;
         Result := (Invalid_Dof_Chain, Dof_Parentid, -1);
         return;
      end if;
      if not Dof_Parent_Ranges_OK (M) then
         Result := (Invalid_Dof_Chain, Dof_Parentid, -1);
         return;
      end if;
      if not Madr_Range_OK (M) then
         for D in 0 .. M.S.Nv - 1 loop
            if M.Dofs.Dof_Madr (D) not in 0 .. M.S.Nm then
               Result := (Invalid_Dof_Chain, Dof_Madr, D);
               return;
            end if;
         end loop;
         Result := (Invalid_Dof_Chain, Dof_Madr, -1);
         return;
      end if;
      if not Madrs_OK (M) then
         if M.S.Nv = 0 then
            Result := (Invalid_Dof_Chain, Dof_Madr, -1);
            return;
         elsif M.Dofs.Dof_Madr (0) /= 0 then
            Result := (Invalid_Dof_Chain, Dof_Madr, 0);
            return;
         end if;
         for D in 0 .. M.S.Nv - 1 loop
            if not Madr_At (M, D) then
               Result := (Invalid_Dof_Chain, Dof_Madr, D);
               return;
            end if;
         end loop;
         Result := (Invalid_Dof_Chain, Dof_Madr, -1);
         return;
      end if;
      if not Simplenums_OK (M) then
         for D in 0 .. M.S.Nv - 1 loop
            if M.Dofs.Dof_Simplenum (D) not in 0 .. M.S.Nv - D then
               Result := (Invalid_Dof_Chain, Dof_Simplenum, D);
               return;
            end if;
         end loop;
         Result := (Invalid_Dof_Chain, Dof_Simplenum, -1);
         return;
      end if;
   end Diagnose_Joints;

   procedure Diagnose_CSR
     (Rownnz, Rowadr, Colind : Int_Array; N, Nnz, Ncols : Integer;
      Field : Field_Id; Result : out Load_Result) with
     Pre  => N >= 0 and then Nnz >= 0 and then Ncols >= 0,
     Post => (if Result.Status = OK then CSR_OK (Rownnz, Rowadr, Colind, N, Nnz, Ncols))
   is
   begin
      if CSR_OK (Rownnz, Rowadr, Colind, N, Nnz, Ncols) then
         Result := OK_Result;
      else
         Result := (Invalid_CSR, Field, -1);
         --  locate a row that breaks the contiguity or ordering rules, if any
         if Rownnz'First = 0 and then Rowadr'First = 0 and then Colind'First = 0
           and then Int64 (Rownnz'Length) = Int64 (N)
           and then Int64 (Rowadr'Length) = Int64 (N)
           and then Int64 (Colind'Length) = Int64 (Nnz)
         then
            for I in 0 .. N - 1 loop
               if Rownnz (I) not in 0 .. Nnz or else Rowadr (I) not in 0 .. Nnz - Rownnz (I)
                 or else Rowadr (I) /= (if I = 0 then 0 else Rowadr (I - 1) + Rownnz (I - 1))
               then
                  Result := (Invalid_CSR, Field, I);
                  return;
               end if;
               pragma Loop_Invariant
                 (for all J in 0 .. I => Rownnz (J) in 0 .. Nnz and then Rowadr (J) in 0 .. Nnz - Rownnz (J));
            end loop;
         end if;
      end if;
   end Diagnose_CSR;

   procedure Diagnose_Sparse (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M) and then Madr_Range_OK (M) and then Dof_Parent_Ranges_OK (M) and then Madrs_OK (M),
     Post => (if Result.Status = OK then
                Sparse_M_OK (M) and then Sparse_B_OK (M) and then Sparse_D_OK (M)
                and then Sparse_Ten_J_OK (M) and then M_Rownnz_OK (M) and then M_Rows_OK (M)
                and then D_Diags_OK (M) and then Maps_OK (M))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_M_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_B_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_D_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_Ten_J_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", M_Rownnz_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", M_Rows_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", D_Diags_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Maps_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Madr_Range_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Parent_Ranges_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Madrs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", M_Row_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", D_Diag_At);
   begin
      Reveal_Layout (M);
      if not Sparse_M_OK (M) then
         Diagnose_CSR (M.Sparse.M_Rownnz.all, M.Sparse.M_Rowadr.all, M.Sparse.M_Colind.all,
                       M.S.Nv, M.S.Nc, M.S.Nv, M_Rowadr, Result);
         if Result.Status /= OK then
            return;
         end if;
         Result := (Invalid_CSR, M_Rowadr, -1);
         return;
      end if;
      if not Sparse_B_OK (M) then
         Diagnose_CSR (M.Sparse.B_Rownnz.all, M.Sparse.B_Rowadr.all, M.Sparse.B_Colind.all,
                       M.S.Nbody, M.S.Nb, M.S.Nv, B_Rowadr, Result);
         if Result.Status /= OK then
            return;
         end if;
         Result := (Invalid_CSR, B_Rowadr, -1);
         return;
      end if;
      if not Sparse_D_OK (M) then
         Diagnose_CSR (M.Sparse.D_Rownnz.all, M.Sparse.D_Rowadr.all, M.Sparse.D_Colind.all,
                       M.S.Nv, M.S.Nd, M.S.Nv, D_Rowadr, Result);
         if Result.Status /= OK then
            return;
         end if;
         Result := (Invalid_CSR, D_Rowadr, -1);
         return;
      end if;
      if not Sparse_Ten_J_OK (M) then
         Diagnose_CSR (M.Tendons.Ten_J_Rownnz.all, M.Tendons.Ten_J_Rowadr.all, M.Tendons.Ten_J_Colind.all,
                       M.S.Ntendon, M.S.Njten, M.S.Nv, Ten_J_Rowadr, Result);
         if Result.Status /= OK then
            return;
         end if;
         Result := (Invalid_CSR, Ten_J_Rowadr, -1);
         return;
      end if;
      if not M_Rownnz_OK (M) then
         for I in 0 .. M.S.Nv - 1 loop
            if M.Sparse.M_Rownnz (I) /= (if M.Dofs.Dof_Simplenum (I) > 0 then 1 else Row_Len (M, I)) then
               Result := (Invalid_CSR, M_Rownnz, I);
               return;
            end if;
         end loop;
         Result := (Invalid_CSR, M_Rownnz, -1);
         return;
      end if;
      if not M_Rows_OK (M) then
         for I in 0 .. M.S.Nv - 1 loop
            if not M_Row_At (M, I) then
               Result := (Invalid_CSR, M_Colind, I);
               return;
            end if;
         end loop;
         Result := (Invalid_CSR, M_Colind, -1);
         return;
      end if;
      if not D_Diags_OK (M) then
         for I in 0 .. M.S.Nv - 1 loop
            if not D_Diag_At (M, I) then
               Result := (Invalid_CSR, D_Diag, I);
               return;
            end if;
         end loop;
         Result := (Invalid_CSR, D_Diag, -1);
         return;
      end if;
      if not Maps_OK (M) then
         for K in 0 .. M.S.Nc - 1 loop
            if M.Sparse.MapM2M (K) not in 0 .. M.S.Nm - 1 then
               Result := (Invalid_CSR, MapM2M, K);
               return;
            end if;
         end loop;
         for K in 0 .. M.S.Nd - 1 loop
            if M.Sparse.MapM2D (K) not in -1 .. M.S.Nc - 1 then
               Result := (Invalid_CSR, MapM2D, K);
               return;
            end if;
         end loop;
         for K in 0 .. M.S.Nc - 1 loop
            if M.Sparse.MapD2M (K) not in 0 .. M.S.Nd - 1 then
               Result := (Invalid_CSR, MapD2M, K);
               return;
            end if;
         end loop;
         for K in 0 .. M.S.Nc - 1 loop
            if M.Sparse.MapD2M (K) not in 0 .. M.S.Nd - 1
              or else M.Sparse.MapM2D (M.Sparse.MapD2M (K)) /= K then
               Result := (Invalid_CSR, MapD2M, K);
               return;
            end if;
         end loop;
         Result := (Invalid_CSR, MapD2M, -1);
         return;
      end if;
      Result := OK_Result;
   end Diagnose_Sparse;

   procedure Diagnose_Assets (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M),
     Post => (if Result.Status = OK then
                Geom_Types_OK (M) and then Geom_Datas_OK (M) and then Site_Datas_OK (M) and then Sameframes_OK (M)
                and then Meshes_OK (M) and then Hfields_OK (M) and then Textures_OK (M)
                and then Texids_OK (M) and then Bvhs_OK (M) and then Octs_OK (M))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Geom_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Geom_Datas_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Site_Datas_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sameframes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Meshes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Hfields_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Textures_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Texids_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Bvhs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Geom_Type_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Geom_Data_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Site_Data_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mesh_Faces_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mesh_Polys_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mesh_Graph_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Hfield_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Texture_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bvh_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mesh_Bvh_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Octs_OK);
   begin
      Reveal_Layout (M);
      Result := OK_Result;
      if not Geom_Types_OK (M) then
         for G in 0 .. M.S.Ngeom - 1 loop
            if not Geom_Type_At (M, G) then
               Result := ((if M.Geoms.Geom_Type (G) = 8 then Unsupported_Plugins else Invalid_Enum),
                          (if M.Geoms.Geom_Type (G) in 0 .. 7 then Geom_Condim else Geom_Type), G);
               return;
            end if;
         end loop;
         Result := (Invalid_Enum, Geom_Type, -1);
         return;
      end if;
      if not Geom_Datas_OK (M) then
         for G in 0 .. M.S.Ngeom - 1 loop
            if not Geom_Data_At (M, G) then
               Result := (Invalid_Reference, Geom_Dataid, G);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Geom_Dataid, -1);
         return;
      end if;
      if not Site_Datas_OK (M) then
         for S in 0 .. M.S.Nsite - 1 loop
            if not Site_Data_At (M, S) then
               Result := (Invalid_Reference, Site_Dataid, S);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Site_Dataid, -1);
         return;
      end if;
      if not Sameframes_OK (M) then
         for I in 0 .. M.S.Nbody - 1 loop
            if M.Bodies.Body_Sameframe (I) > 4 then
               Result := (Invalid_Enum, Body_Sameframe, I);
               return;
            end if;
         end loop;
         for G in 0 .. M.S.Ngeom - 1 loop
            if M.Geoms.Geom_Sameframe (G) > 4 then
               Result := (Invalid_Enum, Geom_Sameframe, G);
               return;
            end if;
         end loop;
         for S in 0 .. M.S.Nsite - 1 loop
            if M.Sites.Site_Sameframe (S) > 4 then
               Result := (Invalid_Enum, Site_Sameframe, S);
               return;
            end if;
         end loop;
         Result := (Invalid_Enum, Body_Sameframe, -1);
         return;
      end if;
      if not Meshes_OK (M) then
         for I in 0 .. M.S.Nmesh - 1 loop
            if not Mesh_Faces_At (M, I) then
               Result := (Invalid_Reference, Mesh_Face, I);
               return;
            elsif not Mesh_Polys_At (M, I) then
               Result := (Invalid_Reference, Mesh_Polyvert, I);
               return;
            elsif not Mesh_Graph_At (M, I) then
               Result := (Invalid_Reference, Mesh_Graph, I);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Mesh_Face, -1);
         return;
      end if;
      if not Hfields_OK (M) then
         for H in 0 .. M.S.Nhfield - 1 loop
            if not Hfield_At (M, H) then
               Result := (Invalid_Parameter, Hfield_Adr, H);
               return;
            end if;
         end loop;
         Result := (Invalid_Parameter, Hfield_Adr, -1);
         return;
      end if;
      if not Textures_OK (M) then
         for T in 0 .. M.S.Ntex - 1 loop
            if not Texture_At (M, T) then
               Result := (Invalid_Parameter, Tex_Adr, T);
               return;
            end if;
         end loop;
         Result := (Invalid_Parameter, Tex_Adr, -1);
         return;
      end if;
      if not Texids_OK (M) then
         for K in M.Materials.Mat_Texid'Range loop
            if M.Materials.Mat_Texid (K) not in -1 .. M.S.Ntex - 1 then
               Result := (Invalid_Reference, Mat_Texid, K);
               return;
            end if;
         end loop;
         for L in 0 .. M.S.Nlight - 1 loop
            if M.Lights.Light_Texid (L) not in -1 .. M.S.Ntex - 1 then
               Result := (Invalid_Reference, Light_Texid, L);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Mat_Texid, -1);
         return;
      end if;
      if not Bvhs_OK (M) then
         for B in 0 .. M.S.Nbody - 1 loop
            if not Body_Bvh_At (M, B) then
               Result := (Invalid_BVH, Body_Bvhadr, B);
               return;
            end if;
         end loop;
         for I in 0 .. M.S.Nmesh - 1 loop
            if not Mesh_Bvh_At (M, I) then
               Result := (Invalid_BVH, Mesh_Bvhadr, I);
               return;
            end if;
         end loop;
         Result := (Invalid_BVH, Body_Bvhadr, -1);
         return;
      end if;
      if not Octs_OK (M) then
         Result := (Invalid_BVH, Oct_Child, -1);
         return;
      end if;
   end Diagnose_Assets;

   procedure Diagnose_Objects (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M) and then Sizes_OK (M) and then Body_Geoms_OK (M),
     Post => (if Result.Status = OK then
                Pairs_OK (M) and then Excludes_OK (M) and then Eq_Types_OK (M) and then Eq_Objs_OK (M)
                and then Wraps_OK (M) and then Tendons_OK (M)
                and then Actuator_Types_OK (M) and then Actuator_Trnids_OK (M)
                and then Actuator_Acts_OK (M) and then Actuator_Ranges_OK (M)
                and then Sensor_Types_OK (M) and then Sensor_Objs_OK (M) and then Sensor_Dims_OK (M)
                and then Sensor_Adrs_OK (M)
                and then Tuples_OK (M) and then Names_OK (M) and then Paths_OK (M))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
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
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Pair_Dim_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Pair_Signature_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Exclude_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Eq_Obj_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Wrap_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Tendon_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Type_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Trnid_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Act_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Control_Range_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Range_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sensor_Type_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sensor_Obj_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sensor_Adr_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Names_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Paths_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sizes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Geoms_OK);
   begin
      Reveal_Layout (M);
      Result := OK_Result;
      if not Pairs_OK (M) then
         for P in 0 .. M.S.Npair - 1 loop
            if not Pair_Dim_At (M, P) then
               Result := (Invalid_Enum, Pair_Dim, P);
               return;
            end if;
         end loop;
         for P in 0 .. M.S.Npair - 1 loop
            if not Pair_Signature_At (M, P) then
               Result := (Invalid_Signature, Pair_Signature, P);
               return;
            end if;
         end loop;
         Result := (Invalid_Signature, Pair_Signature, -1);
         return;
      end if;
      if not Excludes_OK (M) then
         for E in 0 .. M.S.Nexclude - 1 loop
            if not Exclude_At (M, E) then
               Result := (Invalid_Signature, Exclude_Signature, E);
               return;
            end if;
         end loop;
         Result := (Invalid_Signature, Exclude_Signature, -1);
         return;
      end if;
      if not Eq_Types_OK (M) then
         for E in 0 .. M.S.Neq - 1 loop
            if M.Equalities.Eq_Type (E) not in 0 .. 3 then
               Result := ((if M.Equalities.Eq_Type (E) in 4 .. 6 then Unsupported_Flex else Invalid_Enum), Eq_Type, E);
               return;
            end if;
         end loop;
         Result := (Invalid_Enum, Eq_Type, -1);
         return;
      end if;
      if not Eq_Objs_OK (M) then
         for E in 0 .. M.S.Neq - 1 loop
            if not Eq_Obj_At (M, E) then
               Result := (Invalid_Reference, Eq_Obj1id, E);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Eq_Obj1id, -1);
         return;
      end if;
      if not Wraps_OK (M) then
         for W in 0 .. M.S.Nwrap - 1 loop
            if not Wrap_At (M, W) then
               Result := ((if M.Wraps.Wrap_Type (W) in 0 .. 5 then Invalid_Reference else Invalid_Enum),
                          (if M.Wraps.Wrap_Type (W) in 0 .. 5 then Wrap_Objid else Wrap_Type), W);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Wrap_Objid, -1);
         return;
      end if;
      if not Tendons_OK (M) then
         for T in 0 .. M.S.Ntendon - 1 loop
            if not Tendon_At (M, T) then
               Result := (Invalid_Reference, Tendon_Adr, T);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Tendon_Adr, -1);
         return;
      end if;
      if not Actuator_Types_OK (M) then
         for A in 0 .. M.S.Nactuator - 1 loop
            if not Actuator_Type_At (M, A) then
               Result := (Invalid_Enum, Actuator_Trntype, A);
               return;
            end if;
         end loop;
         Result := (Invalid_Enum, Actuator_Trntype, -1);
         return;
      end if;
      if not Actuator_Trnids_OK (M) then
         for A in 0 .. M.S.Nactuator - 1 loop
            if not Actuator_Trnid_At (M, A) then
               Result := (Invalid_Reference, Actuator_Trnid, A);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Actuator_Trnid, -1);
         return;
      end if;
      if not Actuator_Acts_OK (M) then
         for A in 0 .. M.S.Nactuator - 1 loop
            if not Actuator_Act_At (M, A) then
               Result := (Invalid_Reference, Actuator_Actadr, A);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Actuator_Actadr, -1);
         return;
      end if;
      if not Actuator_Ranges_OK (M) then
         for C in 0 .. M.S.Nu - 1 loop
            if not Control_Range_At (M, C) then
               Result := (Invalid_Parameter, Actuator_Ctrlrange, C);
               return;
            end if;
         end loop;
         for A in 0 .. M.S.Nactuator - 1 loop
            if not Actuator_Range_At (M, A) then
               Result := (Invalid_Parameter,
                          (if M.Actuators.Actuator_Forcelimited (A) /= 0
                             and then M.Actuators.Actuator_Forcerange (2 * A)
                                      > M.Actuators.Actuator_Forcerange (2 * A + 1)
                           then Actuator_Forcerange else Actuator_Actrange), A);
               return;
            end if;
         end loop;
         Result := (Invalid_Parameter, Actuator_Ctrlrange, -1);
         return;
      end if;
      if not Sensor_Types_OK (M) then
         for S in 0 .. M.S.Nsensor - 1 loop
            if not Sensor_Type_At (M, S) then
               Result := ((if M.Sensors.Sensor_Type (S) = 47 then Unsupported_Plugins else Invalid_Enum), Sensor_Type, S);
               return;
            end if;
         end loop;
         Result := (Invalid_Enum, Sensor_Type, -1);
         return;
      end if;
      if not Sensor_Objs_OK (M) then
         for S in 0 .. M.S.Nsensor - 1 loop
            if not Sensor_Obj_At (M, S) then
               Result := (Invalid_Reference, Sensor_Objid, S);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Sensor_Objid, -1);
         return;
      end if;
      if not Sensor_Dims_OK (M) then
         for S in 0 .. M.S.Nsensor - 1 loop
            if M.Sensors.Sensor_Dim (S) not in 0 .. M.S.Nsensordata
              or else M.Sensors.Sensor_Dim (S) /= Sensor_Size (M.Sensors.Sensor_Type (S), M.Sensors.Sensor_Dim (S))
            then
               Result := (Invalid_Parameter, Sensor_Dim, S);
               return;
            end if;
         end loop;
         Result := (Invalid_Parameter, Sensor_Dim, -1);
         return;
      end if;
      if not Sensor_Adrs_OK (M) then
         for S in 0 .. M.S.Nsensor - 1 loop
            if not Sensor_Adr_At (M, S) then
               Result := (Invalid_Parameter, Sensor_Adr, S);
               return;
            end if;
         end loop;
         Result := (Invalid_Parameter, Sensor_Adr, M.S.Nsensor - 1);
         return;
      end if;
      if not Tuples_OK (M) then
         for K in 0 .. M.S.Ntupledata - 1 loop
            if Num_Objects (M, M.Tuples.Tuple_Objtype (K)) = -2
              or else (Num_Objects (M, M.Tuples.Tuple_Objtype (K)) /= -1
                       and then M.Tuples.Tuple_Objid (K) not in 0 .. Num_Objects (M, M.Tuples.Tuple_Objtype (K)) - 1)
            then
               Result := (Invalid_Reference, Tuple_Objid, K);
               return;
            end if;
         end loop;
         Result := (Invalid_Reference, Tuple_Objid, -1);
         return;
      end if;
      if not Names_OK (M) then
         Result := (Invalid_Parameter, Names, M.S.Nnames - 1);
         return;
      end if;
      if not Paths_OK (M) then
         Result := (Invalid_Parameter, Paths, M.S.Npaths - 1);
         return;
      end if;
   end Diagnose_Objects;

   procedure Diagnose_Params (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M) and then Jnt_Types_OK (M),
     Post => (if Result.Status = OK then
                Option_OK (M) and then Stat_OK (M)
                and then Body_Params_OK (M) and then Jnt_Params_OK (M) and then Geom_Params_OK (M)
                and then Dof_Params_OK (M) and then Tendon_Params_OK (M) and then Actuator_Params_OK (M)
                and then Caps_OK (M) and then Adhesion_OK (M))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Jnt_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Geom_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Param_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Jnt_Param_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Geom_Param_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Option_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stat_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dof_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Tendon_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Caps_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Adhesion_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Jnt_Types_OK);
   begin
      Reveal_Layout (M);
      Result := OK_Result;
      if not Option_OK (M) then
         Result := (Invalid_Parameter, Option_Block, -1);
         return;
      end if;
      if not Stat_OK (M) then
         Result := (Invalid_Parameter, Statistic_Block, -1);
         return;
      end if;
      if not Body_Params_OK (M) then
         for I in 0 .. M.S.Nbody - 1 loop
            if not Body_Param_At (M, I) then
               Result := (Invalid_Parameter, Body_Mass, I);
               return;
            end if;
         end loop;
         Result := (Invalid_Parameter, Body_Mass, -1);
         return;
      end if;
      if not Jnt_Params_OK (M) then
         for J in 0 .. M.S.Njnt - 1 loop
            if not Jnt_Param_At (M, J) then
               Result := (Invalid_Parameter, Jnt_Axis, J);
               return;
            end if;
         end loop;
         Result := (Invalid_Parameter, Jnt_Axis, -1);
         return;
      end if;
      if not Geom_Params_OK (M) then
         for G in 0 .. M.S.Ngeom - 1 loop
            if not Geom_Param_At (M, G) then
               Result := (Invalid_Parameter, Geom_Size, G);
               return;
            end if;
         end loop;
         for S in 0 .. M.S.Nsite - 1 loop
            if not Unit_Quat (M.Sites.Site_Quat.all, 4 * S) then
               Result := (Invalid_Parameter, Site_Quat, S);
               return;
            end if;
         end loop;
         for C in 0 .. M.S.Ncam - 1 loop
            if not Unit_Quat (M.Cameras.Cam_Quat.all, 4 * C) then
               Result := (Invalid_Parameter, Cam_Quat, C);
               return;
            end if;
         end loop;
         for I in 0 .. M.S.Nmesh - 1 loop
            if not Unit_Quat (M.Meshes.Mesh_Quat.all, 4 * I) then
               Result := (Invalid_Parameter, Mesh_Quat, I);
               return;
            end if;
         end loop;
         Result := (Invalid_Parameter, Geom_Size, -1);
         return;
      end if;
      if not Dof_Params_OK (M) then
         Result := (Invalid_Parameter, Dof_Damping, -1);
         return;
      end if;
      if not Tendon_Params_OK (M) then
         Result := (Invalid_Parameter, Tendon_Stiffness, -1);
         return;
      end if;
      if not Actuator_Params_OK (M) then
         Result := (Invalid_Parameter, Actuator_Acc0, -1);
         return;
      end if;
      if not Caps_OK (M) then
         Result := (Capacity_Overflow, Capacity_Block, -1);
         return;
      end if;
      if not Adhesion_OK (M) then
         Result := (Invalid_Parameter, Flag_Block, -1);
         return;
      end if;
   end Diagnose_Params;

   --  Size ordinals in the .mjb size table (position in MJMODEL_SIZES).
   Size_Nbody   : constant := 6;
   Size_Nbvh    : constant := 7;
   Size_Ntree   : constant := 12;
   Size_Nflex   : constant := 21;
   Size_Nplugin : constant := 72;

   procedure Diagnose (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M) and then not Is_Valid (M),
     Post => Result.Status /= OK
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Valid);
   begin
      if M.S.Nbody < 1 or else M.S.Nbody >= 2**16 then
         Result := (Size_Out_Of_Range, Size_Table, Size_Nbody);
         return;
      elsif M.S.Nplugin /= 0 then
         Result := (Unsupported_Plugins, Size_Table, Size_Nplugin);
         return;
      elsif M.S.Nflex /= 0 then
         Result := (Unsupported_Flex, Size_Table, Size_Nflex);
         return;
      elsif M.S.Nbvhstatic + M.S.Nbvhdynamic /= M.S.Nbvh then
         Result := (Invalid_Parameter, Size_Table, Size_Nbvh);
         return;
      elsif M.S.Ntree > M.S.Nv then
         Result := (Invalid_Parameter, Size_Table, Size_Ntree);
         return;
      end if;
      pragma Assert (Sizes_OK (M));

      Diagnose_Refs (M, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Bools (M, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Reals (M, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Tree (M, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Joints (M, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Sparse (M, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Assets (M, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Objects (M, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Params (M, Result);
      if Result.Status /= OK then
         return;
      end if;

      --  Unreachable when Is_Valid (M) is false; keeps Result well defined.
      Result := (Invalid_Parameter, None, -1);
   end Diagnose;

   procedure Validate (M : in out Model; Options : Validate_Options; Result : out Load_Result) is
      --  The branch tests this exact predicate; its full definition is not
      --  needed to compose Compute_Caps and Diagnose with the public contract.
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      Overflow : Boolean;
   begin
      Compute_Caps (M, Options, Overflow);
      if Overflow then
         Result := (Capacity_Overflow, Capacity_Block, -1);
         return;
      end if;
      if Is_Valid (M) then
         Result := OK_Result;
      else
         Diagnose (M, Result);
      end if;
   end Validate;

end MJ.Validation;
