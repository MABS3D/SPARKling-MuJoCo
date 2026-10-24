with MJ.Model_Structures;
package body MJ.Model_Admission with SPARK_Mode is
   package S renames MJ.Model_Structures;
   use type S.CSR_Code;
   procedure Check_Flex (M : Model; Result : out Load_Result) is
      Item : S.CSR_Result;
   begin
      Item := S.Check_CSR (M.Flexes.Flexedge_J_Rownnz.all, M.Flexes.Flexedge_J_Rowadr.all,
        M.Flexes.Flexedge_J_Colind.all, M.S.Nflexedge, M.S.Nv, M.S.NJfe);
      Result := CSR_Error (Item, Flexedge_J_Rownnz, Flexedge_J_Rowadr, Flexedge_J_Colind);
      if Result.Status /= OK then return; end if;
      Item := S.Check_CSR (M.Flexes.Flexvert_J_Rownnz.all, M.Flexes.Flexvert_J_Rowadr.all,
        M.Flexes.Flexvert_J_Colind.all, 2*M.S.Nflexvert, M.S.Nv, 2*M.S.NJfv);
      Result := CSR_Error (Item, Flexvert_J_Rownnz, Flexvert_J_Rowadr, Flexvert_J_Colind);
      if Result.Status /= OK then return; end if;
      Item := S.Check_CSR (M.Flexes.Efm0_L_Rownnz.all, M.Flexes.Efm0_L_Rowadr.all,
        M.Flexes.Efm0_L_Colind.all, M.S.Nefm0dof, M.S.Nefm0dof, M.S.Nefm0L);
      Result := CSR_Error (Item, Efm0_L_Rownnz, Efm0_L_Rowadr, Efm0_L_Colind);
      if Result.Status /= OK then return; end if;
      for K in 0 .. M.S.Nefm0dof-1 loop
         if M.Flexes.Efm0_Dofid (K) not in 0 .. M.S.Nv-1 then
            Result := (Invalid_Reference, Efm0_Dofid, K); return;
         end if;
         pragma Loop_Invariant (for all J in 0 .. K => M.Flexes.Efm0_Dofid (J) in 0 .. M.S.Nv-1);
      end loop;
      Result := OK_Result;
   end Check_Flex;
   procedure Check_Bodies (M : Model; Result : out Load_Result) is
      Parent : Integer;
      Count : Int64;
   begin
      if not B_Inputs_OK (M) then Result := (Invalid_Tree, Body_Parentid, -1); return; end if;
      if not B_Root_OK (M) then Result := (Invalid_CSR, B_Rownnz, 0); return; end if;
      for B in 1 .. M.S.Nbody-1 loop
         Parent := M.Bodies.Body_Parentid (B);
         if not B_Parent_Subset_At (M, B) then Result := (Invalid_CSR, B_Colind, B); return; end if;
         Count := S.Ancestor_Count (M.Bodies.Body_Parentid.all, M.Bodies.Body_Weldid.all,
           M.Bodies.Body_Dofnum.all, M.S.Nv, M.Bodies.Body_Weldid (Parent));
         if Count > Int64 (M.Sparse.B_Rownnz (B)) or else Count > Int64 (M.Sparse.B_Rownnz (Parent)) then
            Result := (Invalid_CSR, B_Rownnz, B); return;
         end if;
         pragma Loop_Invariant (for all I in 1 .. B => B_Parent_Subset_At (M, I) and then B_Ancestor_At (M, I));
      end loop;
      Result := OK_Result;
   end Check_Bodies;
   procedure Check_Dofs (M : Model; Result : out Load_Result) is
      Body_Id : Integer;
   begin
      for D in 0 .. M.S.Nv-1 loop
         if not D_Diag_At (M, D) then Result := (Invalid_CSR, D_Diag, D); return; end if;
         Body_Id := M.Dofs.Dof_Bodyid (D);
         if Body_Id not in 0 .. M.S.Nbody-1 then Result := (Invalid_Reference, Dof_Bodyid, D); return; end if;
         if M.Sparse.D_Rownnz (D) /= M.Sparse.B_Rownnz (Body_Id) then
            Result := (Invalid_CSR, D_Rownnz, D); return;
         end if;
         if not D_B_Row_At (M, D) then Result := (Invalid_CSR, D_Colind, D); return; end if;
         pragma Loop_Invariant (for all I in 0 .. D => D_Diag_At (M, I) and then D_B_Row_At (M, I));
      end loop;
      Result := OK_Result;
   end Check_Dofs;
end MJ.Model_Admission;
