with MJ.Gravcomp_Kernels;
package body MJ.Data.Gravity_Compensation with SPARK_Mode is
   procedure Accumulate_Column
     (Total : in out Real_Array; Index : Natural; Linear, Force : Vector; Result : out Status)
   is
      Value : constant Real := Total (Index) + MJ.Smooth_Dynamics.Dot_Motion (Linear, Force);
   begin
      if not Within_Work (Value) then Result := Numeric_Limit; return; end if;
      Total (Index) := Value;
      Result := Success;
   end Accumulate_Column;

   procedure Add_Compensation (Total : in out Real_Array; Compensation : Real_Array;
                               Result : out Status)
   is
   begin
      Result := Numeric_Limit;
      for I in Total'Range loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Total));
         pragma Loop_Invariant (for all K in 0 .. I - 1 =>
           Total (K) = Total'Loop_Entry (K) + Compensation (K));
         pragma Loop_Invariant (for all K in I .. Total'Last => Total (K) = Total'Loop_Entry (K));
         declare
            Value : constant Real := Total (I) + Compensation (I);
         begin
            if not Within_Work (Value) then return; end if;
            Total (I) := Value;
         end;
      end loop;
      Result := Success;
   end Add_Compensation;

   procedure Apply_Buffers
     (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Body_Poses : Body_State_Array; Joint_Poses : Joint_State_Array;
      Gravity : Vector;
      Total : in out Real_Array; Result : out Status)
   is
      Compensation : Real_Array (Total'Range) := [others => 0.0];
   begin
      Result := Success;
      --  C outer body order, skipping the world and zero coefficients.
      for B in 1 .. Bodies'Last loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Compensation));
         if Bodies (B).Gravcomp /= 0.0 then
            declare
               Ancestor : Natural := B;
               Force : constant Vector := MJ.Gravcomp_Kernels.Body_Force (Bodies (B).Mass, Bodies (B).Gravcomp, Gravity);
            begin
               while Ancestor > 0 loop
                  pragma Loop_Variant (Decreases => Ancestor);
                  pragma Loop_Invariant (Ancestor in 1 .. B);
                  pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Compensation));
                  declare
                     C : constant Body_Parameters := Bodies (Ancestor);
                  begin
                     for Offset in 0 .. C.Joint_Count - 1 loop
                        pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Compensation));
                        declare
                           J : constant Natural := C.First_Joint + Offset;
                           Linear : constant Vector := MJ.Gravcomp_Kernels.Linear_Column
                             (Joints (J).Kind = Hinge_Joint, Body_Poses (B).Center,
                              Joint_Poses (J).Anchor, Joint_Poses (J).Direction);
                        begin
                           Accumulate_Column (Compensation, Joints (J).Vadr, Linear, Force, Result);
                           if Result /= Success then return; end if;
                        end;
                     end loop;
                     Ancestor := C.Parent;
                  end;
               end loop;
            end;
         end if;
      end loop;
      --  As in C, finish qfrc_gravcomp before adding it to qfrc_passive.
      Add_Compensation (Total, Compensation, Result);
   end Apply_Buffers;
end MJ.Data.Gravity_Compensation;
