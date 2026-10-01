with MJ.Types; use MJ.Types;
with MJ.Tendon_Vectors; use MJ.Tendon_Vectors;
with MJ.Tendon_Geometry; use MJ.Tendon_Geometry;

package MJ.Spatial_Tendons with SPARK_Mode is
   type Site is record
      Position : Vector := Zero;
      Body_Id : Natural := 0;
   end record;
   type Geometry is record
      Position : Vector := Zero;
      Orientation : Matrix := Identity;
      Radius : Real := 0.0;
      Kind : Geometry_Kind := Sphere;
      Body_Id : Natural := 0;
   end record;
   type Node_Kind is (Site_Node, Geometry_Node, Pulley_Node);
   type Node is record
      Kind : Node_Kind := Site_Node;
      Object_Id : Natural := 0;
      Side_Id : Integer := -1;
      Divisor : Real := 1.0;
   end record;
   type Site_Array is array (Natural range <>) of Site;
   type Geometry_Array is array (Natural range <>) of Geometry;
   type Route_Array is array (Natural range <>) of Node;
   type Vector_Array is array (Natural range <>) of Vector;
   --  World linear/angular Jacobian columns evaluated at each Origins point.
   --  A COM Jacobian must be paired with the COM, not with the body position.
   type Body_Jacobian is array (Natural range <>, Natural range <>) of Vector;
   type Path_Point is record
      Position : Vector := Zero;
      Object_Id : Integer := -1; -- site = -1, pulley = -2, otherwise geom id
   end record;
   type Point_Array is array (Natural range <>) of Path_Point;
   type Evaluation_Status is (Success, Numeric_Limit);

   function Path_Node_Valid (Route : Route_Array; Sites : Site_Array;
                            Geometries : Geometry_Array; K : Natural) return Boolean is
     (case Route (K).Kind is
        when Site_Node => Route (K).Object_Id in Sites'Range,
        when Geometry_Node => K > 0 and then K < Route'Last
          and then Route (K - 1).Kind = Site_Node and then Route (K + 1).Kind = Site_Node
          and then Route (K).Object_Id in Geometries'Range
          and then (Route (K).Side_Id = -1 or else Route (K).Side_Id in Sites'Range),
        when Pulley_Node => K < Route'Last and then Route (K + 1).Kind = Site_Node
          and then Route (K).Divisor in 1.0e-10 .. 1.0e10) with
     Pre => Route'First = 0 and then Route'Length in 2 .. 4096 and then K in Route'Range;
   function Path_Layout (Route : Route_Array; Sites : Site_Array;
                         Geometries : Geometry_Array) return Boolean is
     (Route'First = 0 and then Route'Length in 2 .. 4096
      and then Route (Route'Last).Kind = Site_Node
      and then (for all K in Route'Range => Path_Node_Valid (Route, Sites, Geometries, K)));

   function Valid_Path (Route : Route_Array; Sites : Site_Array;
                        Geometries : Geometry_Array) return Boolean with
     Post => (if Valid_Path'Result then Path_Layout (Route, Sites, Geometries));
   --  Validate topology once when constructing a route. Geometry must be
   --  between sites; pulley divides the following branch (does not multiply
   --  the previous divisor). Each branch contains at least two sites.

   function Valid_Kinematics
     (Sites : Site_Array; Geometries : Geometry_Array; Origins : Vector_Array;
      Linear, Angular : Body_Jacobian; Dofs : Natural) return Boolean is
     (Sites'First = 0 and then Sites'Length <= 4096
        and then Geometries'First = 0 and then Geometries'Length <= 4096
        and then Origins'First = 0 and then Origins'Length <= 4096
        and then Dofs <= 4096
        and then Linear'First (1) = Origins'First and then Linear'Last (1) = Origins'Last
        and then Angular'First (1) = Origins'First and then Angular'Last (1) = Origins'Last
        and then Linear'Length (2) <= 4096 and then Angular'Length (2) <= 4096
        and then Linear'First (2) = 0 and then Linear'Length (2) = Dofs
        and then Angular'First (2) = 0 and then Angular'Length (2) = Dofs
        and then (for all S of Sites =>
          Bounded (S.Position, 1.0e10) and then S.Body_Id in Origins'Range)
        and then (for all G of Geometries => G.Body_Id in Origins'Range
          and then Bounded (G.Position, 1.0e10) and then Rotation_Bounded (G.Orientation)
          and then G.Radius in 0.0 .. 1.0e10)
        and then (for all B in Origins'Range => Bounded (Origins (B), 1.0e10)
          and then (for all K in Linear'Range (2) =>
            Bounded (Linear (B, K), 1.0e10) and then Bounded (Angular (B, K), 1.0e10))));

   procedure Evaluate
     (Route : Route_Array; Sites : Site_Array; Geometries : Geometry_Array;
      Origins : Vector_Array; Linear, Angular : Body_Jacobian;
      Status : out Evaluation_Status; Length : out Real; J : out Real_Array;
      Points : out Point_Array; Count : out Natural) with
     Pre => Valid_Path (Route, Sites, Geometries)
       and then J'First = 0 and then J'Length <= 4096
       and then Valid_Kinematics (Sites, Geometries, Origins, Linear, Angular, J'Length)
       and then Points'First = 0 and then Points'Length >= 3 * Route'Length
       and then Points'Length <= 12288,
     Post => Count <= Points'Length
       and then (if Status = Success then Length in 0.0 .. 1.0e100
                   and then (for all K in J'Range => J (K) in -1.0e100 .. 1.0e100)
                 else Length = 0.0 and then Count = 0
                   and then (for all K in J'Range => J (K) = 0.0)
                   and then (for all K in Points'Range =>
                     Points (K) = (Position => Zero, Object_Id => -1)));
   --  Caller owns all storage. No model/state mutation. Failure is atomic:
   --  all outputs reset, never a partially accumulated path or force row.

   function Flat_Column (Flat : Real_Array; Body_Index, Dof, Dofs : Natural)
     return Vector with
     Global => null,
     Pre => Body_Index < 4096 and then Dofs <= 4096 and then Dof < Dofs
       and then Flat'First = 0
       and then Flat'Last >= 3 * (Body_Index * Dofs + Dof) + 2
       and then (for all A in 0 .. 2 =>
         Flat (3 * (Body_Index * Dofs + Dof) + A) in -1.0e10 .. 1.0e10),
     Post => Bounded (Flat_Column'Result, 1.0e10)
       and then Flat_Column'Result =
         (Flat (3 * (Body_Index * Dofs + Dof)),
          Flat (3 * (Body_Index * Dofs + Dof) + 1),
          Flat (3 * (Body_Index * Dofs + Dof) + 2));
   pragma Inline_Always (Flat_Column);

   function Valid_Flat_Kinematics
     (Sites : Site_Array; Geometries : Geometry_Array; Origins : Vector_Array;
      Linear, Angular : Real_Array; Dofs : Natural) return Boolean is
     (Sites'First = 0 and then Sites'Length <= 4096
        and then Geometries'First = 0 and then Geometries'Length <= 4096
        and then Origins'First = 0 and then Origins'Length <= 4096
        and then Dofs <= 4096
        and then Linear'First = 0 and then Angular'First = 0
        and then Int64 (Linear'Length) = 3 * Int64 (Origins'Length) * Int64 (Dofs)
        and then Angular'Length = Linear'Length
        and then (for all S of Sites =>
          Bounded (S.Position, 1.0e10) and then S.Body_Id in Origins'Range)
        and then (for all G of Geometries => G.Body_Id in Origins'Range
          and then Bounded (G.Position, 1.0e10) and then Rotation_Bounded (G.Orientation)
          and then G.Radius in 0.0 .. 1.0e10)
        and then (for all B in Origins'Range => Bounded (Origins (B), 1.0e10))
        and then (for all X of Linear => abs X <= 1.0e10)
        and then (for all X of Angular => abs X <= 1.0e10));

   procedure Evaluate_Flat
     (Route : Route_Array; Sites : Site_Array; Geometries : Geometry_Array;
      Origins : Vector_Array; Linear, Angular : Real_Array;
      Status : out Evaluation_Status; Length : out Real; J : out Real_Array;
      Points : out Point_Array; Count : out Natural) with
     Pre => Valid_Path (Route, Sites, Geometries)
       and then J'First = 0 and then J'Length <= 4096
       and then Valid_Flat_Kinematics (Sites, Geometries, Origins, Linear, Angular, J'Length)
       and then Points'First = 0 and then Points'Length >= 3 * Route'Length
       and then Points'Length <= 12288,
     Post => Count <= Points'Length
       and then (if Status = Success then Length in 0.0 .. 1.0e100
                   and then (for all K in J'Range => J (K) in -1.0e100 .. 1.0e100)
                 else Length = 0.0 and then Count = 0
                   and then (for all K in J'Range => J (K) = 0.0)
                   and then (for all K in Points'Range =>
                     Points (K) = (Position => Zero, Object_Id => -1)));
   --  Same path algorithm and output contract, reading the caller's existing
   --  body-major/component-interleaved buffers without full Jacobian copies.

   function Point_Column (Linear, Angular, Point, Origin : Vector) return Vector with
     Pre => Bounded (Linear, 1.0e10) and then Bounded (Angular, 1.0e10)
       and then Bounded (Point, 1.0e30) and then Bounded (Origin, 1.0e10),
     Post => Point_Column'Result =
       (Linear (1) + (Angular (2) * (Point (3) - Origin (3)) - Angular (3) * (Point (2) - Origin (2))),
        Linear (2) + (Angular (3) * (Point (1) - Origin (1)) - Angular (1) * (Point (3) - Origin (3))),
        Linear (3) + (Angular (1) * (Point (2) - Origin (2)) - Angular (2) * (Point (1) - Origin (1))));

   function Project_Component (Previous, Moment, Force : Real) return Real with
     Pre => Previous in -1.0e100 .. 1.0e100
       and then Moment in -1.0e100 .. 1.0e100 and then Force in -1.0e10 .. 1.0e10,
     Post => Project_Component'Result = Previous + Moment * Force;

   Velocity_Step_Bound : constant Real := 2.0 ** 370;
   function Velocity_Add (Acc, Moment, Rate : Real; Count : Natural) return Real is
     (Acc + Moment * Rate) with Ghost => Static,
     Pre => Count < 4096
       and then abs Acc <= Real (Count) * Velocity_Step_Bound
       and then Moment in -1.0e100 .. 1.0e100
       and then Rate in -1.0e10 .. 1.0e10,
     Post => Velocity_Add'Result = Acc + Moment * Rate
       and then abs Velocity_Add'Result <= Real (Count + 1) * Velocity_Step_Bound;

   function Velocity_Prefix (J, Qvel : Real_Array; Count : Natural) return Real with
     Ghost => Static,
     Pre => J'First = 0 and then Qvel'First = 0 and then J'Length = Qvel'Length
       and then J'Length <= 4096 and then Count <= J'Length
       and then (for all K in J'Range => J (K) in -1.0e100 .. 1.0e100
         and then Qvel (K) in -1.0e10 .. 1.0e10),
     Post => Velocity_Prefix'Result in -Real (Count) * Velocity_Step_Bound .. Real (Count) * Velocity_Step_Bound,
     Subprogram_Variant => (Decreases => Count);
   function Velocity (J, Qvel : Real_Array) return Real with
     Pre => J'First = 0 and then Qvel'First = 0 and then J'Length = Qvel'Length
       and then J'Length <= 4096
       and then (for all K in J'Range => J (K) in -1.0e100 .. 1.0e100
         and then Qvel (K) in -1.0e10 .. 1.0e10),
     Post => (Static => Velocity'Result = Velocity_Prefix (J, Qvel, J'Length));
   procedure Project_Force (J : Real_Array; Force : Real; Qforce : in out Real_Array) with
     Pre => J'First = Qforce'First and then J'Last = Qforce'Last
       and then Force in -1.0e10 .. 1.0e10
       and then (for all K in J'Range => J (K) in -1.0e100 .. 1.0e100
         and then Qforce (K) in -1.0e100 .. 1.0e100),
     Post => (for all K in J'Range =>
       Qforce (K) = Project_Component (Qforce'Old (K), J (K), Force));
   --  Force sign follows MuJoCo: qfrc += J^T * tendon_force (negative pulls).
end MJ.Spatial_Tendons;
