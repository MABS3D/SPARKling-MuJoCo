with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Fields; use MJ.Fields;
with MJ.Models; use MJ.Models;
with MJ.Models.Validity; use MJ.Models.Validity;
with MJ.MJB;
with MJ.File_IO;
with MJ.Model_Admission;
with MJ.Validation;

--  Test transport for real C-produced MJB images, including malformed references.
--  FLEX helper coverage is separate from the full validator's Unsupported_Flex.
procedure Admission_Probe is
   Input : Byte_Array_Access;
   Loaded : Boolean;
   M : Model;
   Result : Load_Result;
   procedure Show (Name : String; Value : Load_Result) is
   begin
      Put_Line (Name & " " & Value.Status'Image & " " & Value.Field'Image
                & " " & Integer'Image (Value.Index));
   end Show;
begin
   if Ada.Command_Line.Argument_Count /= 1 then
      raise Constraint_Error with "one MJB path required";
   end if;
   MJ.File_IO.Read_File (Ada.Command_Line.Argument (1), Input, Loaded);
   if not Loaded then raise Program_Error with "fixture cannot be read"; end if;
   MJ.MJB.Parse_Raw (Input.all, M, Result);
   Show ("PARSE", Result);
   if Result.Status /= OK then raise Program_Error with "raw parser rejected fixture"; end if;
   if not Valid_Layout (M) or else M.S.Nbody < 1 or else not Madr_Range_OK (M)
   then
      raise Program_Error with "admission helper preconditions not met";
   end if;
   MJ.Model_Admission.Check_M_CSR (M, Result); Show ("M_CSR", Result);
   MJ.Model_Admission.Check_B_CSR (M, Result); Show ("B_CSR", Result);
   MJ.Model_Admission.Check_D_CSR (M, Result); Show ("D_CSR", Result);
   MJ.Model_Admission.Check_Tendon_CSR (M, Result); Show ("TENDON_CSR", Result);
   MJ.Model_Admission.Check_Flex (M, Result); Show ("FLEX", Result);
   if Sparse_B_OK (M) and then Sparse_D_OK (M) then
      Put_Line ("HELPER_PRE TRUE");
      MJ.Model_Admission.Check_Bodies (M, Result); Show ("BODIES", Result);
      MJ.Model_Admission.Check_Dofs (M, Result); Show ("DOFS", Result);
   else
      --  A malformed CSR exercises its total diagnostic and Validate. It is
      --  outside the stated preconditions of the body/DOF composition helpers.
      Put_Line ("HELPER_PRE FALSE");
   end if;
   MJ.Model_Admission.Check_Maps (M, Result); Show ("MAPS", Result);
   MJ.Validation.Validate (M, (Contact_Cap => 0), Result); Show ("VALIDATE", Result);
   Free (M);
   Free_Byte (Input);
   if not All_Null (M) then raise Program_Error with "model was not freed"; end if;
   Put_Line ("ALL_NULL TRUE");
end Admission_Probe;
