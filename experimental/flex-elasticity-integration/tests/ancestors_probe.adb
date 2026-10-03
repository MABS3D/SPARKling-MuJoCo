with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Flex_Ancestors;

--  Batch leaf probe: no Model/Data owner or simulation is involved.
procedure Ancestors_Probe is
   package FA renames MJ.Flex_Ancestors;
   use type FA.Status;
   use type FA.Chain;
   Cases : Natural;
   procedure Read (A : out Int_Array) is
   begin
      for I in A'Range loop Ada.Integer_Text_IO.Get(A(I)); end loop;
   end Read;
begin
   Ada.Integer_Text_IO.Get(Cases);
   for Test in 1 .. Cases loop
      declare
         Nb, Nv, B0, B1 : Natural;
      begin
         Ada.Integer_Text_IO.Get(Nb); Ada.Integer_Text_IO.Get(Nv);
         Ada.Integer_Text_IO.Get(B0); Ada.Integer_Text_IO.Get(B1);
         if Nb=0 or else Nv>FA.Max_Dofs or else B0>=Nb or else B1>=Nb then
            raise Program_Error with "leaf probe input shape";
         end if;
         declare
            Weld, Address, Width : Int_Array(0 .. Integer(Nb)-1);
            Parents : Int_Array(0 .. Integer(Nv)-1);
            Value : FA.Chain;
            Result : FA.Status;
         begin
            Read(Weld); Read(Address); Read(Width); Read(Parents);
            FA.Build(Weld,Address,Width,Parents,B0,B1,Value,Result);
            Put("case " & Result'Image & Natural'Image(Value.Count));
            for K in 0 .. Integer(Value.Count)-1 loop
               Put(Natural'Image(Value.Col(K)));
            end loop;
            --  Failure is atomic, including every unused output slot.
            if Result/=FA.Success and then Value/=FA.Empty_Chain then
               raise Program_Error with "partial rejected chain";
            end if;
            for K in Integer(Value.Count) .. FA.Max_Dofs-1 loop
               if Value.Col(K)/=0 then raise Program_Error with "chain tail"; end if;
            end loop;
            New_Line;
         end;
      end;
   end loop;
end Ancestors_Probe;
