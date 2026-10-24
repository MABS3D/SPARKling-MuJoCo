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
     with Global => null;
   procedure Check_Flex (M : Model; Result : out Load_Result) with
     Global => null, Pre => Valid_Layout (M),
     Post => (Result.Status = OK) = Flex_Structures_OK (M);
   procedure Check_Bodies (M : Model; Result : out Load_Result) with
     Global => null,
     Pre => Valid_Layout (M) and then M.S.Nbody >= 1 and then Sparse_B_OK (M),
     Post => (Result.Status = OK) = B_Structure_OK (M);
   procedure Check_Dofs (M : Model; Result : out Load_Result) with
     Global => null,
     Pre => Valid_Layout (M) and then Sparse_B_OK (M) and then Sparse_D_OK (M)
       and then Madr_Range_OK (M),
     Post => (Result.Status = OK) = (D_Diags_OK (M) and then D_B_Rows_OK (M));
end MJ.Model_Admission;
