with MJ.Types; use MJ.Types;
with MJ.Fields; use MJ.Fields;
with MJ.Models; use MJ.Models;
with MJ.Models.Validity; use MJ.Models.Validity;
with MJ.Model_Structures;

--  Typed diagnostics for the new 3.17 clauses. Contracts are implementation
--  objectives until the minimum and composed proof receipts close.
package MJ.Model_Admission with SPARK_Mode is
   use type MJ.Model_Structures.CSR_Code;
   function CSR_Error (Item : MJ.Model_Structures.CSR_Result;
                       Width_Field, Address_Field, Column_Field : Field_Id) return Load_Result is
     (if Item.Code = MJ.Model_Structures.Valid then OK_Result else
       (Invalid_CSR,
        (case Item.Code is when MJ.Model_Structures.Width_Error => Width_Field,
         when MJ.Model_Structures.Column_Error => Column_Field, when others => Address_Field), Item.Row))
     with Global => null,
     Post => (if Item.Code = MJ.Model_Structures.Valid then CSR_Error'Result = OK_Result
       else CSR_Error'Result.Status = Invalid_CSR
         and then CSR_Error'Result.Field =
           (case Item.Code is when MJ.Model_Structures.Width_Error => Width_Field,
            when MJ.Model_Structures.Column_Error => Column_Field, when others => Address_Field)
         and then CSR_Error'Result.Index = Item.Row);
   procedure Reveal_Flex_Layout (M : Model) with
     Ghost => Static, Global => null, Pre => Valid_Layout (M),
     Post => Sizes_In_Range (M.S) and then Flex_Layout_OK (M.S, M.Flexes);
   procedure Check_Flexedge_J (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Sparse_Flexedge_J_OK (M);
   procedure Check_Flexvert_J (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Sparse_Flexvert_J_OK (M);
   procedure Check_Efm0_L (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Sparse_Efm0_L_OK (M);
   procedure Check_Efm0_Dofs (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Efm0_Dofs_OK (M);
   procedure Check_Flex (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Flex_Structures_OK (M);
   procedure Check_Bodies (M : Model; Result : out Load_Result) with
     Global => null,
     Pre => Valid_Layout (M) and then M.S.Nbody >= 1 and then Sparse_B_OK (M),
     Post => (Result.Status = OK) = B_Structure_OK (M);
   procedure Reveal_Dof_Layout (M : Model) with
     Ghost => Static, Global => null, Pre => Valid_Layout (M),
     Post => Sizes_In_Range (M.S) and then Dof_Layout_OK (M.S, M.Dofs)
       and then Sparse_Layout_OK (M.S, M.Sparse);
   procedure Check_Dofs (M : Model; Result : out Load_Result) with
     Global => null,
     Pre => Valid_Layout (M) and then Sparse_B_OK (M) and then Sparse_D_OK (M)
       and then Madr_Range_OK (M),
     Post => (Result.Status = OK) = (D_Diags_OK (M) and then D_B_Rows_OK (M));
   procedure Check_Maps (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Maps_OK (M);
   procedure Reveal_Joint_Count_Layout (S : Sizes; Joints : Joint_Arrays) with
     Ghost => Static, Global => null,
     Pre => Sizes_In_Range (S) and then Joint_Layout_OK (S, Joints),
     Post => Joints.Jnt_Limited /= null and then Joints.Jnt_Type /= null
       and then Joints.Jnt_Limited'First = Joints.Jnt_Type'First
       and then Joints.Jnt_Limited'Length = Joints.Jnt_Type'Length;
   procedure Reveal_Tendon_Layout (M : Model) with
     Ghost => Static, Global => null, Pre => Valid_Layout (M),
     Post => Sizes_In_Range (M.S) and then Tendon_Layout_OK (M.S, M.Tendons);
   procedure Check_M_CSR (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Sparse_M_OK (M)
       and then Result = CSR_Error
         (MJ.Model_Structures.Check_CSR
           (M.Sparse.M_Rownnz.all, M.Sparse.M_Rowadr.all,
            M.Sparse.M_Colind.all, M.S.Nv, M.S.Nv, M.S.Nc, Strict => True),
          M_Rownnz, M_Rowadr, M_Colind);
   procedure Check_B_CSR (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Sparse_B_OK (M)
       and then Result = CSR_Error
         (MJ.Model_Structures.Check_CSR
           (M.Sparse.B_Rownnz.all, M.Sparse.B_Rowadr.all,
            M.Sparse.B_Colind.all, M.S.Nbody, M.S.Nv, M.S.Nb, Strict => True),
          B_Rownnz, B_Rowadr, B_Colind);
   procedure Check_D_CSR (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Sparse_D_OK (M)
       and then Result = CSR_Error
         (MJ.Model_Structures.Check_CSR
           (M.Sparse.D_Rownnz.all, M.Sparse.D_Rowadr.all,
            M.Sparse.D_Colind.all, M.S.Nv, M.S.Nv, M.S.Nd, Strict => True),
          D_Rownnz, D_Rowadr, D_Colind);
   procedure Check_Tendon_CSR (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Sparse_Ten_J_OK (M)
       and then Result = CSR_Error
         (MJ.Model_Structures.Check_CSR
           (M.Tendons.Ten_J_Rownnz.all, M.Tendons.Ten_J_Rowadr.all,
            M.Tendons.Ten_J_Colind.all, M.S.Ntendon, M.S.Nv, M.S.Njten, Strict => False),
          Ten_J_Rownnz, Ten_J_Rowadr, Ten_J_Colind);
end MJ.Model_Admission;
