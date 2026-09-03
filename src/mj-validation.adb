--  Contracts and loop invariants in this body are proven by GNATprove and are
--  not evaluated at run time (see MJ.Models.Validity for why).
pragma Assertion_Policy (Pre => Ignore, Post => Ignore, Loop_Invariant => Ignore,
                         Loop_Variant => Ignore, Assert => Check);
with Interfaces;            use type Interfaces.Unsigned_8;
with MJ.Models.Gen_Clauses; use MJ.Models.Gen_Clauses;

package body MJ.Validation with SPARK_Mode is

   ----------------------------------------------------------------------------
   --  Capacities (spec 5.11). Counts are computed defensively because the
   --  arrays are not yet known to be valid.
   ----------------------------------------------------------------------------

   procedure Compute_Caps (M : in out Model; Options : Validate_Options; Overflow : out Boolean) with
     Pre  => Valid_Layout (M),
     Post => Valid_Layout (M) and then M.S = M.S'Old
   is
      Ne, Nf, Nl : Int64 := 0;
      Contact    : Int64;
      Efc, NJ    : Int64;
   begin
      for E in 0 .. M.S.Neq - 1 loop
         pragma Loop_Invariant (Ne in 0 .. 6 * Int64 (E));
         Ne := Ne + (case M.Equalities.Eq_Type (E) is
                       when 0 => 3, when 1 => 6, when 2 | 3 => 1, when others => 0);
      end loop;
      for D in 0 .. M.S.Nv - 1 loop
         pragma Loop_Invariant (Nf in 0 .. Int64 (D));
         if M.Dofs.Dof_Frictionloss (D) > 0.0 then
            Nf := Nf + 1;
         end if;
      end loop;
      for T in 0 .. M.S.Ntendon - 1 loop
         pragma Loop_Invariant (Nf in 0 .. Int64 (M.S.Nv) + Int64 (T));
         if M.Tendons.Tendon_Frictionloss (T) > 0.0 then
            Nf := Nf + 1;
         end if;
      end loop;
      for J in 0 .. M.S.Njnt - 1 loop
         pragma Loop_Invariant (Nl in 0 .. 2 * Int64 (J));
         if M.Joints.Jnt_Limited (J) /= 0 then
            Nl := Nl + (if M.Joints.Jnt_Type (J) = 1 then 1 else 2);   --  ball 1, slide/hinge 2
         end if;
      end loop;
      for T in 0 .. M.S.Ntendon - 1 loop
         pragma Loop_Invariant (Nl in 0 .. 2 * Int64 (M.S.Njnt) + 2 * Int64 (T));
         if M.Tendons.Tendon_Limited (T) /= 0 then
            Nl := Nl + 2;
         end if;
      end loop;

      Contact := (if Options.Contact_Cap > 0 then Int64 (Options.Contact_Cap)
                  elsif M.S.Nconmax >= 0 then Int64 (M.S.Nconmax)
                  else 64 + 16 * Int64 (M.S.Ngeom));
      Contact := Int64'Min (Contact, Int64 (Max_Cap));

      Efc := Ne + Nf + Nl + 10 * Contact;
      NJ  := Efc * Int64 (M.S.Nv);
      Overflow := Efc > Int64 (Max_Cap) or else NJ > Int64 (Max_Size);
      if Overflow then
         return;
      end if;
      M.Caps := (Contact_Cap => Integer (Contact),
                 Ne_Max      => Integer (Ne),
                 Nf_Max      => Integer (Nf),
                 Nl_Max      => Integer (Nl),
                 Efc_Cap     => Integer (Efc),
                 NJ_Cap      => Integer (NJ),
                 NIsland_Cap => M.S.Ntree,
                 NIdof_Cap   => M.S.Nv);
   end Compute_Caps;

   ----------------------------------------------------------------------------
   --  Diagnostics: each procedure re-walks one clause family in Is_Valid order
   --  and reports the first failing element. Only absence of runtime errors is
   --  proven here; the postconditions let Diagnose chain them.
   ----------------------------------------------------------------------------

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
   begin
      Result := OK_Result;
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

   procedure Diagnose_Tree (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M) and then Sizes_OK (M),
     Post => (if Result.Status = OK then
                Parents_OK (M) and then Roots_OK (M) and then Welds_OK (M)
                and then Body_Joints_OK (M) and then Body_Dofs_OK (M) and then Body_Geoms_OK (M)
                and then Dof_Trees_OK (M) and then Tree_Dofs_OK (M) and then Body_Trees_OK (M))
   is
   begin
      Result := OK_Result;
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
      Diagnose_Blocks (M.Trees.Tree_Dofadr.all, M.Trees.Tree_Dofnum.all, M.Dofs.Dof_Treeid.all,
                       M.S.Ntree, Tree_Dofadr, Dof_Treeid, Result);
      if Result.Status /= OK then
         return;
      end if;
      pragma Assert (Tree_Dofs_OK (M));

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
     Pre  => Valid_Layout (M) and then Sizes_OK (M) and then Parents_OK (M) and then Welds_OK (M)
             and then Body_Joints_OK (M) and then Body_Dofs_OK (M),
     Post => (if Result.Status = OK then
                Jnt_Types_OK (M) and then Jnt_Adrs_OK (M) and then Dof_Joints_OK (M)
                and then Dof_Parents_OK (M) and then Dof_Parent_Ranges_OK (M)
                and then Madr_Range_OK (M) and then Madrs_OK (M) and then Simplenums_OK (M))
   is
   begin
      Result := OK_Result;
      for J in 0 .. M.S.Njnt - 1 loop
         if M.Joints.Jnt_Type (J) not in 0 .. 3 then
            Result := (Invalid_Enum, Jnt_Type, J);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. J => M.Joints.Jnt_Type (K) in 0 .. 3);
      end loop;
      for J in 0 .. M.S.Njnt - 1 loop
         if not Jnt_Adr_At (M, J) then
            Result := (Invalid_Joint_Layout, Jnt_Qposadr, J);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. J => Jnt_Adr_At (M, K));
      end loop;
      if M.S.Njnt = 0 then
         if M.S.Nq /= 0 or else M.S.Nv /= 0 then
            Result := (Invalid_Joint_Layout, Jnt_Qposadr, -1);
            return;
         end if;
      else
         if M.Joints.Jnt_Qposadr (M.S.Njnt - 1)
              + Qpos_Width (M.Joints.Jnt_Type (M.S.Njnt - 1)) /= M.S.Nq
         then
            Result := (Invalid_Joint_Layout, Jnt_Qposadr, M.S.Njnt - 1);
            return;
         end if;
         if M.Joints.Jnt_Dofadr (M.S.Njnt - 1)
              + Dof_Width (M.Joints.Jnt_Type (M.S.Njnt - 1)) /= M.S.Nv
         then
            Result := (Invalid_Joint_Layout, Jnt_Dofadr, M.S.Njnt - 1);
            return;
         end if;
      end if;
      pragma Assert (Jnt_Adrs_OK (M));

      for D in 0 .. M.S.Nv - 1 loop
         if not Dof_Joint_At (M, D) then
            Result := (Invalid_Dof_Chain, Dof_Jntid, D);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. D => Dof_Joint_At (M, K));
      end loop;
      for D in 0 .. M.S.Nv - 1 loop
         if not Dof_Parent_At (M, D) then
            Result := (Invalid_Dof_Chain, Dof_Parentid, D);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. D => Dof_Parent_At (M, K));
      end loop;
      pragma Assert (Dof_Parent_Ranges_OK (M));
      for D in 0 .. M.S.Nv - 1 loop
         if M.Dofs.Dof_Madr (D) not in 0 .. M.S.Nm then
            Result := (Invalid_Dof_Chain, Dof_Madr, D);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. D => M.Dofs.Dof_Madr (K) in 0 .. M.S.Nm);
      end loop;
      if M.S.Nv = 0 then
         if M.S.Nm /= 0 then
            Result := (Invalid_Dof_Chain, Dof_Madr, -1);
            return;
         end if;
      elsif M.Dofs.Dof_Madr (0) /= 0 then
         Result := (Invalid_Dof_Chain, Dof_Madr, 0);
         return;
      end if;
      for D in 0 .. M.S.Nv - 1 loop
         if not Madr_At (M, D) then
            Result := (Invalid_Dof_Chain, Dof_Madr, D);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. D => Madr_At (M, K));
      end loop;
      for D in 0 .. M.S.Nv - 1 loop
         if M.Dofs.Dof_Simplenum (D) not in 0 .. M.S.Nv - D then
            Result := (Invalid_Dof_Chain, Dof_Simplenum, D);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. D => M.Dofs.Dof_Simplenum (K) in 0 .. M.S.Nv - K);
      end loop;
   end Diagnose_Joints;

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
      --  Tasks 8b to 8d insert their Diagnose_* calls here, in Is_Valid order.

      --  Unreachable when Is_Valid (M) is false; keeps Result well defined.
      Result := (Invalid_Parameter, None, -1);
   end Diagnose;

   procedure Validate (M : in out Model; Options : Validate_Options; Result : out Load_Result) is
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
