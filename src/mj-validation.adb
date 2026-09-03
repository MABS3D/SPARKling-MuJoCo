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
           and then Rownnz'Length = N and then Rowadr'Length = N and then Colind'Length = Nnz
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
   begin
      Diagnose_CSR (M.Sparse.M_Rownnz.all, M.Sparse.M_Rowadr.all, M.Sparse.M_Colind.all,
                    M.S.Nv, M.S.Nm, M.S.Nv, M_Rowadr, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_CSR (M.Sparse.B_Rownnz.all, M.Sparse.B_Rowadr.all, M.Sparse.B_Colind.all,
                    M.S.Nbody, M.S.Nb, M.S.Nv, B_Rowadr, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_CSR (M.Sparse.D_Rownnz.all, M.Sparse.D_Rowadr.all, M.Sparse.D_Colind.all,
                    M.S.Nv, M.S.Nd, M.S.Nv, D_Rowadr, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_CSR (M.Tendons.Ten_J_Rownnz.all, M.Tendons.Ten_J_Rowadr.all, M.Tendons.Ten_J_Colind.all,
                    M.S.Ntendon, M.S.Njten, M.S.Nv, Ten_J_Rowadr, Result);
      if Result.Status /= OK then
         return;
      end if;
      for I in 0 .. M.S.Nv - 1 loop
         if M.Sparse.M_Rownnz (I) /= Row_Len (M, I) then
            Result := (Invalid_CSR, M_Rownnz, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => M.Sparse.M_Rownnz (K) = Row_Len (M, K));
      end loop;
      for I in 0 .. M.S.Nv - 1 loop
         if not M_Row_At (M, I) then
            Result := (Invalid_CSR, M_Colind, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => M_Row_At (M, K));
      end loop;
      for I in 0 .. M.S.Nv - 1 loop
         if not D_Diag_At (M, I) then
            Result := (Invalid_CSR, D_Diag, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => D_Diag_At (M, K));
      end loop;
      for K in 0 .. M.S.Nc - 1 loop
         if M.Sparse.MapM2M (K) not in 0 .. M.S.Nm - 1 then
            Result := (Invalid_CSR, MapM2M, K);
            return;
         end if;
         pragma Loop_Invariant (for all J in 0 .. K => M.Sparse.MapM2M (J) in 0 .. M.S.Nm - 1);
      end loop;
      for K in 0 .. M.S.Nd - 1 loop
         if M.Sparse.MapM2D (K) not in 0 .. M.S.Nm - 1 then
            Result := (Invalid_CSR, MapM2D, K);
            return;
         end if;
         pragma Loop_Invariant (for all J in 0 .. K => M.Sparse.MapM2D (J) in 0 .. M.S.Nm - 1);
      end loop;
      for K in 0 .. M.S.Nm - 1 loop
         if M.Sparse.MapD2M (K) not in 0 .. M.S.Nd - 1 then
            Result := (Invalid_CSR, MapD2M, K);
            return;
         end if;
         pragma Loop_Invariant (for all J in 0 .. K => M.Sparse.MapD2M (J) in 0 .. M.S.Nd - 1);
      end loop;
      for K in 0 .. M.S.Nm - 1 loop
         if M.Sparse.MapM2D (M.Sparse.MapD2M (K)) /= K then
            Result := (Invalid_CSR, MapD2M, K);
            return;
         end if;
         pragma Loop_Invariant (for all J in 0 .. K => M.Sparse.MapM2D (M.Sparse.MapD2M (J)) = J);
      end loop;
      Result := OK_Result;
   end Diagnose_Sparse;

   procedure Diagnose_Assets (M : Model; Result : out Load_Result) with
     Pre  => Valid_Layout (M) and then Refs_OK (M),
     Post => (if Result.Status = OK then
                Geom_Types_OK (M) and then Geom_Datas_OK (M) and then Sameframes_OK (M)
                and then Meshes_OK (M) and then Hfields_OK (M) and then Textures_OK (M)
                and then Texids_OK (M) and then Bvhs_OK (M) and then Octs_OK (M))
   is
   begin
      Result := OK_Result;
      for G in 0 .. M.S.Ngeom - 1 loop
         if not Geom_Type_At (M, G) then
            Result := ((if M.Geoms.Geom_Type (G) = 8 then Unsupported_Plugins else Invalid_Enum),
                       (if M.Geoms.Geom_Type (G) in 0 .. 7 then Geom_Condim else Geom_Type), G);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. G => Geom_Type_At (M, K));
      end loop;
      for G in 0 .. M.S.Ngeom - 1 loop
         if not Geom_Data_At (M, G) then
            Result := (Invalid_Reference, Geom_Dataid, G);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. G => Geom_Data_At (M, K));
      end loop;
      for I in 0 .. M.S.Nbody - 1 loop
         if M.Bodies.Body_Sameframe (I) > 4 then
            Result := (Invalid_Enum, Body_Sameframe, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => M.Bodies.Body_Sameframe (K) <= 4);
      end loop;
      for G in 0 .. M.S.Ngeom - 1 loop
         if M.Geoms.Geom_Sameframe (G) > 4 then
            Result := (Invalid_Enum, Geom_Sameframe, G);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. G => M.Geoms.Geom_Sameframe (K) <= 4);
      end loop;
      for S in 0 .. M.S.Nsite - 1 loop
         if M.Sites.Site_Sameframe (S) > 4 then
            Result := (Invalid_Enum, Site_Sameframe, S);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. S => M.Sites.Site_Sameframe (K) <= 4);
      end loop;
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
         pragma Loop_Invariant
           (for all K in 0 .. I => Mesh_Faces_At (M, K) and then Mesh_Polys_At (M, K) and then Mesh_Graph_At (M, K));
      end loop;
      for H in 0 .. M.S.Nhfield - 1 loop
         if not Hfield_At (M, H) then
            Result := (Invalid_Parameter, Hfield_Adr, H);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. H => Hfield_At (M, K));
      end loop;
      for T in 0 .. M.S.Ntex - 1 loop
         if not Texture_At (M, T) then
            Result := (Invalid_Parameter, Tex_Adr, T);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. T => Texture_At (M, K));
      end loop;
      for K in M.Materials.Mat_Texid'Range loop
         if M.Materials.Mat_Texid (K) not in -1 .. M.S.Ntex - 1 then
            Result := (Invalid_Reference, Mat_Texid, K);
            return;
         end if;
         pragma Loop_Invariant (for all J in 0 .. K => M.Materials.Mat_Texid (J) in -1 .. M.S.Ntex - 1);
      end loop;
      for L in 0 .. M.S.Nlight - 1 loop
         if M.Lights.Light_Texid (L) not in -1 .. M.S.Ntex - 1 then
            Result := (Invalid_Reference, Light_Texid, L);
            return;
         end if;
         pragma Loop_Invariant (for all J in 0 .. L => M.Lights.Light_Texid (J) in -1 .. M.S.Ntex - 1);
      end loop;
      for B in 0 .. M.S.Nbody - 1 loop
         if not Body_Bvh_At (M, B) then
            Result := (Invalid_BVH, Body_Bvhadr, B);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. B => Body_Bvh_At (M, K));
      end loop;
      for I in 0 .. M.S.Nmesh - 1 loop
         if not Mesh_Bvh_At (M, I) then
            Result := (Invalid_BVH, Mesh_Bvhadr, I);
            return;
         end if;
         pragma Loop_Invariant (for all K in 0 .. I => Mesh_Bvh_At (M, K));
      end loop;
      if not Octs_OK (M) then
         Result := (Invalid_BVH, Oct_Child, -1);
         return;
      end if;
   end Diagnose_Assets;

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
      Diagnose_Sparse (M, Result);
      if Result.Status /= OK then
         return;
      end if;
      Diagnose_Assets (M, Result);
      if Result.Status /= OK then
         return;
      end if;
      --  Tasks 8c and 8d insert their Diagnose_* calls here, in Is_Valid order.

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
