with Ada.Command_Line;
with Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Smooth_Math;
with MJ.Spatial_Kernels;
with MJ.Bounds_Kernels;

procedure Bounds_Check_Test is
   package M renames MJ.Smooth_Math;
   package S renames MJ.Spatial_Kernels;
   Scale : constant Real := Real'Value (Ada.Command_Line.Argument (1));
   Limits : constant Real_Array := [0.0, Real'Adjacent (0.0, 1.0),
     1.0e-200 * Scale, Scale, 16.0 * Scale, 1.0e60 * Scale,
     1.0e300 * Scale, Real'Last];
   Cases : Natural := 0;
   function Interval (X, L : Real) return Boolean is (X in -L .. L);
   pragma No_Inline (Interval);
   procedure Check (Actual, Expected : Boolean) is
   begin
      Cases := Cases + 1;
      if Actual /= Expected then raise Program_Error with "bound predicate mismatch"; end if;
   end Check;

   procedure Fixed (X, L : Real) is
      V : M.Vector := [others => 0.0];
      Q : M.Quaternion := [others => 0.0];
      R : M.Matrix := [others => [others => 0.0]];
      Motion : S.Motion := [others => 0.0];
      Inertia : S.Inertia := [others => 0.0];
      Expected : constant Boolean := Interval (X, L);
   begin
      for I in V'Range loop
         V (I) := X; Check (M.Bounded (V, L), Expected); V (I) := 0.0;
      end loop;
      for I in Q'Range loop
         Q (I) := X; Check (M.Bounded (Q, L), Expected); Q (I) := 0.0;
      end loop;
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            R (I, J) := X; Check (M.Bounded (R, L), Expected); R (I, J) := 0.0;
         end loop;
      end loop;
      for I in Motion'Range loop
         Motion (I) := X; Check (S.Bounded (Motion, L), Expected); Motion (I) := 0.0;
      end loop;
      for I in Inertia'Range loop
         Inertia (I) := X; Check (S.Bounded (Inertia, L), Expected); Inertia (I) := 0.0;
      end loop;
   end Fixed;

   procedure Dynamic (First : Natural; N : Natural; X, L : Real) is
      Values : Real_Array (First .. First + (N - 1)) := [others => 0.0];
      Expected : constant Boolean := Interval (X, L);
   begin
      Check (MJ.Bounds_Kernels.All_Within (Values, L), True);
      for I in Values'Range loop
         Values (I) := X;
         Check (MJ.Bounds_Kernels.All_Within (Values, L), Expected);
         Values (I) := 0.0;
      end loop;
   end Dynamic;
   Values : Real_Array (0 .. 7);
begin
   for L of Limits loop
      Values := [0.0, -0.0, L, -L,
        Real'Adjacent (L, 0.0), -Real'Adjacent (L, 0.0),
        Real'Adjacent (L, Real'Last), -Real'Adjacent (L, Real'Last)];
      for X of Values loop
         Fixed (X, L);
         for N in 0 .. 129 loop
            Dynamic (37, N, X, L);
         end loop;
         Dynamic (0, 17, X, L);
         Dynamic (Integer'Last - 256, 257, X, L);
      end loop;
   end loop;
   Ada.Text_IO.Put_Line ("PASS" & Cases'Image & " finite boundary and SIMD-tail checks");
end Bounds_Check_Test;
