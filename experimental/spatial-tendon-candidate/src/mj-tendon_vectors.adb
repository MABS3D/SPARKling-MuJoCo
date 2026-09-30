package body MJ.Tendon_Vectors with SPARK_Mode is
   function Add (A, B : Vector) return Vector is
     ((A (1) + B (1), A (2) + B (2), A (3) + B (3)));
   function Sub (A, B : Vector) return Vector is
     ((A (1) - B (1), A (2) - B (2), A (3) - B (3)));
   function Scale (A : Vector; S : Real) return Vector is
     ((A (1) * S, A (2) * S, A (3) * S));
   subtype Product is Real range -1.1e200 .. 1.1e200;
   function Dot (A, B : Vector) return Real is
      X : constant Product := A (1) * B (1);
      Y : constant Product := A (2) * B (2);
      Z : constant Product := A (3) * B (3);
      XY : constant Real range -2.3e200 .. 2.3e200 := X + Y;
   begin
      return XY + Z;
   end Dot;
   function Cross (A, B : Vector) return Vector is
     ((A (2) * B (3) - A (3) * B (2),
       A (3) * B (1) - A (1) * B (3),
       A (1) * B (2) - A (2) * B (1)));
   function Multiply (M : Matrix; V : Vector; Transpose : Boolean := False)
     return Vector is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Dot_Model);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Matrix_Row);
      Result : Vector := Zero;
   begin
      for I in 1 .. 3 loop
         Result (I) := Dot (Matrix_Row (M, I, Transpose), V);
         pragma Loop_Invariant (Static => (for all K in 1 .. I => Result (K) =
           Dot_Model (Matrix_Row (M, K, Transpose), V)));
      end loop;
      return Result;
   end Multiply;
end MJ.Tendon_Vectors;
