package body MJ.Force_Composition with SPARK_Mode is
   function Smooth_Total (Passive, Full_Bias, Applied, Actuator : Real) return Wide_Sum is
     (((Passive-Full_Bias)+Applied)+Actuator);
   procedure Compose
     (Passive, Full_Bias, Applied, Actuator : Real_Array;
      Total : out Real_Array; Accepted : out Boolean) is
      Value : Wide_Sum;
   begin
      Accepted := False;
      for I in Total'Range loop
         Value := Smooth_Total (Passive (I), Full_Bias (I), Applied (I), Actuator (I));
         if Value not in Component then return; end if;
         Total (I) := Value;
         pragma Loop_Invariant (for all K in 0 .. I => Total (K)'Initialized
           and then Total (K) in Component and then Total (K) =
             Smooth_Total (Passive (K), Full_Bias (K), Applied (K), Actuator (K)));
      end loop;
      Accepted := True;
   end Compose;
end MJ.Force_Composition;
