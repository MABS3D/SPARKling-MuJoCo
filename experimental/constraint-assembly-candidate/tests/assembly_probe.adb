with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types;
with MJ.Constraint_Assembly; use MJ.Constraint_Assembly;

--  Whitespace protocol, deliberately outside the SPARK library.
procedure Assembly_Probe is
   subtype Real is MJ.Types.Real;
   subtype Tier0_Real is MJ.Types.Tier0_Real;
   subtype Tier1_Real is MJ.Types.Tier1_Real;
   subtype Nonneg_Tier0 is MJ.Types.Nonneg_Tier0;
   package Integers is new Integer_IO (Integer);
   package Reals is new Float_IO (Real);
   function I return Integer is
      V : Integer;
   begin
      Integers.Get (V);
      return V;
   end I;
   function F return Real is
      V : Real;
   begin
      Reals.Get (V);
      return V;
   end F;
   procedure Emit (V : Integer) is
   begin
      Integers.Put (V, Width => 0);
      Put (" ");
   end Emit;
   procedure Emit (V : Real) is
   begin
      Reals.Put (V, Fore => 1, Aft => 17, Exp => 3);
      Put (" ");
   end Emit;
   Cases : constant Positive := I;
begin
   for Case_Number in 1 .. Cases loop
      declare
         NV : constant Dof_Count := I;
         RC : constant Row_Capacity := I;
         EC : constant Entry_Capacity := I;
         Operations : constant Positive := I;
         B : Storage (RC, EC);
         Status : Result;
      begin
         B.Descriptors := (others => (0, 0, (-3.0, -4.0), 5.0, Equality, 21));
         B.Values := (others => -7.25);
         Reset (B, NV);
         for Operation in 1 .. Operations loop
            declare
               Mode : constant Natural := I;
               Before : constant Storage := B;
            begin
               case Mode is
                  when 0 =>
                     declare
                        Kind : constant Constraint_Kind := Constraint_Kind'Val (I);
                        Id : constant Natural := I;
                        N : constant Positive := I;
                        W : constant Dof_Count := I;
                        Loss : constant Nonneg_Tier0 := F;
                        Chain : Column_Array (1 .. W);
                        J : Matrix (1 .. N, 1 .. W);
                        Pos : Parameter_Array (1 .. N);
                     begin
                        for C in Chain'Range loop Chain (C) := I; end loop;
                        for R in J'Range (1) loop
                           for C in J'Range (2) loop J (R, C) := F; end loop;
                        end loop;
                        for R in Pos'Range loop
                           declare
                              Position : constant Real := F;
                              Margin : constant Real := F;
                           begin
                              Pos (R) := (Position, Margin);
                           end;
                        end loop;
                        Append (B, Kind, Id, Chain, J, Pos, Loss, Status);
                     end;
                  when 1 =>
                     declare
                        Dim : constant Contact_Dimension := I;
                        Cone : constant Cone_Kind := Cone_Kind'Val (I);
                        Id : constant Natural := I;
                        W : constant Dof_Count := I;
                        Distance : constant Tier1_Real := F;
                        Margin : constant Tier1_Real := F;
                        Mu : Friction_Array;
                        Chain : Column_Array (1 .. W);
                        J : Matrix (1 .. Dim, 1 .. W);
                     begin
                        for K in Mu'Range loop Mu (K) := F; end loop;
                        for C in Chain'Range loop Chain (C) := I; end loop;
                        for R in J'Range (1) loop
                           for C in J'Range (2) loop J (R, C) := F; end loop;
                        end loop;
                        Add_Contact (B, Id, Dim, Cone, Chain, J, Mu, Distance, Margin, Status);
                     end;
                  when 2 =>
                     declare
                        Dof : constant Column := I;
                        Loss : constant Nonneg_Tier0 := F;
                     begin
                        Add_Dof_Friction (B, Dof, Loss, Status);
                     end;
                  when 3 =>
                     declare
                        Id : constant Natural := I;
                        Dof : constant Column := I;
                        Side : constant Limit_Side := Limit_Side'Val (I);
                        Value : constant Tier0_Real := F;
                        Bound : constant Tier0_Real := F;
                        Margin : constant Tier0_Real := F;
                     begin
                        Add_Scalar_Limit (B, Id, Dof, Side, Value, Bound, Margin, Status);
                     end;
                  when 4 => Reset (B, I); Status := Skipped;
                  when others => raise Program_Error;
               end case;
               if Mode = 4 then
                  pragma Assert (B.Rows = 0 and then B.Used = 0);
                  pragma Assert (B.Descriptors = Before.Descriptors
                    and then B.Columns = Before.Columns and then B.Values = Before.Values);
               elsif Status /= Success then
                  pragma Assert (B = Before);
               else
                  for R in B.Descriptors'Range loop
                     if R <= Before.Rows or else R > B.Rows then
                        pragma Assert (B.Descriptors (R) = Before.Descriptors (R));
                     end if;
                  end loop;
                  for C in B.Values'Range loop
                     if C <= Before.Used or else C > B.Used then
                        pragma Assert (B.Values (C) = Before.Values (C)
                          and then B.Columns (C) = Before.Columns (C));
                     end if;
                  end loop;
               end if;
               Emit (Result'Pos (Status));
            end;
         end loop;
         New_Line;
         Emit (B.Dofs); Emit (B.Rows); Emit (B.Used);
         Emit (B.Ne); Emit (B.Nf); Emit (B.Nl); New_Line;
         for R in 1 .. B.Rows loop
            declare
               D : Row renames B.Descriptors (R);
            begin
               Emit (D.Offset); Emit (D.Nonzeros); Emit (Constraint_Kind'Pos (D.Kind)); Emit (D.Id);
               Emit (D.Param.Position); Emit (D.Param.Margin); Emit (D.Loss); New_Line;
            end;
         end loop;
         for C in 1 .. B.Used loop
            Emit (B.Columns (C)); Emit (B.Values (C)); New_Line;
         end loop;
      end;
   end loop;
end Assembly_Probe;
