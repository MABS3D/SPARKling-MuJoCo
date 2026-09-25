with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Smooth_Dynamics; use MJ.Smooth_Dynamics;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Solver_Kernels;

procedure Disjoint_Rows_Probe is
   package SK renames MJ.Solver_Kernels;
   Cases : Natural := 0;
   procedure Require (Condition : Boolean) is
   begin
      if not Condition then raise Program_Error with "case" & Cases'Image; end if;
   end Require;

   procedure Check (Buffer : in out Real_Array; Target, Source : Natural;
                    Count : Positive; Multiplier : SK.Scale_Real) is
      Old : constant Real_Array := Buffer;
      Expected : Real_Array := Buffer;
      Ok, Expected_Ok : Boolean;
   begin
      for I in Target .. Target + Count - 1 loop
         Expected (I) := Old (I) + Old (Source + (I - Target)) * Multiplier;
      end loop;
      Expected_Ok := Work_Array (Expected);
      SK.Add_Row_Disjoint (Buffer, Target, Source, Count, Multiplier, Ok);
      Require (Buffer = Expected and then Ok = Expected_Ok);
      Cases := Cases + 1;
   end Check;
begin
   for N in 1 .. 256 loop
      for Gap in 0 .. 2 loop
         declare
            Target : constant Natural := 9;
            Source : constant Natural := Target + N + Gap;
            Buffer : Real_Array (7 .. Source + N + 1);
         begin
            for I in Buffer'Range loop Buffer (I) := Real (I) / 32.0; end loop;
            Check (Buffer, Target, Source, N, -0.125);
            for Negative in Boolean loop
               Buffer := [others => (if Negative then -Work_Limit else Work_Limit)];
               Check (Buffer, Target, Source, N, 0.0);
               Buffer := [others => Work_Limit];
               Check (Buffer, Target, Source, N, SK.Scale_Real'Last);
            end loop;
            if N <= 33 or else N in 63 .. 66 or else N in 127 .. 130 or else N in 255 .. 256 then
               for A in 0 .. N - 1 loop
                  for Negative in Boolean loop
                     Buffer := [others => 0.0];
                     Buffer (Source + A) := (if Negative then -Work_Limit else Work_Limit);
                     Check (Buffer, Target, Source, N, 2.0);
                  end loop;
               end loop;
            end if;
         end;
      end loop;
   end loop;
   --  Array upper bounds need not leave space for a one-past-end index.
   declare
      Buffer : Real_Array (Natural'Last - 3 .. Natural'Last) := [others => 1.0];
   begin
      Check (Buffer, Natural'Last - 3, Natural'Last - 1, 2, 0.5);
   end;
   Put_Line ("passed" & Cases'Image & " disjoint row cases");
end Disjoint_Rows_Probe;
