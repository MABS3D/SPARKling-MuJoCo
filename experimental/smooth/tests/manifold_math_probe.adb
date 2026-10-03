with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Manifold_Math;

procedure Manifold_Math_Probe is
   package RIO is new Ada.Text_IO.Float_IO (Real);
   package IIO is new Ada.Text_IO.Integer_IO (Integer);
   Count, Mode : Integer;
   Q, R : Quaternion;
   V : Vector;
   H : Real;
begin
   IIO.Get (Count);
   for Case_Id in 1 .. Count loop
      IIO.Get (Mode);
      for X of Q loop RIO.Get (X); end loop;
      for X of V loop RIO.Get (X); end loop;
      RIO.Get (H);
      case Mode is
         when 0 => R := MJ.Manifold_Math.Normalized (Q);
         when 1 => R := MJ.Manifold_Math.Rotation_Increment (V, H);
         when 2 => R := MJ.Manifold_Math.Integrated (Q, V, H);
         when others => raise Constraint_Error;
      end case;
      for X of R loop RIO.Put (X, Fore => 1, Aft => 17, Exp => 4); Put (' '); end loop;
      New_Line;
   end loop;
end Manifold_Math_Probe;
