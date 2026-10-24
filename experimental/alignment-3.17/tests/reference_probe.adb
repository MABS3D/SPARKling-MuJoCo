with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Models; use MJ.Models;
with MJ.Models.Gen_Clauses;

-- Isolate the new generated element predicate. Its precondition requires
-- matching non-null address/count arrays, not a complete allocated Model.
-- Values near twice Max_Size check the multiplied target beyond one size field.
procedure Reference_Probe is
   M : Model;
   Count : Natural := 0;
   procedure Check (Edges, Address, Width : Integer; Expected : Boolean) is
      Actual : Boolean;
   begin
      M.S.Nflexedge := Edges;
      M.Flexes.Flex_Vertedgeadr (0) := Address;
      M.Flexes.Flex_Vertedgenum (0) := Width;
      Actual := MJ.Models.Gen_Clauses.Ref_Flex_Vertedgeadr_At (M, 0);
      if Actual /= Expected then raise Program_Error with "reference predicate mismatch"; end if;
      Count := Count + 1;
   end Check;
begin
   M.Flexes.Flex_Vertedgeadr := new Int_Array'(0 => 0);
   M.Flexes.Flex_Vertedgenum := new Int_Array'(0 => 0);
   Check (Max_Size, 2 * Max_Size, 0, True);
   Check (Max_Size, 2 * Max_Size - 1, 1, True);
   Check (Max_Size, Integer'Last, 0, False);
   Check (Max_Size, -1, 1, False);
   Check (1, 2, 0, True);
   Check (1, 1, 2, False);
   Check (0, -1, 0, True);
   Check (0, 0, 1, False);
   Free_Int (M.Flexes.Flex_Vertedgeadr);
   Free_Int (M.Flexes.Flex_Vertedgenum);
   Put_Line ("PASS" & Count'Image);
end Reference_Probe;
