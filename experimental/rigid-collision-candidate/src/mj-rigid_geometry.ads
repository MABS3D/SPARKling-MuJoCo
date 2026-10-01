with MJ.Types; use MJ.Types;
with Interfaces;

package MJ.Rigid_Geometry with SPARK_Mode is
   use type Interfaces.Unsigned_32;
   Max_Geoms : constant := 4096;
   Max_Pairs : constant := 65536;
   subtype Geom_Id is Natural range 0 .. Max_Geoms - 1;
   subtype Count is Natural range 0 .. Max_Geoms;
   subtype Axis is Natural range 0 .. 2;
   subtype Coordinate is Real range -1.0e10 .. 1.0e10;
   type Vec is array (Axis) of Real;
   subtype Matrix_Entry is Real range -4.0 .. 4.0;
   type Matrix is array (Natural range 0 .. 8) of Matrix_Entry;
   Zero : constant Vec := [others => 0.0];
   Identity : constant Matrix := [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0];
   type Shape_Kind is (Plane, Sphere, Capsule, Ellipsoid, Cylinder, Box);
   type Shape is record
      Kind : Shape_Kind := Sphere;
      Size : Vec := [0.1, 0.1, 0.1];
      Body_Id, Weld, Weld_Parent : Natural range 0 .. 65535 := 0;
      Dynamic : Boolean := False;
      Contype, Conaffinity : Interfaces.Unsigned_32 := 1;
      Margin, Gap : Real range 0.0 .. 1.0e10 := 0.0;
   end record;
   type Shape_Array is array (Natural range <>) of Shape;
   type Pose is record
      Position : Vec := Zero;
      Rotation : Matrix := Identity;
      Asleep : Boolean := False;
   end record;
   type Pose_Array is array (Natural range <>) of Pose;
   type Pair is record
      First, Second : Geom_Id;
   end record;
   type Pair_Array is array (Natural range <>) of Pair;
   type Pair_List is record
      Length : Natural range 0 .. Max_Pairs := 0;
      Items : Pair_Array (0 .. Max_Pairs - 1);
   end record;
   type Explicit_Pair is record
      Geoms : Pair;
      Margin : Real range 0.0 .. 1.0e10 := 0.0;
   end record;
   type Explicit_Array is array (Natural range <>) of Explicit_Pair;
   type Body_Pair is record
      First, Second : Natural range 0 .. 65535 := 0;
   end record;
   type Exclusion_Array is array (Natural range <>) of Body_Pair;
   type Status is (Success, Invalid_Input, Capacity_Limit, Numeric_Limit, Iteration_Limit);
   type Decision is (Separated, Contact, Unresolved);
   type Options is record
      Filter_Parent : Boolean := True;
      Sleep_Filter : Boolean := False;
      Enabled : Boolean := True;
      Tolerance : Real range 1.0e-15 .. 1.0e-2 := 1.0e-6;
      Iterations : Positive range 1 .. 1000 := 100;
   end record;

   function Valid_Shape (S : Shape) return Boolean is
     ((for all X of S.Size => X in 0.0 .. 1.0e10)
      and then (if S.Kind /= Plane then S.Size (0) > 0.0)
      and then (if S.Kind in Capsule | Cylinder then S.Size (1) > 0.0)
      and then (if S.Kind in Box | Ellipsoid then S.Size (1) > 0.0 and S.Size (2) > 0.0));
   function Valid_Pose (P : Pose) return Boolean is
     ((for all X of P.Position => X in Coordinate)
      and then (for all X of P.Rotation => X in -1.0000000001 .. 1.0000000001)
      and then (for all I in Axis =>
        abs (((P.Rotation (I)*P.Rotation (I)+P.Rotation (3+I)*P.Rotation (3+I))
             +P.Rotation (6+I)*P.Rotation (6+I))-1.0) <= 1.0e-10)
      and then (for all I in Axis => (for all J in Axis =>
        (if I /= J then abs ((P.Rotation (I)*P.Rotation (J)+P.Rotation (3+I)*P.Rotation (3+J))
                            +P.Rotation (6+I)*P.Rotation (6+J)) <= 1.0e-10))));
   --  Orientation has no effect on a sphere. Other rigid primitives require
   --  an orthogonal frame; the runtime admission check is shape-aware.
   function Valid_Placement (S : Shape; P : Pose) return Boolean is
     ((for all X of P.Position => X in Coordinate)
      and then (S.Kind = Sphere or else Valid_Pose (P))) with Global => null;
   function Compatible (A, B : Shape) return Boolean is
     ((A.Contype and B.Conaffinity) /= 0 or else (B.Contype and A.Conaffinity) /= 0)
     with Global => null;
   function Body_Allowed (A, B : Shape; PA, PB : Pose; O : Options) return Boolean is
     (A.Weld /= B.Weld and then (A.Dynamic or B.Dynamic)
      and then (not O.Sleep_Filter or else
        (not (PA.Asleep and PB.Asleep)
         and then not (PA.Asleep and B.Weld = 0)
         and then not (PB.Asleep and A.Weld = 0)))
      and then (not O.Filter_Parent or else A.Weld = 0 or else B.Weld = 0 or else
        (A.Weld /= B.Weld_Parent and B.Weld /= A.Weld_Parent)))
     with Global => null;
   function Canonical (A, B : Geom_Id) return Pair is
     (if A < B then (A, B) else (B, A))
     with Global => null, Post => Canonical'Result.First = Geom_Id'Min (A, B)
       and Canonical'Result.Second = Geom_Id'Max (A, B);
   function Before (A, B : Pair) return Boolean is
     (A.First < B.First or else (A.First = B.First and then A.Second < B.Second));
end MJ.Rigid_Geometry;
