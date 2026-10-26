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
   --  Exercise the vector backend at high origins too: the historical
   --  Natural'Last case below selected only the two-element scalar path.
   for Origin_Class in 0 .. 3 loop
      for N in 1 .. 256 loop
         for Gap in 0 .. 2 loop
            declare
               Target : constant Natural :=
                 (if Origin_Class = 0 then 9
                  elsif Origin_Class = 1 then 65535 - N - Gap
                  elsif Origin_Class = 2 then 65536 - N - Gap
                  else Natural'Last - (2 * N + Gap - 1));
               Source : constant Natural := Target + N + Gap;
               Buffer : Real_Array
                 ((if Origin_Class = 0 then 7 else Target - 1) ..
                  (if Origin_Class = 3 then Natural'Last else Source + N + 1));
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
   end loop;
   --  Preserve the generic public domain across the compact metadata limit.
   --  The compact branch must neither wrap origin 65535 nor count 65536.
   for N in 65535 .. 65536 loop
      declare
         Buffer : Real_Array (0 .. 2 * N - 1) := [others => 0.125];
      begin
         Check (Buffer, 0, N, N, 0.5);
         Buffer := [others => Work_Limit];
         Check (Buffer, 0, N, N, 2.0);
      end;
   end loop;
   --  Array upper bounds need not leave space for a one-past-end index.
   declare
      Buffer : Real_Array (Natural'Last - 3 .. Natural'Last) := [others => 1.0];
   begin
      Check (Buffer, Natural'Last - 3, Natural'Last - 1, 2, 0.5);
   end;
   Put_Line ("passed" & Cases'Image & " disjoint row cases");
end Disjoint_Rows_Probe;
