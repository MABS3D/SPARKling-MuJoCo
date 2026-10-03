with MJ.Data.Pipeline;
with MJ.Data.Inertia_Phase;
with MJ.Data.Forces_Phase;
package body MJ.Data.Controller_Dynamics with SPARK_Mode is
   procedure Invalidate_Actuation (D : in out Simulation)
     with Pre => (Static => Is_Ready (D));
   pragma Postcondition (Static => Is_Ready (D));
   pragma Postcondition (Static => Shape (D) = Shape (D)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   procedure Ensure_Poses (D : in out Simulation; Has_Sites : Boolean; Result : out Status)
     with Pre => (Static => Is_Ready (D));
   pragma Postcondition (Static => Is_Ready (D));
   pragma Postcondition (Static => Shape (D) = Shape (D)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   procedure Compute_Forces (D : in out Simulation; Result : out Status)
     with Pre => (Static => Is_Ready (D));
   pragma Postcondition (Static => Is_Ready (D));
   pragma Postcondition (Static => Shape (D) = Shape (D)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   procedure Invalidate_Actuation (D : in out Simulation) is
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
      D.Cache.Actuation_Valid := False;
      D.Cache.Force_Valid := False;
      pragma Assert (Static => Is_Ready (D));
      Equal_State_Images (D.State.Qpos.all, Initial_Qpos, D.State.Qvel.all, Initial_Qvel,
                          D.Clock, Initial_Clock);
      Equal_Input_Images (D.State.Ctrl.all, Initial_Control,
                          D.State.Applied.all, Initial_Applied);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
   end Invalidate_Actuation;
   procedure Ensure_Poses (D : in out Simulation; Has_Sites : Boolean; Result : out Status) is
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
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Shape);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mass_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Forces_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
   begin
      Result := Success;
      if not Positions_Current (D) then
         Pipeline.Update_Poses (D, Result);
         if Result /= Success then return; end if;
      end if;
      if Has_Sites then
         declare
            Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         begin
            Pipeline.Ensure_Jacobians (D, Result);
            MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         end;
      end if;
   end Ensure_Poses;
   procedure Compute_Forces (D : in out Simulation; Result : out Status) is
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
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Shape);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mass_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Forces_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
   begin
      Inertia_Phase.Assemble (D, Result);
      if Result /= Success then return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
      begin
         Forces_Phase.Compute (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
      end;
   end Compute_Forces;
   procedure Prepare (D : in out Simulation; Has_Sites : Boolean; Result : out Status) is
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
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
   begin
      Invalidate_Actuation (D);
      Ensure_Poses (D, Has_Sites, Result);
      if Result /= Success then return; end if;
      Compute_Forces (D, Result);
   end Prepare;
end MJ.Data.Controller_Dynamics;
