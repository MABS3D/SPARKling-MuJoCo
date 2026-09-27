package body MJ.Rotations with SPARK_Mode is
   procedure Rotate (R : out Vector_3; Q : Quaternion; V : Vector_3) is
      Result : Vector_3;
   begin
      if V (0) = 0.0 and then V (1) = 0.0 and then V (2) = 0.0 then
         R := [0.0, 0.0, 0.0];
      elsif MJ.Quaternions.Is_Identity (Q) then
         R := V;
      else
         MJ.Quaternions.Rotate (Result, Q, V);
         --  Scalar stores avoid a packed temporary for 8-byte-aligned destinations.
         R (0) := Result (0);
         R (1) := Result (1);
         R (2) := Result (2);
      end if;
   end Rotate;

   procedure Rotate (V : in out Vector_3; Q : Quaternion) is
   begin
      if V (0) = 0.0 and then V (1) = 0.0 and then V (2) = 0.0 then
         V := [0.0, 0.0, 0.0];
      elsif not MJ.Quaternions.Is_Identity (Q) then
         declare
            Original : constant Vector_3 := V;
         begin
            Rotate (V, Q, Original);
         end;
      end if;
   end Rotate;

   procedure Rotate_Conjugate (R : out Vector_3; Q : Quaternion; V : Vector_3) is
      Conjugate : constant Quaternion := Conjugated (Q);
   begin
      Rotate (R, Conjugate, V);
   end Rotate_Conjugate;

   procedure Rotate_Conjugate (V : in out Vector_3; Q : Quaternion) is
      Conjugate : constant Quaternion := Conjugated (Q);
   begin
      Rotate (V, Conjugate);
   end Rotate_Conjugate;

   procedure Rotate (R : out Vector_3; A : Matrix_3; V : Vector_3) is
   begin
      MJ.Matrices.MulMatVec3 (R, A, V);
   end Rotate;

   procedure Rotate (V : in out Vector_3; A : Matrix_3) is
      Original : constant Vector_3 := V;
   begin
      Rotate (V, A, Original);
   end Rotate;

   procedure Rotate_Transpose (R : out Vector_3; A : Matrix_3; V : Vector_3) is
   begin
      MJ.Matrices.MulMatTVec3 (R, A, V);
   end Rotate_Transpose;

   procedure Rotate_Transpose (V : in out Vector_3; A : Matrix_3) is
      Original : constant Vector_3 := V;
   begin
      Rotate_Transpose (V, A, Original);
   end Rotate_Transpose;
end MJ.Rotations;
