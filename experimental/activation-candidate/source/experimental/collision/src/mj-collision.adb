--  Adapted from MuJoCo engine_collision_primitive.c.
--  Copyright 2021 DeepMind Technologies Limited
--  SPDX-License-Identifier: Apache-2.0
package body MJ.Collision with SPARK_Mode is
   function Projected_Distance
     (Plane_Position, Center : Position_3; Normal : Direction_3)
      return Projection
   is
   begin
      return (((Center (0) - Plane_Position (0)) * Normal (0)
             + (Center (1) - Plane_Position (1)) * Normal (1))
             + (Center (2) - Plane_Position (2)) * Normal (2));
   end Projected_Distance;

   --  Keep contact packing independent of the floating-point geometry facts.
   function Pack_Contacts
     (First, Second : Contact_Set; Normal, Axis : Direction_3) return Contact_Set
   with Global => null,
     Pre => First.Count <= 1 and then Second.Count <= 1
       and then (if First.Count = 1 then First.Contacts (0).Normal = Normal)
       and then (if Second.Count = 1 then Second.Contacts (0).Normal = Normal),
     Post => Pack_Contacts'Result.Count = First.Count + Second.Count
       and then (for all I in 0 .. 1 =>
         (if I < Pack_Contacts'Result.Count then
            Pack_Contacts'Result.Contacts (I).Normal = Normal
            and then Pack_Contacts'Result.Contacts (I).Tangent = Axis
          else Pack_Contacts'Result.Contacts (I) = Empty_Contact))
       and then (if First.Count = 1 then
         Pack_Contacts'Result.Contacts (0).Position = First.Contacts (0).Position
         and then Pack_Contacts'Result.Contacts (0).Distance = First.Contacts (0).Distance)
       and then (if Second.Count = 1 then
         Pack_Contacts'Result.Contacts (First.Count).Position = Second.Contacts (0).Position
         and then Pack_Contacts'Result.Contacts (First.Count).Distance = Second.Contacts (0).Distance)
       and then Pack_Contacts'Result = Packed_Model (First, Second, Axis)
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Packed_Model);
      Contact_1 : Pre_Contact := First.Contacts (0);
      Contact_2 : Pre_Contact := Second.Contacts (0);
   begin
      Contact_1.Tangent := Axis;
      Contact_2.Tangent := Axis;
      if First.Count = 1 then
         if Second.Count = 1 then
            return (Count => 2, Contacts => [Contact_1, Contact_2]);
         else
            return (Count => 1, Contacts => [Contact_1, Empty_Contact]);
         end if;
      elsif Second.Count = 1 then
         return (Count => 1, Contacts => [Contact_2, Empty_Contact]);
      else
         return (Count => 0, Contacts => [others => Empty_Contact]);
      end if;
   end Pack_Contacts;

   function Plane_Sphere
     (Plane_Position : Position_3; Normal : Direction_3;
      Center : Position_3; Radius : Nonneg_Tier0; Margin : Tier0_Real)
      return Contact_Set
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Unit);
      subtype Contact_Work is Real range -1.0e12 .. 1.0e12;
      Result : Contact_Set;
      Cdist  : constant Projection := Projected_Distance (Plane_Position, Center, Normal);
      Depth  : constant Contact_Work := Cdist - Radius;
      Scale  : constant Contact_Work := -Depth / 2.0 - Radius;
   begin
      if Cdist > Margin + Radius then
         return Result;
      end if;
      Result.Count := 1;
      Result.Contacts (0) :=
        (Distance => Depth,
         Position => [Center (0) + Normal (0) * Scale,
                      Center (1) + Normal (1) * Scale,
                      Center (2) + Normal (2) * Scale],
         Normal => Normal, Tangent => [others => 0.0]);
      return Result;
   end Plane_Sphere;

   function Endpoint
     (Center : Tier0_Real; Axis : Direction_Component;
      Half_Length : Nonneg_Tier0; Positive : Boolean) return Position_Component
   with Global => null,
     Post => Endpoint'Result =
       (if Positive then Center + Half_Length * Axis else Center - Half_Length * Axis)
   is
   begin
      if Positive then
         return Center + Half_Length * Axis;
      else
         return Center - Half_Length * Axis;
      end if;
   end Endpoint;

   function Capsule_End
     (Center : Position_3; Axis : Direction_3;
      Half_Length : Nonneg_Tier0; Positive : Boolean) return Position_3
   is
   begin
      return [Endpoint (Center (0), Axis (0), Half_Length, Positive),
              Endpoint (Center (1), Axis (1), Half_Length, Positive),
              Endpoint (Center (2), Axis (2), Half_Length, Positive)];
   end Capsule_End;

   function Plane_Capsule
     (Plane_Position : Position_3; Normal : Direction_3;
      Center : Position_3; Axis : Direction_3;
      Radius, Half_Length : Nonneg_Tier0; Margin : Tier0_Real)
      return Contact_Set
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Unit);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Capsule_Model);
      Plus_End : constant Position_3 :=
        Capsule_End (Center, Axis, Half_Length, True);
      Minus_End : constant Position_3 :=
        Capsule_End (Center, Axis, Half_Length, False);
      First : constant Contact_Set :=
        Plane_Sphere (Plane_Position, Normal, Plus_End, Radius, Margin);
      Second : constant Contact_Set :=
        Plane_Sphere (Plane_Position, Normal, Minus_End, Radius, Margin);
   begin
      pragma Assert_And_Cut
        (First.Count <= 1 and then Second.Count <= 1
         and then (if First.Count = 1 then First.Contacts (0).Normal = Normal)
         and then (if Second.Count = 1 then Second.Contacts (0).Normal = Normal)
         and then Is_Unit (Normal) and then Is_Unit (Axis) and then In_Tier0 (Center)
         and then Packed_Model (First, Second, Axis) =
           Capsule_Model (Plane_Position, Normal, Center, Axis, Radius, Half_Length, Margin));
      return Pack_Contacts (First, Second, Normal, Axis);
   end Plane_Capsule;
end MJ.Collision;
