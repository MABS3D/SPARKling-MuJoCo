with MJ.Types; use MJ.Types;

--  Narrowphase primitives from MuJoCo 3.12.0 engine_collision_primitive.c.
--  Positions and directions are in world coordinates; the normal points
--  out of the plane, toward its positive half-space. No frame completion or
--  constraint construction occurs here.
package MJ.Collision with SPARK_Mode is
   subtype Position_Component is Real range -2.0e10 .. 2.0e10;
   type Position_3 is array (0 .. 2) of Position_Component;
   subtype Direction_Component is Real range -1.0 .. 1.0;
   type Direction_3 is array (0 .. 2) of Direction_Component;
   type Contact_Position_3 is array (0 .. 2) of Tier1_Real;

   function Is_Unit (V : Direction_3) return Boolean is
     (((V (0) * V (0) + V (1) * V (1)) + V (2) * V (2))
        in 1.0 - 1.0e-12 .. 1.0 + 1.0e-12)
   with Global => null;

   function In_Tier0 (V : Position_3) return Boolean is
     (for all X of V => X in Tier0_Real)
   with Global => null;

   type Pre_Contact is record
      Distance : Tier1_Real := 0.0;
      Position : Contact_Position_3 := [others => 0.0];
      Normal   : Direction_3 := [others => 0.0];
      Tangent  : Direction_3 := [others => 0.0];
   end record;
   Empty_Contact : constant Pre_Contact := (others => <>);

   type Contact_Pair is array (0 .. 1) of Pre_Contact;
   type Contact_Set is record
      Count    : Natural range 0 .. 2 := 0;
      Contacts : Contact_Pair := [others => Empty_Contact];
   end record;

   --  A deliberately bounded result exposes the arithmetic bound to callers.
   subtype Projection is Real range -2.0e11 .. 2.0e11;
   function Projected_Distance
     (Plane_Position, Center : Position_3; Normal : Direction_3)
      return Projection
   with Global => null,
     Post => Projected_Distance'Result =
       (((Center (0) - Plane_Position (0)) * Normal (0)
       + (Center (1) - Plane_Position (1)) * Normal (1))
       + (Center (2) - Plane_Position (2)) * Normal (2));

   --  Preserve the C test cdist > margin + radius (including equality).
   --  Margin can be negative. Radius zero is supported by this raw kernel.
   function Plane_Sphere
     (Plane_Position : Position_3; Normal : Direction_3;
      Center : Position_3; Radius : Nonneg_Tier0; Margin : Tier0_Real)
      return Contact_Set
   with Global => null,
     Pre => Is_Unit (Normal),
     Post =>
       Plane_Sphere'Result.Count =
         (if Projected_Distance (Plane_Position, Center, Normal) > Margin + Radius
          then 0 else 1)
       and then Plane_Sphere'Result.Contacts (1) = Empty_Contact
       and then
         (if Plane_Sphere'Result.Count = 0 then
            Plane_Sphere'Result.Contacts (0) = Empty_Contact
          else
            Plane_Sphere'Result.Contacts (0).Distance =
              Projected_Distance (Plane_Position, Center, Normal) - Radius
            and then Plane_Sphere'Result.Contacts (0).Normal = Normal
            and then Plane_Sphere'Result.Contacts (0).Tangent = Direction_3'[others => 0.0]
            and then (for all I in 0 .. 2 =>
              Plane_Sphere'Result.Contacts (0).Position (I) = Center (I)
                + Normal (I) *
                  (-Plane_Sphere'Result.Contacts (0).Distance / 2.0 - Radius)));

   function Capsule_End
     (Center : Position_3; Axis : Direction_3;
      Half_Length : Nonneg_Tier0; Positive : Boolean) return Position_3
   with Global => null,
     Pre => In_Tier0 (Center),
     Post => (for all I in 0 .. 2 => Capsule_End'Result (I) =
       (if Positive then Center (I) + Half_Length * Axis (I)
        else Center (I) - Half_Length * Axis (I)));

   --  A ghost sequence specification: keep each accepted contact in endpoint
   --  order and replace only its tangent. This does not call Pack_Contacts.
   function Packed_Model
     (First, Second : Contact_Set; Axis : Direction_3) return Contact_Set is
     (declare
        A : constant Pre_Contact :=
          (First.Contacts (0).Distance, First.Contacts (0).Position,
           First.Contacts (0).Normal, Axis);
        B : constant Pre_Contact :=
          (Second.Contacts (0).Distance, Second.Contacts (0).Position,
           Second.Contacts (0).Normal, Axis);
      begin
        (if First.Count = 1 then
           (if Second.Count = 1 then (2, [A, B]) else (1, [A, Empty_Contact]))
         elsif Second.Count = 1 then (1, [B, Empty_Contact])
         else (0, [others => Empty_Contact])))
   with Ghost, Global => null,
     Pre => First.Count <= 1 and then Second.Count <= 1,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   --  Composition of the proved sphere specification at the two exact
   --  floating-point endpoints; independent of the capsule implementation.
   function Capsule_Model
     (Plane_Position : Position_3; Normal : Direction_3;
      Center : Position_3; Axis : Direction_3;
      Radius, Half_Length : Nonneg_Tier0; Margin : Tier0_Real) return Contact_Set is
     (Packed_Model
        (Plane_Sphere (Plane_Position, Normal,
           Capsule_End (Center, Axis, Half_Length, True), Radius, Margin),
         Plane_Sphere (Plane_Position, Normal,
           Capsule_End (Center, Axis, Half_Length, False), Radius, Margin), Axis))
   with Ghost, Global => null,
     Pre => Is_Unit (Normal) and then Is_Unit (Axis) and then In_Tier0 (Center),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   --  Capsule endpoints are tested in +axis, -axis order, as in C. The
   --  tangent hint remains the axis, even when parallel to the plane normal.
   --  Duplicated contacts for zero half-length are retained, as in C.
   function Plane_Capsule
     (Plane_Position : Position_3; Normal : Direction_3;
      Center : Position_3; Axis : Direction_3;
      Radius, Half_Length : Nonneg_Tier0; Margin : Tier0_Real)
      return Contact_Set
   with Global => null,
     Pre => Is_Unit (Normal) and then Is_Unit (Axis) and then In_Tier0 (Center),
     Post =>
       (for all I in 0 .. 1 =>
         (if I < Plane_Capsule'Result.Count then
            Plane_Capsule'Result.Contacts (I).Normal = Normal
            and then Plane_Capsule'Result.Contacts (I).Tangent = Axis
          else Plane_Capsule'Result.Contacts (I) = Empty_Contact))
       and then Plane_Capsule'Result =
         Capsule_Model (Plane_Position, Normal, Center, Axis, Radius, Half_Length, Margin);
end MJ.Collision;
