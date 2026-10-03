package body MJ.Surface_Velocity with SPARK_Mode is
   function Dot_Local (A, B, C, X, Y, Z : Real) return Real is
      subtype Product is Real range -2.0e11 .. 2.0e11;
      subtype Sum is Real range -4.0e11 .. 4.0e11;
      P0 : constant Product := A * X;
      P1 : constant Product := B * Y;
      P2 : constant Product := C * Z;
      S : constant Sum := P0 + P1;
   begin
      return S + P2;
   end Dot_Local;
   function Dot_World (A, B, C, X, Y, Z : Real) return Real is
      subtype Product is Real range -2.0e26 .. 2.0e26;
      subtype Sum is Real range -4.0e26 .. 4.0e26;
      P0 : constant Product := A * X;
      P1 : constant Product := B * Y;
      P2 : constant Product := C * Z;
      S : constant Sum := P0 + P1;
   begin
      return S + P2;
   end Dot_World;
   function Rotate (R : Rotation; V : Vector) return Vector is
     ([Dot_Local (R (0), R (1), R (2), V (0), V (1), V (2)),
       Dot_Local (R (3), R (4), R (5), V (0), V (1), V (2)),
       Dot_Local (R (6), R (7), R (8), V (0), V (1), V (2))]);

   function Point_Value (Linear, Angular_A, Angular_B, Offset_A, Offset_B : Real) return Real is
      subtype Product is Real range -2.0e23 .. 2.0e23;
      subtype Delta_Value is Real range -4.0e23 .. 4.0e23;
      A : constant Product := Angular_A * Offset_B;
      B : constant Product := Angular_B * Offset_A;
      D : constant Delta_Value := A - B;
   begin
      return Linear + D;
   end Point_Value;

   function Geometry (Local : Motion; P : Pose; Point : Vector) return Motion is
     (if not Active (Local) then Motion'[others => 0.0]
      else Geometry_Value
        (Rotate (P.Orientation, Linear (Local)),
         Rotate (P.Orientation, Angular (Local)),
         [Point (0) - P.Position (0), Point (1) - P.Position (1), Point (2) - P.Position (2)]));

   function Difference (First, Second : Motion; I : Natural) return Real is
     ((0.0 + (-First (I))) + Second (I));

   function Project (Frame : Rotation; V : Vector) return Vector is
     ([Dot_World (Frame (0), Frame (1), Frame (2), V (0), V (1), V (2)),
       Dot_World (Frame (3), Frame (4), Frame (5), V (0), V (1), V (2)),
       Dot_World (Frame (6), Frame (7), Frame (8), V (0), V (1), V (2))]);

   function Contact (First, Second : Motion; Frame : Rotation) return Motion is
      V : constant Vector := [Difference (First, Second, 0),
        Difference (First, Second, 1), Difference (First, Second, 2)];
      W : constant Vector := [Difference (First, Second, 3),
        Difference (First, Second, 4), Difference (First, Second, 5)];
      Tangent : constant Vector := Project (Frame, V);
      Spin : constant Vector := Project (Frame, W);
   begin
      return [0.0, Tangent (1), Tangent (2), Spin (0), 0.0, 0.0];
   end Contact;

   function Row_Value (V : Motion; Mu : Friction; Dim : Positive; Edge : Natural;
                       Pyramidal : Boolean := True) return Real is
     (if Dim = 1 or else not Pyramidal then V (Edge)
      elsif Edge mod 2 = 0 then V (0) + Mu (Edge / 2) * V (1 + Edge / 2)
      else V (0) - Mu (Edge / 2) * V (1 + Edge / 2));
end MJ.Surface_Velocity;
