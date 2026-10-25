with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Smooth_Dynamics; use MJ.Smooth_Dynamics;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Solver_Kernels;

procedure Generic_Rows_Probe is
   package SK renames MJ.Solver_Kernels;
   function Bits is new Ada.Unchecked_Conversion (Real, Interfaces.Unsigned_64);
   use type Interfaces.Unsigned_64;
   Cases : Natural := 0;
   Multipliers : constant Real_Array :=
     [0.0, -1.0, 1.0, SK.Scale_Real'First, SK.Scale_Real'Last];
   Inverses : constant Real_Array := [SK.Inverse_Real'First, 1.0, 2.0, SK.Inverse_Real'Last];

   procedure Require (Condition : Boolean) is
   begin
      if not Condition then
         raise Program_Error with "generic row case" & Cases'Image;
      end if;
   end Require;

   --  Separate early-exit oracle: do not duplicate the fused reduction whose
   --  compiler behavior is under test. Bit transport above is test-only.
   function All_Work (Values : Real_Array) return Boolean is
   begin
      for Value of Values loop
         if Value not in Work_Real then return False; end if;
      end loop;
      return True;
   end All_Work;
   pragma No_Inline (All_Work);

   procedure Check_Add
     (Target : in out Real_Array; Source : Real_Array;
      Multiplier : SK.Scale_Real)
   is
      Expected : Real_Array := Target;
      Ok : Boolean;
   begin
      for I in Target'Range loop
         Expected (I) := Target (I)
           + Source (Source'First + (I - Target'First)) * Multiplier;
      end loop;
      SK.Add_Row (Target, Source, Multiplier, Ok);
      Require (Ok = All_Work (Expected));
      for I in Target'Range loop
         Require (Bits (Target (I)) = Bits (Expected (I)));
      end loop;
      Cases := Cases + 1;
   end Check_Add;

   procedure Check_Scale
     (Target : in out Real_Array; Inverse : SK.Inverse_Real)
   is
      Expected : Real_Array := Target;
      Ok : Boolean;
   begin
      for I in Target'Range loop
         Expected (I) := Target (I) * Inverse;
      end loop;
      SK.Scale_Row (Target, Inverse, Ok);
      Require (Ok = All_Work (Expected));
      for I in Target'Range loop
         Require (Bits (Target (I)) = Bits (Expected (I)));
      end loop;
      Cases := Cases + 1;
   end Check_Scale;
begin
   for N in 0 .. 256 loop
      declare
         Target : Real_Array (3 .. 3 + N - 1);
         Source : Real_Array (9 .. 9 + N - 1);
      begin
         for I in Target'Range loop
            Target (I) := Real (I) / 32.0;
         end loop;
         for I in Source'Range loop
            Source (I) := -Real (I) / 64.0;
         end loop;
         Check_Add (Target, Source, -0.125);
         Check_Scale (Target, SK.Inverse_Real'First);
         for Negative in Boolean loop
            Source := [others => (if Negative then -Work_Limit else Work_Limit)];
            for Multiplier of Multipliers loop
               Target := [others => (if Negative then -Work_Limit else Work_Limit)];
               Check_Add (Target, Source, Multiplier);
            end loop;
            for Inverse of Inverses loop
               Target := [others => (if Negative then -Work_Limit else Work_Limit)];
               Check_Scale (Target, Inverse);
            end loop;
            --  Rejection in every position, including complete SIMD blocks,
            --  scalar tails and both signs, with all other entries accepted.
            for Offset in 0 .. N - 1 loop
               Target := [others => 0.0];
               Source := [others => 0.0];
               Source (Source'First + Offset) :=
                 (if Negative then -Work_Limit else Work_Limit);
               Check_Add (Target, Source, 2.0);
               Target := [others => 0.0];
               Target (Target'First + Offset) :=
                 (if Negative then -Work_Limit else Work_Limit);
               Check_Scale (Target, 2.0);
            end loop;
            Target := [others => (if Negative then -0.0 else 0.0)];
            Source := [others => (if Negative then -0.0 else 0.0)];
            Check_Add (Target, Source, -1.0);
            Check_Scale (Target, 1.0);
         end loop;
      end;
   end loop;
   declare
      Target : Real_Array (Natural'Last - 1 .. Natural'Last) := [others => 1.0];
      Source : constant Real_Array (Natural'Last - 3 .. Natural'Last - 2) :=
        [others => -1.0];
   begin
      Check_Add (Target, Source, 0.5);
      Check_Scale (Target, 2.0);
   end;
   Put_Line ("passed" & Cases'Image & " generic row cases");
end Generic_Rows_Probe;
