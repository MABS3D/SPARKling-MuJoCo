package body MJ.Data.Fluid_Tree with SPARK_Mode is
   procedure Project_Into
     (Passive : in out Real_Array; Index : Natural; Hinge : Boolean;
      Direction, Offset, Force, Torque : Vector; Result : out Status) is
      Value : constant Real := Passive (Index) + MJ.Fluid_Transport.Project (Hinge, Direction, Offset, Force, Torque);
   begin
      Result := Numeric_Limit;
      if not Within_Work (Value) then return; end if;
      Passive (Index) := Value;
      Result := Success;
   end Project_Into;
   procedure Fold
     (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Body_Poses : Body_State_Array; Joint_Poses : Joint_State_Array;
      Forces, Torques : in out MJ.Fluid_Kernels.Vector_Array;
      Passive : in out Real_Array; Result : out Status) is
      Ok : Boolean;
   begin
      for B in reverse 1 .. Bodies'Last loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Passive));
         pragma Loop_Invariant (for all F of Forces => Bounded (F));
         pragma Loop_Invariant (for all T of Torques => Bounded (T));
         pragma Loop_Invariant (Forces (0) = Forces'Loop_Entry (0) and then Torques (0) = Torques'Loop_Entry (0));
         declare
            C : constant Body_Parameters := Bodies (B);
         begin
            for K in 0 .. C.Joint_Count - 1 loop
               pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Passive));
               declare
                  J : constant Natural := C.First_Joint + K;
               begin
                  Project_Into (Passive, Joints (J).Vadr, Joints (J).Kind = Hinge_Joint,
                    Joint_Poses (J).Direction, Body_Poses (B).Position - Joint_Poses (J).Anchor,
                    Forces (B), Torques (B), Result);
                  if Result /= Success then return; end if;
               end;
            end loop;
            if C.Parent > 0 then
               declare
                  Child_Force : constant Vector := Forces (B);
                  Child_Torque : constant Vector := Torques (B);
                  Offset : constant Vector := Body_Poses (B).Position - Body_Poses (C.Parent).Position;
               begin
                  pragma Assert (Static => Bounded (Forces (C.Parent)));
                  pragma Assert (Static => Bounded (Torques (C.Parent)));
                  pragma Assert (Static => Bounded (Child_Force) and then Bounded (Child_Torque));
                  pragma Assert (Static => Bounded (Offset, 1.0e66));
                  MJ.Fluid_Transport.Merge (Forces (C.Parent), Torques (C.Parent), Child_Force, Child_Torque,
                    Offset, Ok);
               end;
               if not Ok then Result := Numeric_Limit; return; end if;
            end if;
         end;
      end loop;
      Result := Success;
   end Fold;
end MJ.Data.Fluid_Tree;
