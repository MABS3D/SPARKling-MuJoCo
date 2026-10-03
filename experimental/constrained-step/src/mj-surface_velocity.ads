with MJ.Types; use MJ.Types;

--  MuJoCo 3.14.0 mj_geomSurfaceVelocity / mj_addSurfaceVel.
--  Exact ordered binary64 operations; no claim about ideal real arithmetic.
package MJ.Surface_Velocity with SPARK_Mode is
   subtype Axis is Natural range 0 .. 2;
   type Vector is array (Axis) of Real;
   type Rotation is array (Natural range 0 .. 8) of Real;
   type Motion is array (Natural range 0 .. 5) of Real;
   type Friction is array (Natural range 0 .. 4) of Real;
   type Pose is record
      Position : Vector := [others => 0.0];
      Orientation : Rotation := [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0];
   end record;

   function Bounded (V : Vector; Limit : Real) return Boolean is
     (for all X of V => X in -Limit .. Limit) with Global => null;
   function Bounded (V : Motion; Limit : Real) return Boolean is
     (for all X of V => X in -Limit .. Limit) with Global => null;
   function Bounded (R : Rotation; Limit : Real) return Boolean is
     (for all X of R => X in -Limit .. Limit) with Global => null;
   function Active (V : Motion) return Boolean is
     (for some X of V => X /= 0.0) with Global => null;
   function Linear (V : Motion) return Vector is ([V (0), V (1), V (2)])
     with Global => null;
   function Angular (V : Motion) return Vector is ([V (3), V (4), V (5)])
     with Global => null;

   function Dot_Local (A, B, C, X, Y, Z : Real) return Real
     with Global => null,
       Pre => A in -16.0 .. 16.0 and then B in -16.0 .. 16.0 and then C in -16.0 .. 16.0
         and then X in -Max_Val .. Max_Val and then Y in -Max_Val .. Max_Val
         and then Z in -Max_Val .. Max_Val,
       Post => Dot_Local'Result in -1.0e12 .. 1.0e12
         and then Dot_Local'Result = (A * X + B * Y) + C * Z;
   function Dot_World (A, B, C, X, Y, Z : Real) return Real
     with Global => null,
       Pre => A in -16.0 .. 16.0 and then B in -16.0 .. 16.0 and then C in -16.0 .. 16.0
         and then X in -1.0e25 .. 1.0e25 and then Y in -1.0e25 .. 1.0e25
         and then Z in -1.0e25 .. 1.0e25,
       Post => Dot_World'Result in -1.0e27 .. 1.0e27
         and then Dot_World'Result = (A * X + B * Y) + C * Z;

   function Rotate (R : Rotation; V : Vector) return Vector
     with Global => null,
       Pre => Bounded (R, 16.0) and then Bounded (V, Max_Val),
       Post => (Static => Bounded (Rotate'Result, 1.0e12)
         and then Rotate'Result =
           [Dot_Local (R (0), R (1), R (2), V (0), V (1), V (2)),
            Dot_Local (R (3), R (4), R (5), V (0), V (1), V (2)),
            Dot_Local (R (6), R (7), R (8), V (0), V (1), V (2))]);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Rotate);

   function Point_Value (Linear, Angular_A, Angular_B, Offset_A, Offset_B : Real) return Real
     with Global => null,
       Pre => Linear in -1.0e12 .. 1.0e12
         and then Angular_A in -1.0e12 .. 1.0e12 and then Angular_B in -1.0e12 .. 1.0e12
         and then Offset_A in -1.0e11 .. 1.0e11 and then Offset_B in -1.0e11 .. 1.0e11,
       Post => Point_Value'Result in -1.0e24 .. 1.0e24
         and then Point_Value'Result = Linear + (Angular_A * Offset_B - Angular_B * Offset_A);

   function Geometry_Value (V, W, Arm : Vector) return Motion is
     ([Point_Value (V (0), W (1), W (2), Arm (1), Arm (2)),
       Point_Value (V (1), W (2), W (0), Arm (2), Arm (0)),
       Point_Value (V (2), W (0), W (1), Arm (0), Arm (1)),
       W (0), W (1), W (2)])
     with Global => null,
       Pre => Bounded (V, 1.0e12) and then Bounded (W, 1.0e12)
         and then Bounded (Arm, 1.0e11),
       Post => (Static => Bounded (Geometry_Value'Result, 1.0e24)
         and then (for all I in Axis => Geometry_Value'Result (I) = Point_Value
           (V (I), W ((I + 1) mod 3), W ((I + 2) mod 3),
            Arm ((I + 1) mod 3), Arm ((I + 2) mod 3)))
         and then (for all I in Axis => Geometry_Value'Result (I + 3) = W (I)));

   function Geometry (Local : Motion; P : Pose; Point : Vector) return Motion
     with Global => null,
       Pre => Bounded (Local, Max_Val) and then Bounded (P.Orientation, 16.0)
         and then Bounded (P.Position, Max_Val) and then Bounded (Point, Max_Val),
       Post => (Static => Bounded (Geometry'Result, 1.0e24)
         and then (if not Active (Local) then Geometry'Result = Motion'[others => 0.0]
           else (declare V : constant Vector := Rotate (P.Orientation, Linear (Local));
                         W : constant Vector := Rotate (P.Orientation, Angular (Local));
                         Arm : constant Vector := [Point (0) - P.Position (0),
                           Point (1) - P.Position (1), Point (2) - P.Position (2)];
                 begin Geometry'Result = Geometry_Value (V, W, Arm))));

   function Difference (First, Second : Motion; I : Natural) return Real
     with Global => null,
       Pre => I <= 5 and then Bounded (First, 1.0e24) and then Bounded (Second, 1.0e24),
       Post => Difference'Result in -1.0e25 .. 1.0e25
         and then Difference'Result = (0.0 + (-First (I))) + Second (I);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Difference);

   function Project (Frame : Rotation; V : Vector) return Vector
     with Global => null,
       Pre => Bounded (Frame, 16.0) and then Bounded (V, 1.0e25),
       Post => (Static => Bounded (Project'Result, 1.0e27)
         and then Project'Result =
           [Dot_World (Frame (0), Frame (1), Frame (2), V (0), V (1), V (2)),
            Dot_World (Frame (3), Frame (4), Frame (5), V (0), V (1), V (2)),
            Dot_World (Frame (6), Frame (7), Frame (8), V (0), V (1), V (2))]);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Project);

   function Contact (First, Second : Motion; Frame : Rotation) return Motion
     with Global => null,
       Pre => Bounded (First, 1.0e24) and then Bounded (Second, 1.0e24)
         and then Bounded (Frame, 16.0),
       Post => (Static => Bounded (Contact'Result, 1.0e27)
         and then (declare V : constant Vector := Project (Frame,
                      [Difference (First, Second, 0), Difference (First, Second, 1),
                       Difference (First, Second, 2)]);
                           W : constant Vector := Project (Frame,
                      [Difference (First, Second, 3), Difference (First, Second, 4),
                       Difference (First, Second, 5)]);
                   begin Contact'Result = [0.0, V (1), V (2), W (0), 0.0, 0.0]));

   function Row_Count (Dim : Positive; Pyramidal : Boolean := True) return Positive is
     (if Dim = 1 or else not Pyramidal then Dim else 2 * (Dim - 1))
     with Global => null, Pre => Dim = 1 or else Dim in 3 .. 6,
       Post => Row_Count'Result in 1 .. 10;
   function Row_Value (V : Motion; Mu : Friction; Dim : Positive; Edge : Natural;
                       Pyramidal : Boolean := True) return Real
     with Global => null,
       Pre => (Dim = 1 or else Dim = 3 or else Dim = 4 or else Dim = 6)
         and then Edge < Row_Count (Dim, Pyramidal) and then Bounded (V, 1.0e27)
         and then (for all X of Mu => X in 0.0 .. Max_Val),
       Post => Row_Value'Result in -1.0e38 .. 1.0e38
         and then Row_Value'Result = (if Dim = 1 or else not Pyramidal then V (Edge)
           elsif Edge mod 2 = 0 then V (0) + Mu (Edge / 2) * V (1 + Edge / 2)
           else V (0) - Mu (Edge / 2) * V (1 + Edge / 2));
end MJ.Surface_Velocity;
