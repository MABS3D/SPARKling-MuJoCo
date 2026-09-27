package body MJ.Data.External_Loads with SPARK_Mode is
   procedure Accumulate_Column
     (Total : in out Real_Array; Index : Natural; Linear, Angular : Vector;
      Load : MJ.External_Forces.Wrench; Result : out Status)
   is
      Value : constant Real := MJ.External_Forces.Contribution
        (Total (Index), Linear, Angular, Load);
   begin
      if not Within_Work (Value) then Result := Numeric_Limit; return; end if;
      Total (Index) := Value;
      Result := Success;
   end Accumulate_Column;

   procedure Apply_Buffers
     (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Body_Poses : Body_State_Array; Joint_Poses : Joint_State_Array;
      External : MJ.External_Forces.Wrench_Array;
      Total : in out Real_Array; Result : out Status)
   is
   begin
      Result := Success;
      if External'Length = 0 then return; end if;
      if External'First /= 0 or else External'Length /= Bodies'Length then
         Result := Invalid_Size;
         return;
      end if;
      --  Same outer body order as mj_xfrcAccumulate. Body zero is the world.
      for B in 1 .. Bodies'Last loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Total));
         if not MJ.External_Forces.Is_Zero (External (B)) then
            declare
               Ancestor : Natural := B;
            begin
               while Ancestor > 0 loop
                  pragma Loop_Variant (Decreases => Ancestor);
                  pragma Loop_Invariant (Ancestor in 1 .. B);
                  pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Total));
                  declare
                     C : constant Body_Parameters := Bodies (Ancestor);
                  begin
                     for Offset in 0 .. C.Joint_Count - 1 loop
                        pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Total));
                        declare
                           J : constant Natural := C.First_Joint + Offset;
                           Linear, Angular : Vector;
                           Ok : Boolean;
                        begin
                           MJ.Data.Jacobians.Column
                             (Joints (J).Kind = Hinge_Joint, Body_Poses (B).Center,
                              Joint_Poses (J).Anchor, Joint_Poses (J).Direction,
                              Linear, Angular, Ok);
                           if not Ok then Result := Numeric_Limit; return; end if;
                           Accumulate_Column (Total, Joints (J).Vadr, Linear, Angular,
                                              External (B), Result);
                           if Result /= Success then return; end if;
                        end;
                     end loop;
                     Ancestor := C.Parent;
                  end;
               end loop;
            end;
         end if;
      end loop;
      Result := Success;
   end Apply_Buffers;
end MJ.Data.External_Loads;
