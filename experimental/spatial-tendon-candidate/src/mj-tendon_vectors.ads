with MJ.Types; use MJ.Types;

--  Small arithmetic kernels shared by the spatial tendon candidate.
package MJ.Tendon_Vectors with SPARK_Mode is
   type Vector is array (Positive range 1 .. 3) of Real;
   type Matrix is array (Positive range 1 .. 3, Positive range 1 .. 3) of Real;
   Zero : constant Vector := (others => 0.0);
   Identity : constant Matrix :=
     ((1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0));

   function Bounded (V : Vector; Limit : Real) return Boolean is
     (V (1) in -Limit .. Limit and then V (2) in -Limit .. Limit
      and then V (3) in -Limit .. Limit);
   function Rotation_Bounded (M : Matrix) return Boolean is
     (M (1, 1) in -1.000001 .. 1.000001 and then
      M (1, 2) in -1.000001 .. 1.000001 and then
      M (1, 3) in -1.000001 .. 1.000001 and then
      M (2, 1) in -1.000001 .. 1.000001 and then
      M (2, 2) in -1.000001 .. 1.000001 and then
      M (2, 3) in -1.000001 .. 1.000001 and then
      M (3, 1) in -1.000001 .. 1.000001 and then
      M (3, 2) in -1.000001 .. 1.000001 and then
      M (3, 3) in -1.000001 .. 1.000001);

   function Add (A, B : Vector) return Vector with
     Pre => Bounded (A, 1.0e100) and then Bounded (B, 1.0e100),
     Post => (for all I in 1 .. 3 => Add'Result (I) = A (I) + B (I));
   function Sub (A, B : Vector) return Vector with
     Pre => Bounded (A, 1.0e100) and then Bounded (B, 1.0e100),
     Post => (for all I in 1 .. 3 => Sub'Result (I) = A (I) - B (I));
   function Scale (A : Vector; S : Real) return Vector with
     Pre => Bounded (A, 1.0e100) and then S in -1.0e100 .. 1.0e100,
     Post => (for all I in 1 .. 3 => Scale'Result (I) = A (I) * S);
   function Dot_Model (A, B : Vector) return Real is
     ((A (1) * B (1) + A (2) * B (2)) + A (3) * B (3)) with
     Ghost => Static, Global => null,
     Pre => Bounded (A, 1.0e100) and then Bounded (B, 1.0e100);
   function Dot (A, B : Vector) return Real with
     Pre => Bounded (A, 1.0e100) and then Bounded (B, 1.0e100),
     Post => (Static => Dot'Result = Dot_Model (A, B));
   function Cross (A, B : Vector) return Vector with
     Pre => Bounded (A, 1.0e100) and then Bounded (B, 1.0e100),
     Post => Cross'Result =
       (A (2) * B (3) - A (3) * B (2),
        A (3) * B (1) - A (1) * B (3),
        A (1) * B (2) - A (2) * B (1));
   function Matrix_Row (M : Matrix; I : Positive; Transpose : Boolean) return Vector is
     (if Transpose then (M (1, I), M (2, I), M (3, I))
      else (M (I, 1), M (I, 2), M (I, 3))) with
     Pre => I <= 3 and then Rotation_Bounded (M),
     Post => Bounded (Matrix_Row'Result, 1.000001);
   function Multiply (M : Matrix; V : Vector; Transpose : Boolean := False)
     return Vector with
     Pre => Rotation_Bounded (M) and then Bounded (V, 1.0e100),
     Post => (Static => (for all I in 1 .. 3 => Multiply'Result (I) =
       Dot_Model (Matrix_Row (M, I, Transpose), V)));
end MJ.Tendon_Vectors;
