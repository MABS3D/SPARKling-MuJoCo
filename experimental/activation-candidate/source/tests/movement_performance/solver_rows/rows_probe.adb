with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Solver_Kernels;
with MJ.Bounds_Kernels;

--  Checked and optimized executions of the exact same adversarial inputs.
--  Every SIMD tail length and every possible rejected lane is exercised.
procedure Rows_Probe is
   package SK renames MJ.Solver_Kernels;
   Cases : Natural := 0;
   Current_N, Current_I, Checks : Natural := 0;
   procedure Require (Condition : Boolean) is
   begin
      Checks := Checks + 1;
      if not Condition then
         raise Program_Error with "N" & Current_N'Image & " I" & Current_I'Image
           & " checks" & Checks'Image & " cases" & Cases'Image;
      end if;
   end Require;
begin
   for N in 0 .. 256 loop
      Current_N := N;
      declare
         A : Real_Array (7 .. 6 + N);
         B : Real_Array (19 .. 18 + N);
         Old : Real_Array (A'Range);
         Ok : Boolean;
      begin
         for I in A'Range loop A (I) := Real (I) / 16.0; end loop;
         for I in B'Range loop B (I) := -Real (I) / 32.0; end loop;
         Old := A;
         SK.Add_Row (A, B, 0.125, Ok);
         if not Ok or else not MJ.Bounds_Kernels.All_Within (A, Work_Limit) then
            Put_Line ("add row rejected N" & N'Image & " ok=" & Ok'Image
              & " bounded=" & MJ.Bounds_Kernels.All_Within (A, Work_Limit)'Image);
            for X of A loop Put_Line (X'Image); end loop;
         end if;
         Require (Ok and then MJ.Bounds_Kernels.All_Within (A, Work_Limit));
         for I in A'Range loop
            Require (A (I) = Old (I) + B (B'First + I - A'First) * 0.125);
         end loop;
         Old := A;
         SK.Scale_Row (A, 2.0, Ok);
         Require (Ok);
         for I in A'Range loop Require (A (I) = Old (I) * 2.0); end loop;
         Cases := Cases + 1;
         --  Inclusive limits, next representable value outside either limit,
         --  and each bad lane, including tails after a full vector block.
         A := [others => Work_Limit];
         Require (MJ.Bounds_Kernels.All_Within (A, Work_Limit));
         A := [others => -Work_Limit];
         Require (MJ.Bounds_Kernels.All_Within (A, Work_Limit));
         for I in A'Range loop
            Current_I := I;
            for Negative in Boolean loop
               A := [others => 0.0];
               A (I) := (if Negative then -Real'Adjacent (Work_Limit, Real'Last)
                         else Real'Adjacent (Work_Limit, Real'Last));
               Require (not MJ.Bounds_Kernels.All_Within (A, Work_Limit));
               --  All inputs accepted, exactly one output outside Work_Real.
               A := [others => 0.0]; B := [others => 0.0];
               B (B'First + I - A'First) := (if Negative then -Work_Limit else Work_Limit);
               SK.Add_Row (A, B, 2.0, Ok);
               Require (not Ok and then not MJ.Bounds_Kernels.All_Within (A, Work_Limit));
               Require (A (I) = B (B'First + I - A'First) * 2.0);
               A := [others => 0.0];
               A (I) := (if Negative then -Work_Limit else Work_Limit);
               SK.Scale_Row (A, 2.0, Ok);
               Require (not Ok and then not MJ.Bounds_Kernels.All_Within (A, Work_Limit));
               Cases := Cases + 1;
            end loop;
         end loop;
         --  Largest permitted inputs stay finite even when the row is rejected.
         A := [others => Work_Limit]; B := [others => Work_Limit];
         SK.Add_Row (A, B, SK.Scale_Real'Last, Ok);
         Require (Ok = (N = 0));
         Require (MJ.Bounds_Kernels.All_Within (A, SK.Update_Real'Last));
         Cases := Cases + 1;
      end;
   end loop;
   Put_Line ("passed row cases" & Cases'Image);
end Rows_Probe;
