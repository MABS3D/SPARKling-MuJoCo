package body MJ.External_Forces with SPARK_Mode is
   function Dot_Load (Column : Vector; Load : Input_Vector) return Projection_Real is
     ((Column (0) * Load (0) + Column (1) * Load (1)) + Column (2) * Load (2));
   function Contribution
     (Previous : Real;
      Linear, Angular : Vector; Load : Wrench) return Real
   is
      F0 : constant Real := Linear (0) * Load.Force (0);
      F1 : constant Real := Linear (1) * Load.Force (1);
      F2 : constant Real := Linear (2) * Load.Force (2);
      T0 : constant Real := Angular (0) * Load.Torque (0);
      T1 : constant Real := Angular (1) * Load.Torque (1);
      T2 : constant Real := Angular (2) * Load.Torque (2);
   begin
      pragma Assert (Static => F0 in -2.0e70 .. 2.0e70);
      pragma Assert (Static => F1 in -2.0e70 .. 2.0e70);
      pragma Assert (Static => F2 in -2.0e70 .. 2.0e70);
      pragma Assert (Static => T0 in -2.0e70 .. 2.0e70);
      pragma Assert (Static => T1 in -2.0e70 .. 2.0e70);
      pragma Assert (Static => T2 in -2.0e70 .. 2.0e70);
      declare
         Force_Value : constant Real := (F0 + F1) + F2;
         Torque_Value : constant Real := (T0 + T1) + T2;
      begin
         pragma Assert (Static => Force_Value in Projection_Real);
         pragma Assert (Static => Torque_Value in Projection_Real);
         pragma Assert (Static => Force_Value = Dot_Load (Linear, Load.Force));
         pragma Assert (Static => Torque_Value = Dot_Load (Angular, Load.Torque));
         return (Previous + Force_Value) + Torque_Value;
      end;
   end Contribution;
end MJ.External_Forces;
