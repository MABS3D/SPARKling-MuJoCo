with MJ.Bounds_Kernels;
package body MJ.Data.Controller_Forces with SPARK_Mode is
   procedure Prove_Array_Bounded (D : Simulation; Limit : Real)
     with Ghost => Static,
       Pre => D.Dynamics.Actuator /= null and then Limit >= 0.0
         and then (for all X of D.Dynamics.Actuator.all => X in -Limit .. Limit),
       Post => Array_Bounded (D.Dynamics.Actuator, Limit)
   is
   begin
      if D.Dynamics.Actuator'Length = 1 then
         pragma Assert (D.Dynamics.Actuator (D.Dynamics.Actuator'First) in -Limit .. Limit);
      else
         pragma Assert (MJ.Bounds_Kernels.All_Within (D.Dynamics.Actuator.all, Limit));
      end if;
   end Prove_Array_Bounded;
   procedure Publish
     (D : in out Simulation; Values : Real_Array; Result : out Status)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Array_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_Qpos : constant Real_Array := D.State.Qpos.all with Ghost => Static;
      Initial_Qvel : constant Real_Array := D.State.Qvel.all with Ghost => Static;
      Initial_Control : constant Real_Array := D.State.Ctrl.all with Ghost => Static;
      Initial_Applied : constant Real_Array := D.State.Applied.all with Ghost => Static;
      Initial_Clock : constant Nonneg_Tier0 := D.Clock with Ghost => Static;
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
   begin
      pragma Assert (Static => Storage_Ready (D));
      pragma Assert (Static => Stable_Ready (D));
      Result := Invalid_Size;
      if Int64 (Values'Length) /= Int64 (D.Nv) then return; end if;
      Result := Numeric_Limit;
      if (for some X of Values => X not in -1.0e50 .. 1.0e50)
        or else not Array_Bounded (D.Actuators.Length, 1.0e20)
        or else not Array_Bounded (D.Actuators.Velocity, 1.0e20)
        or else not Array_Bounded (D.Actuators.Force, 4.0e30)
      then return; end if;
      D.Dynamics.Actuator.all := Values;
      pragma Assert (Static => D.Dynamics.Actuator.all = Values);
      pragma Assert (Static => (for all X of D.Dynamics.Actuator.all => X in -1.0e50 .. 1.0e50));
      Prove_Array_Bounded (D, 1.0e50);
      D.Cache.Force_Valid := False;
      D.Cache.Actuation_Valid := True;
      pragma Assert (Static => Storage_Ready (D));
      pragma Assert (Static => Stable_Ready (D));
      pragma Assert (Static => Caches_Bounded (D));
      Equal_State_Images (D.State.Qpos.all, Initial_Qpos, D.State.Qvel.all, Initial_Qvel,
                          D.Clock, Initial_Clock);
      Equal_Input_Images (D.State.Ctrl.all, Initial_Control, D.State.Applied.all, Initial_Applied);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      Result := Success;
   end Publish;
end MJ.Data.Controller_Forces;
