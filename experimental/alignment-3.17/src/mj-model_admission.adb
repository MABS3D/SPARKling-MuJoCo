with MJ.Model_Structures;
package body MJ.Model_Admission with SPARK_Mode is
   package S renames MJ.Model_Structures;
   use type S.CSR_Code;
   procedure Reveal_Flex_Layout (M : Model) is
   begin
      null;
   end Reveal_Flex_Layout;
   procedure Check_Flexedge_J (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      Item : S.CSR_Result;
   begin
      Reveal_Flex_Layout (M);
      Item := S.Check_CSR (M.Flexes.Flexedge_J_Rownnz.all, M.Flexes.Flexedge_J_Rowadr.all,
        M.Flexes.Flexedge_J_Colind.all, M.S.Nflexedge, M.S.Nv, M.S.NJfe);
      Result := CSR_Error (Item, Flexedge_J_Rownnz, Flexedge_J_Rowadr, Flexedge_J_Colind);
   end Check_Flexedge_J;
   procedure Check_Flexvert_J (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      Item : S.CSR_Result;
   begin
      Reveal_Flex_Layout (M);
      Item := S.Check_CSR (M.Flexes.Flexvert_J_Rownnz.all, M.Flexes.Flexvert_J_Rowadr.all,
        M.Flexes.Flexvert_J_Colind.all, 2*M.S.Nflexvert, M.S.Nv, 2*M.S.NJfv);
      Result := CSR_Error (Item, Flexvert_J_Rownnz, Flexvert_J_Rowadr, Flexvert_J_Colind);
   end Check_Flexvert_J;
   procedure Check_Efm0_L (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      Item : S.CSR_Result;
   begin
      Reveal_Flex_Layout (M);
      Item := S.Check_CSR (M.Flexes.Efm0_L_Rownnz.all, M.Flexes.Efm0_L_Rowadr.all,
        M.Flexes.Efm0_L_Colind.all, M.S.Nefm0dof, M.S.Nefm0dof, M.S.Nefm0L);
      Result := CSR_Error (Item, Efm0_L_Rownnz, Efm0_L_Rowadr, Efm0_L_Colind);
   end Check_Efm0_L;
   procedure Check_Efm0_Dofs (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
   begin
      Reveal_Flex_Layout (M);
      for K in 0 .. M.S.Nefm0dof-1 loop
         if M.Flexes.Efm0_Dofid (K) not in 0 .. M.S.Nv-1 then
            Result := (Invalid_Reference, Efm0_Dofid, K); return;
         end if;
         pragma Loop_Invariant (for all J in 0 .. K => M.Flexes.Efm0_Dofid (J) in 0 .. M.S.Nv-1);
      end loop;
      Result := OK_Result;
   end Check_Efm0_Dofs;
   procedure Check_Flex (M : Model; Result : out Load_Result) is
      --  Compose the independently proved clauses as abstract predicates.
      --  Hiding their definitions changes only the proof context.
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_Flexedge_J_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_Flexvert_J_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_Efm0_L_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Efm0_Dofs_OK);
   begin
      Check_Flexedge_J (M, Result);
      if Result.Status /= OK then return; end if;
      Check_Flexvert_J (M, Result);
      if Result.Status /= OK then return; end if;
      Check_Efm0_L (M, Result);
      if Result.Status /= OK then return; end if;
      Check_Efm0_Dofs (M, Result);
   end Check_Flex;
   procedure Check_Bodies (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_B_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", B_Inputs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", B_Root_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", B_Parent_Subset_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", B_Ancestor_At);
   begin
      if not B_Inputs_OK (M) then Result := (Invalid_Tree, Body_Parentid, -1); return; end if;
      if not B_Root_OK (M) then Result := (Invalid_CSR, B_Rownnz, 0); return; end if;
      for B in 1 .. M.S.Nbody-1 loop
         if not B_Parent_Subset_At (M, B) then Result := (Invalid_CSR, B_Colind, B); return; end if;
         if not B_Ancestor_At (M, B) then Result := (Invalid_CSR, B_Rownnz, B); return; end if;
         pragma Loop_Invariant (for all I in 1 .. B => B_Parent_Subset_At (M, I) and then B_Ancestor_At (M, I));
      end loop;
      Result := OK_Result;
   end Check_Bodies;
   procedure Reveal_Dof_Layout (M : Model) is
   begin
      null;
   end Reveal_Dof_Layout;
   procedure Check_Dofs (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_B_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_D_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Madr_Range_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", D_Diag_At);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", D_B_Row_At);
      Body_Id : Integer;
   begin
      Reveal_Dof_Layout (M);
      for D in 0 .. M.S.Nv-1 loop
         if not D_Diag_At (M, D) then Result := (Invalid_CSR, D_Diag, D); return; end if;
         if not D_B_Row_At (M, D) then
            --  Classify only a rejected row; a successful row needs no second
            --  body-ID or width check. The predicate guards its own accesses.
            Body_Id := M.Dofs.Dof_Bodyid (D);
            if Body_Id not in 0 .. M.S.Nbody-1 then
               Result := (Invalid_Reference, Dof_Bodyid, D);
            elsif M.Sparse.D_Rownnz (D) /= M.Sparse.B_Rownnz (Body_Id) then
               Result := (Invalid_CSR, D_Rownnz, D);
            else
               Result := (Invalid_CSR, D_Colind, D);
            end if;
            return;
         end if;
         pragma Loop_Invariant (for all I in 0 .. D => D_Diag_At (M, I) and then D_B_Row_At (M, I));
      end loop;
      Result := OK_Result;
   end Check_Dofs;
   procedure Check_Maps (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Maps_OK);
   begin
      Reveal_Dof_Layout (M);
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
   end Check_Maps;
   procedure Reveal_Joint_Count_Layout (S : Sizes; Joints : Joint_Arrays) is
   begin
      null;
   end Reveal_Joint_Count_Layout;
   procedure Reveal_Tendon_Layout (M : Model) is
   begin
      null;
   end Reveal_Tendon_Layout;
   procedure Check_M_CSR (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      Item : S.CSR_Result;
   begin
      Reveal_Dof_Layout (M);
      Item := S.Check_CSR (M.Sparse.M_Rownnz.all, M.Sparse.M_Rowadr.all,
                          M.Sparse.M_Colind.all, M.S.Nv, M.S.Nv, M.S.Nc, Strict => True);
      Result := CSR_Error (Item, M_Rownnz, M_Rowadr, M_Colind);
   end Check_M_CSR;
   procedure Check_B_CSR (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      Item : S.CSR_Result;
   begin
      Reveal_Dof_Layout (M);
      Item := S.Check_CSR (M.Sparse.B_Rownnz.all, M.Sparse.B_Rowadr.all,
                          M.Sparse.B_Colind.all, M.S.Nbody, M.S.Nv, M.S.Nb, Strict => True);
      Result := CSR_Error (Item, B_Rownnz, B_Rowadr, B_Colind);
   end Check_B_CSR;
   procedure Check_D_CSR (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      Item : S.CSR_Result;
   begin
      Reveal_Dof_Layout (M);
      Item := S.Check_CSR (M.Sparse.D_Rownnz.all, M.Sparse.D_Rowadr.all,
                          M.Sparse.D_Colind.all, M.S.Nv, M.S.Nv, M.S.Nd, Strict => True);
      Result := CSR_Error (Item, D_Rownnz, D_Rowadr, D_Colind);
   end Check_D_CSR;
   procedure Check_Tendon_CSR (M : Model; Result : out Load_Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      Item : S.CSR_Result;
   begin
      Reveal_Tendon_Layout (M);
      Item := S.Check_CSR (M.Tendons.Ten_J_Rownnz.all, M.Tendons.Ten_J_Rowadr.all,
                          M.Tendons.Ten_J_Colind.all, M.S.Ntendon, M.S.Nv, M.S.Njten, Strict => False);
      Result := CSR_Error (Item, Ten_J_Rownnz, Ten_J_Rowadr, Ten_J_Colind);
   end Check_Tendon_CSR;
end MJ.Model_Admission;
