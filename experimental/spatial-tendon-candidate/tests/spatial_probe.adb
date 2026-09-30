with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Tendon_Vectors; use MJ.Tendon_Vectors;
with MJ.Tendon_Geometry;
with MJ.Spatial_Tendons; use MJ.Spatial_Tendons;

procedure Spatial_Probe is
   package FIO is new Ada.Text_IO.Float_IO (Real);
   function Read_Int return Integer is
      V : Integer;
   begin
      Ada.Integer_Text_IO.Get (V);
      return V;
   end Read_Int;
   function Read_Real return Real is
      V : Real;
   begin
      FIO.Get (V);
      return V;
   end Read_Real;
   function Read_Vector return Vector is
      V : Vector;
   begin
      for I in V'Range loop
         V (I) := Read_Real;
      end loop;
      return V;
   end Read_Vector;
   function Read_Matrix return Matrix is
      M : Matrix;
   begin
      for I in 1 .. 3 loop
         for J in 1 .. 3 loop
            M (I, J) := Read_Real;
         end loop;
      end loop;
      return M;
   end Read_Matrix;
   procedure Put_Real (X : Real) is
   begin
      Put (" ");
      FIO.Put (X, Fore => 1, Aft => 17, Exp => 3);
   end Put_Real;
   procedure Put_Vector (V : Vector) is
   begin
      for X of V loop
         Put_Real (X);
      end loop;
   end Put_Vector;
   Command : Character;
begin
   while not End_Of_File loop
      Get (Command);
      case Command is
         when 'W' =>
            declare
               use MJ.Tendon_Geometry;
               Kind : constant Geometry_Kind := Geometry_Kind'Val (Read_Int);
               Radius : constant Real := Read_Real;
               Has_Side : constant Boolean := Read_Int /= 0;
               A : constant Vector := Read_Vector;
               B : constant Vector := Read_Vector;
               Center : constant Vector := Read_Vector;
               Rotation : constant Matrix := Read_Matrix;
               Side : constant Vector := Read_Vector;
               W : constant Wrap_Result := Wrap (A, B, Center, Rotation, Radius, Kind, Has_Side, Side);
            begin
               Put (Integer'Image (Wrap_Status'Pos (W.Status)));
               Put_Real (W.Arc_Length);
               Put_Vector (W.First);
               Put_Vector (W.Last);
               New_Line;
            end;
         when 'P' =>
            declare
               NS : constant Natural := Read_Int;
               NG : constant Natural := Read_Int;
               NB : constant Natural := Read_Int;
               NV : constant Natural := Read_Int;
               NR : constant Natural := Read_Int;
               Sites : Site_Array (0 .. NS - 1);
               Geoms : Geometry_Array (0 .. NG - 1);
               Origins : Vector_Array (0 .. NB - 1);
               Linear, Angular : Body_Jacobian (0 .. NB - 1, 0 .. NV - 1);
               Route : Route_Array (0 .. NR - 1);
               Points : Point_Array (0 .. 3 * NR - 1);
               J, Vel, Force_Row : Real_Array (0 .. NV - 1) := (others => 0.0);
               State : Evaluation_Status;
               Length, Force : Real;
               Count : Natural;
            begin
               for S of Sites loop
                  S.Body_Id := Read_Int;
                  S.Position := Read_Vector;
               end loop;
               for G of Geoms loop
                  G.Body_Id := Read_Int;
                  G.Kind := MJ.Tendon_Geometry.Geometry_Kind'Val (Read_Int);
                  G.Radius := Read_Real;
                  G.Position := Read_Vector;
                  G.Orientation := Read_Matrix;
               end loop;
               for B in Origins'Range loop
                  Origins (B) := Read_Vector;
                  for K in J'Range loop
                     Linear (B, K) := Read_Vector;
                     Angular (B, K) := Read_Vector;
                  end loop;
               end loop;
               for N of Route loop
                  N.Kind := Node_Kind'Val (Read_Int);
                  N.Object_Id := Read_Int;
                  N.Side_Id := Read_Int;
                  N.Divisor := Read_Real;
               end loop;
               for V of Vel loop
                  V := Read_Real;
               end loop;
               Force := Read_Real;
               for V of Force_Row loop
                  V := Read_Real;
               end loop;
               if not Valid_Path (Route, Sites, Geoms) or else
                 not Valid_Kinematics (Sites, Geoms, Origins, Linear, Angular, J'Length)
               then
                  Put_Line ("invalid");
               else
                  Evaluate (Route, Sites, Geoms, Origins, Linear, Angular, State,
                            Length, J, Points, Count);
                  Put (Integer'Image (Evaluation_Status'Pos (State)));
                  Put_Real (Length);
                  Put (Integer'Image (Count));
                  for X of J loop
                     Put_Real (X);
                  end loop;
                  Put_Real (Velocity (J, Vel));
                  Project_Force (J, Force, Force_Row);
                  for X of Force_Row loop
                     Put_Real (X);
                  end loop;
                  for K in 0 .. Count - 1 loop
                     Put (" " & Integer'Image (Points (K).Object_Id));
                     Put_Vector (Points (K).Position);
                  end loop;
                  New_Line;
               end if;
            end;
         when others => null;
      end case;
   end loop;
end Spatial_Probe;
