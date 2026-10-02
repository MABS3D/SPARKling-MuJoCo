with Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Friction_Kernels; use MJ.Friction_Kernels;
with MJ.Friction_Random;
with MJ.Pyramidal_PGS;
with Interfaces; use Interfaces;
--  Line protocol used by the native differential tests; IO outside SPARK.
procedure Friction_Probe is
   package Real_IO is new Ada.Text_IO.Float_IO (Real);
   procedure Get (X : out Real) is begin Real_IO.Get (X); end;
   procedure Put (X : Real) is
   begin Real_IO.Put (X, Fore => 1, Aft => 17, Exp => 3); Ada.Text_IO.Put (" "); end;
   function Read_Real return Real is X : Real; begin Get (X); return X; end;
   function Read_Int return Integer is (Integer (Read_Real));
   D : Dimension;
   F : Contact_Force;
   P : Pyramid;
   Mu : Friction;
   G : MJ.Friction_Random.Generator;
   U : Unsigned_32;
begin
   while not Ada.Text_IO.End_Of_File loop
      declare Op : constant Integer := Read_Int; begin
         case Op is
            when 1 | 2 =>
               D := Read_Int;
               for I in Mu'Range loop Mu (I) := Read_Real; end loop;
               if Op = 1 then
                  for I in F'Range loop F (I) := Read_Real; end loop;
                  Encode (F, Mu, D, P);
                  for X of P loop Put (X); end loop;
               else
                  for I in P'Range loop P (I) := Read_Real; end loop;
                  Decode (P, Mu, D, F);
                  for X of F loop Put (X); end loop;
               end if;
            when 3 =>
               declare
                  Kind : constant Row_Kind := Row_Kind'Val (Read_Int);
                  Old_F : constant Force_Value := Read_Real;
                  Res : constant Residual_Value := Read_Real;
                  Inv : constant Inverse_Diagonal := Read_Real;
                  Bound : constant Bound_Value := Read_Real;
                  S : constant Step_Result := Step (Kind, Old_F, Res, Inv, Bound);
               begin Put (if S.Accepted then 1.0 else 0.0); Put (S.Force); Put (S.Change); end;
            when 4 =>
               declare N : constant Natural := Read_Int; begin
                  G := (others => <>);
                  for I in 1 .. N loop MJ.Friction_Random.Next (G, U); Put (Real (U)); end loop;
               end;
            when 5 =>
               declare
                  use MJ.Pyramidal_PGS;
                  N : constant Natural := Read_Int;
                  Settings : Options;
                  AR : Matrix (1 .. N, 1 .. N);
                  B, Forces : Vector (1 .. N);
                  Kind : Kinds (1 .. N);
                  Loss : Bounds (1 .. N);
                  R : Report;
               begin
                  Settings.Iterations := Read_Int; Settings.Tolerance := Read_Real;
                  Settings.Scale := Read_Real; Settings.Nesterov := Read_Int /= 0;
                  for I in 1 .. N loop Kind (I) := Row_Kind'Val (Read_Int); end loop;
                  for I in 1 .. N loop Loss (I) := Read_Real; end loop;
                  for I in 1 .. N loop B (I) := Read_Real; end loop;
                  for I in 1 .. N loop Forces (I) := Read_Real; end loop;
                  for I in 1 .. N loop
                     for J in 1 .. N loop AR (I, J) := Read_Real; end loop;
                  end loop;
                  Solve (AR, B, Kind, Loss, Settings, Forces, R);
                  Put (Real (Status'Pos (R.Outcome))); Put (Real (R.Iterations));
                  Put (Real (R.Restarts)); Put (R.Improvement);
                  for X of Forces loop Put (X); end loop;
               end;
            when others => raise Program_Error;
         end case;
         Ada.Text_IO.New_Line;
      end;
   end loop;
end Friction_Probe;
