with Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Data; use MJ.Data;
with MJ.Data.Flex_Elasticity;
procedure Flex_Load_Checks (M : in out MJ.Models.Model) is
   package FE renames MJ.Data.Flex_Elasticity;
   F : FE.Force_Model;
   Result : Status;
   Checks : Natural := 0;
   Body_Index, Weld_Index, Dof_Index : Natural := 0;
   type Field is (Column, Row_Address, Row_Width, Flex_Address, Flex_Count,
                  Weld, Body_Address, Body_Width, Ancestor);
   function Get (K : Field) return Integer is
     (case K is
       when Column => M.Flexes.Flexedge_J_Colind (0),
       when Row_Address => M.Flexes.Flexedge_J_Rowadr (0),
       when Row_Width => M.Flexes.Flexedge_J_Rownnz (0),
       when Flex_Address => M.Flexes.Flex_Edgeadr (0),
       when Flex_Count => M.Flexes.Flex_Edgenum (0),
       when Weld => M.Bodies.Body_Weldid (Body_Index),
       when Body_Address => M.Bodies.Body_Dofadr (Weld_Index),
       when Body_Width => M.Bodies.Body_Dofnum (Weld_Index),
       when Ancestor => M.Dofs.Dof_Parentid (Dof_Index));
   procedure Set (K : Field; Value : Integer) is
   begin
      case K is
         when Column => M.Flexes.Flexedge_J_Colind (0) := Value;
         when Row_Address => M.Flexes.Flexedge_J_Rowadr (0) := Value;
         when Row_Width => M.Flexes.Flexedge_J_Rownnz (0) := Value;
         when Flex_Address => M.Flexes.Flex_Edgeadr (0) := Value;
         when Flex_Count => M.Flexes.Flex_Edgenum (0) := Value;
         when Weld => M.Bodies.Body_Weldid (Body_Index) := Value;
         when Body_Address => M.Bodies.Body_Dofadr (Weld_Index) := Value;
         when Body_Width => M.Bodies.Body_Dofnum (Weld_Index) := Value;
         when Ancestor => M.Dofs.Dof_Parentid (Dof_Index) := Value;
      end case;
   end Set;
   procedure Expect_Accept is
   begin
      FE.Create_Forces (M, F, Result);
      if Result /= Success or else not FE.Ready (F) then
         raise Program_Error with "valid FLEX rejected: " & Result'Image;
      end if;
      declare T : constant FE.Edge_Jacobian_Trace := FE.Edge_Jacobians (F); begin
         if T.Columns /= M.Flexes.Flexedge_J_Colind.all
           or else T.Rowadr /= M.Flexes.Flexedge_J_Rowadr.all
           or else T.Rownnz /= M.Flexes.Flexedge_J_Rownnz.all then
            raise Program_Error with "compiled CSR copy";
         end if;
      end;
      FE.Create_Forces (M, F, Result);
      if Result /= Already_Allocated then raise Program_Error with "double create"; end if;
      FE.Free_Forces (F);
      if FE.Ready (F) then raise Program_Error with "free"; end if;
      Checks := Checks+1;
   end Expect_Accept;
   procedure Reject (Name : String) is
   begin
      FE.Create_Forces (M, F, Result);
      if Result /= Invalid_Model or else FE.Ready (F) then
         raise Program_Error with "invalid CSR admitted: " & Name & " " & Result'Image;
      end if;
      FE.Free_Forces (F);
      Checks := Checks+1;
   end Reject;
   procedure Reject_Value (K : Field; Value : Integer) is
      Saved : constant Integer := Get (K);
   begin
      Set (K, Value); Reject (K'Image); Set (K, Saved); Expect_Accept;
   exception when others => Set (K, Saved); raise;
   end Reject_Value;
begin
   if M.S.Nflex = 0 or else M.S.Nflexedge = 0 then
      raise Program_Error with "FLEX CSR checks require edges";
   end if;
   Expect_Accept;
   --  Select a root reached by a real flex vertex, so every malformed link
   --  below is exercised by the owned ancestry loader rather than ignored.
   Body_Index := M.Flexes.Flex_Vertbodyid (0);
   for I in M.Flexes.Flex_Vertbodyid'Range loop
      declare B : constant Natural := M.Flexes.Flex_Vertbodyid (I); begin
         if M.Bodies.Body_Dofnum (M.Bodies.Body_Weldid (B)) > 0 then
            Body_Index := B; exit;
         end if;
      end;
   end loop;
   Weld_Index := M.Bodies.Body_Weldid (Body_Index);
   Reject_Value (Weld, -1); Reject_Value (Weld, M.S.Nbody);
   Reject_Value (Body_Width, -1);
   if M.Bodies.Body_Dofnum (Weld_Index) > 0 then
      Dof_Index := M.Bodies.Body_Dofadr (Weld_Index)+M.Bodies.Body_Dofnum (Weld_Index)-1;
      Reject_Value (Body_Address, -1); Reject_Value (Body_Address, M.S.Nv);
      Reject_Value (Body_Width, M.S.Nv+1);
      Reject_Value (Ancestor, -2); Reject_Value (Ancestor, M.S.Nv);
      Reject_Value (Ancestor, Dof_Index);
      if Dof_Index < M.S.Nv-1 then Reject_Value (Ancestor, Dof_Index+1); end if;
   end if;
   if M.S.NJfe > 0 then
      Reject_Value (Column, -1); Reject_Value (Column, M.S.Nv);
   end if;
   Reject_Value (Row_Address, -1); Reject_Value (Row_Address, M.S.NJfe+1);
   Reject_Value (Row_Width, -1); Reject_Value (Row_Width, M.S.Nv+1);
   Reject_Value (Flex_Address, -1); Reject_Value (Flex_Address, M.S.Nflexedge+1);
   Reject_Value (Flex_Count, -1); Reject_Value (Flex_Count, M.S.Nflexedge+1);
   if M.S.Nv > 0 then
      declare
         Adr : constant Integer := Get (Row_Address);
         Width : constant Integer := Get (Row_Width);
      begin
         Set (Row_Address, M.S.NJfe); Set (Row_Width, 1);
         Reject ("row span"); Set (Row_Address, Adr); Set (Row_Width, Width); Expect_Accept;
      exception when others => Set (Row_Address, Adr); Set (Row_Width, Width); raise;
      end;
   end if;
   Ada.Text_IO.Put_Line ("flex-load-checks" & Checks'Image);
exception when others => FE.Free_Forces (F); raise;
end Flex_Load_Checks;
