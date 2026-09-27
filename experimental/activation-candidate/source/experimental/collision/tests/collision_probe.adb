with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Collision; use MJ.Collision;

--  Streaming test I/O; intentionally outside SPARK.
procedure Collision_Probe is
   package Real_IO is new Float_IO (Real);
   package Int_IO is new Integer_IO (Integer);
   Kind : Integer;
   Plane_Position, Center : Position_3;
   Normal, Axis : Direction_3;
   Radius, Half_Length : Nonneg_Tier0;
   Margin : Tier0_Real;
   Result : Contact_Set;
   procedure Put_Real (Value : Real) is
   begin
      Real_IO.Put (Value, Fore => 1, Aft => 17, Exp => 3);
      Put (' ');
   end Put_Real;
begin
   while not End_Of_File loop
      Int_IO.Get (Kind);
      for X of Plane_Position loop Real_IO.Get (X); end loop;
      for X of Normal loop Real_IO.Get (X); end loop;
      for X of Center loop Real_IO.Get (X); end loop;
      for X of Axis loop Real_IO.Get (X); end loop;
      Real_IO.Get (Radius);
      Real_IO.Get (Half_Length);
      Real_IO.Get (Margin);
      Skip_Line;
      if Kind = 0 then
         Result := Plane_Sphere (Plane_Position, Normal, Center, Radius, Margin);
      elsif Kind = 1 then
         Result := Plane_Capsule
           (Plane_Position, Normal, Center, Axis, Radius, Half_Length, Margin);
      else
         raise Program_Error with "unknown primitive";
      end if;
      Int_IO.Put (Result.Count, Width => 1);
      Put (' ');
      for C of Result.Contacts loop
         Put_Real (C.Distance);
         for X of C.Position loop Put_Real (X); end loop;
         for X of C.Normal loop Put_Real (X); end loop;
         for X of C.Tangent loop Put_Real (X); end loop;
      end loop;
      New_Line;
   end loop;
end Collision_Probe;
