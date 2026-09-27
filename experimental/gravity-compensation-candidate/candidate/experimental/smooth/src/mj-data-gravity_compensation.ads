with MJ.Smooth_Dynamics;
with MJ.Data.Jacobians;

private package MJ.Data.Gravity_Compensation with SPARK_Mode is
   procedure Accumulate_Column
     (Total : in out Real_Array; Index : Natural; Linear, Force : Vector; Result : out Status)
     with Global => null,
     Pre => Index in Total'Range and then MJ.Smooth_Dynamics.Work_Array (Total)
       and then Bounded (Linear, 1.0e62) and then Bounded (Force),
     Post => MJ.Smooth_Dynamics.Work_Array (Total)
       and then Result in Success | Numeric_Limit
       and then (if Result = Success then
         (for all K in Total'Range => Total (K) =
           (if K = Index then Total'Old (K) + MJ.Smooth_Dynamics.Dot_Motion (Linear, Force)
            else Total'Old (K)))
         else Total = Total'Old);
   pragma Inline_Always (Accumulate_Column);
   procedure Add_Compensation (Total : in out Real_Array; Compensation : Real_Array;
                               Result : out Status)
     with Global => null, Inline_Always,
     Pre => Total'First = 0 and then Total'Length <= Max_Dofs
       and then Compensation'First = 0 and then Compensation'Last = Total'Last
       and then MJ.Smooth_Dynamics.Work_Array (Total)
       and then MJ.Smooth_Dynamics.Work_Array (Compensation),
     Post => MJ.Smooth_Dynamics.Work_Array (Total) and then Result in Success | Numeric_Limit
       and then (if Result = Success then
         (for all I in Total'Range => Total (I) = Total'Old (I) + Compensation (I)));

   procedure Apply_Buffers
     (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Body_Poses : Body_State_Array; Joint_Poses : Joint_State_Array;
      Gravity : Vector;
      Total : in out Real_Array; Result : out Status)
     with Global => null,
     Pre => Bodies'First = 0 and then Bodies'Length in 1 .. Max_Bodies
       and then Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then MJ.Data.Jacobians.Topology (Bodies, Joints)
       and then Body_Poses'First = 0 and then Body_Poses'Last = Bodies'Last
       and then Joint_Poses'First = 0 and then Joint_Poses'Last = Joints'Last
       and then (for all B of Body_Poses => Bounded (B.Center))
       and then (for all J of Joint_Poses => Joint_Bounded (J))
       and then Total'First = 0 and then Total'Last = Joints'Last
       and then MJ.Smooth_Dynamics.Work_Array (Total)
       and then Bounded (Gravity, Max_Val),
     Post => MJ.Smooth_Dynamics.Work_Array (Total);
   pragma Postcondition (Result in Success | Numeric_Limit);
end MJ.Data.Gravity_Compensation;
