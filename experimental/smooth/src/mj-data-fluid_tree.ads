with MJ.Data.Jacobians;
with MJ.Smooth_Dynamics;
with MJ.Fluid_Transport;
private package MJ.Data.Fluid_Tree with SPARK_Mode is
   procedure Project_Into
     (Passive : in out Real_Array; Index : Natural; Hinge : Boolean;
      Direction, Offset, Force, Torque : Vector; Result : out Status) with
     Global => null, Pre => Index in Passive'Range and then MJ.Smooth_Dynamics.Work_Array (Passive)
       and then Bounded (Direction, 2.0) and then Bounded (Offset, 1.0e66)
       and then Bounded (Force) and then Bounded (Torque),
     Post => MJ.Smooth_Dynamics.Work_Array (Passive)
       and then Result in Success | Numeric_Limit
       and then (if Result = Success then
         (for all K in Passive'Range => Passive (K) =
           (if K = Index then Passive'Old (K) + MJ.Fluid_Transport.Project (Hinge, Direction, Offset, Force, Torque)
            else Passive'Old (K))) else Passive = Passive'Old);
   pragma Inline_Always (Project_Into);
   procedure Fold
     (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Body_Poses : Body_State_Array; Joint_Poses : Joint_State_Array;
      Forces, Torques : in out MJ.Fluid_Kernels.Vector_Array;
      Passive : in out Real_Array; Result : out Status) with
     Global => null,
     Pre => Bodies'First = 0 and then Bodies'Length in 1 .. Max_Bodies
       and then Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then MJ.Data.Jacobians.Topology (Bodies, Joints)
       and then Body_Poses'First = 0 and then Body_Poses'Last = Bodies'Last
       and then Joint_Poses'First = 0 and then Joint_Poses'Last = Joints'Last
       and then (for all B of Body_Poses => Bounded (B.Position))
       and then (for all J of Joint_Poses => Joint_Bounded (J))
       and then Forces'First = 0 and then Forces'Last = Bodies'Last
       and then Torques'First = 0 and then Torques'Last = Bodies'Last
       and then (for all F of Forces => Bounded (F)) and then (for all T of Torques => Bounded (T))
       and then Passive'First = 0 and then Passive'Last = Joints'Last
       and then MJ.Smooth_Dynamics.Work_Array (Passive),
     Post => MJ.Smooth_Dynamics.Work_Array (Passive)
       and then Result in Success | Numeric_Limit
       and then (for all F of Forces => Bounded (F)) and then (for all T of Torques => Bounded (T))
       and then Forces (0) = Forces'Old (0) and then Torques (0) = Torques'Old (0);
end MJ.Data.Fluid_Tree;
