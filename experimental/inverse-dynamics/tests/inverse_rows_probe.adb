with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Assembly;
with MJ.Constraint_Solvers;
with MJ.Inverse_Constraints;
procedure Inverse_Rows_Probe is
   package CA renames MJ.Constraint_Assembly;
   package CS renames MJ.Constraint_Solvers;
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   Nv, Nr, Cases : Natural;
   Sparse : constant Boolean := Ada.Command_Line.Argument_Count = 0
     or else Ada.Command_Line.Argument (1) /= "dense";
   procedure Get (X : out Natural) is
   begin Ada.Integer_Text_IO.Get (X); end Get;
   procedure Emit (Name : String; V : Real_Array) is
   begin
      Put (Name);
      for X of V loop Put (' '); Numbers.Put (X, Fore => 1, Aft => 17, Exp => 3); end loop;
      New_Line;
   end Emit;
begin
   Get (Cases);
   for Sample in 1 .. Cases loop
      Get (Nv); Get (Nr);
      declare
         J : CA.Storage (CS.Max_Rows, CS.Max_Dofs * CS.Max_Rows);
         Rows : CS.Rows (1 .. Nr);
         Ref : CS.Vector (1 .. Nr);
         Acc : Real_Array (0 .. Nv - 1);
         F : Real_Array (1 .. Nr) := [others => 321.0];
         G : Real_Array (0 .. Nv - 1) := [others => 123.0];
         Kind, Width, Dimension : Natural;
         X : Real;
         Ok : Boolean;
      begin
         J.Rows := Nr; J.Dofs := Nv; J.Used := 0;
         for I in 1 .. Nr loop
            Get (Kind); Get (Dimension); Get (Width);
            Rows (I).Form := CS.Kind'Val (Kind); Rows (I).Dimension := Dimension;
            Numbers.Get (Rows (I).R); Numbers.Get (Rows (I).D);
            Numbers.Get (Rows (I).Bound); Numbers.Get (Rows (I).Mu);
            for Mu of Rows (I).Friction loop Numbers.Get (Mu); end loop;
            Numbers.Get (Ref (I));
            J.Descriptors (I) := (Offset => J.Used, Nonzeros => Width, others => <>);
            for K in 1 .. Width loop
               Get (Kind); Numbers.Get (X);
               J.Used := J.Used + 1; J.Columns (J.Used) := Kind; J.Values (J.Used) := X;
            end loop;
         end loop;
         for V of Acc loop Numbers.Get (V); end loop;
         MJ.Inverse_Constraints.Evaluate (J, Rows, Ref, Acc, F, G, Ok, Sparse);
         if not Ok then raise Program_Error with "row response rejected"; end if;
         Emit ("force", F); Emit ("generalized", G);
      end;
   end loop;
exception
   when X : others => Put_Line (Ada.Exceptions.Exception_Information (X));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Inverse_Rows_Probe;
