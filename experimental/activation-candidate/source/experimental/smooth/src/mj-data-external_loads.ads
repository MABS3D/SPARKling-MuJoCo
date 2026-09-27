with MJ.External_Forces;
with MJ.Smooth_Dynamics;
with MJ.Data.Jacobians;

private package MJ.Data.External_Loads with SPARK_Mode is
   procedure Accumulate_Column
     (Total : in out Real_Array; Index : Natural; Linear, Angular : Vector;
      Load : MJ.External_Forces.Wrench; Result : out Status)
     with Global => null,
     Pre => Index in Total'Range and then MJ.Smooth_Dynamics.Work_Array (Total)
       and then Bounded (Linear) and then Bounded (Angular),
     Post => MJ.Smooth_Dynamics.Work_Array (Total)
       and then Result in Success | Numeric_Limit
       and then (if Result = Success then
         (for all K in Total'Range => Total (K) =
           (if K = Index then MJ.External_Forces.Contribution (Total'Old (K), Linear, Angular, Load)
            else Total'Old (K)))
         else Total = Total'Old);
   pragma Inline_Always (Accumulate_Column);
   procedure Apply_Buffers
     (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Body_Poses : Body_State_Array; Joint_Poses : Joint_State_Array;
      External : MJ.External_Forces.Wrench_Array;
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
       and then MJ.Smooth_Dynamics.Work_Array (Total),
     Post => MJ.Smooth_Dynamics.Work_Array (Total);
   pragma Postcondition (Result in Success | Invalid_Size | Numeric_Limit);
   pragma Postcondition (if External'Length = 0 then Result = Success and then Total = Total'Old);
   pragma Postcondition (if Result = Invalid_Size then Total = Total'Old);
end MJ.Data.External_Loads;
