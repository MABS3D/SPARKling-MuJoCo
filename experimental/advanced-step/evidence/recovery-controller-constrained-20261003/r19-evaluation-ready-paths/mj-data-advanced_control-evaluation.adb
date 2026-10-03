with MJ.Controller_Array_Kernels;
with MJ.Data.Inertia_Phase;
with MJ.Data.Controller_Forces;
with MJ.Data.Controller_Dynamics;
with MJ.Data.Advanced_Control.Computation;
package body MJ.Data.Advanced_Control.Evaluation with SPARK_Mode is
   procedure Evaluate_Ready (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Pre => (Static => Ready (E) and then Is_Ready (D)
       and then D.Nq = E.Nq and then D.Nv = E.Nv and then D.Nb = E.Nb
       and then (External'Length = 0 or else
         (External'First = 0 and then Int64 (External'Length) = Int64 (D.Nb)))),
       Post => (Static => E.No = E.No'Old);
   pragma Postcondition (Static => E.Na = E.Na'Old);
   pragma Postcondition (Static => E.Nv = E.Nv'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (Static => E.Act = E.Act'Old);
   pragma Postcondition (Static => E.Control = E.Control'Old and then E.Nu = E.Nu'Old);
   procedure Evaluate_Ready (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
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
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Controller_Array_Kernels.Prefix);
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Na : constant Natural := E.Na with Ghost => Static;
      Initial_Activation : constant Real_Array := Activation (E) with Ghost => Static;
   begin
      pragma Assert (Static => Activation (E)'Length = E.Na);
      Controller_Dynamics.Prepare (D, E.Has_Sites, Result);
      if Result /= Success then return; end if;
      Computation.Compute (D, E, Result);
      pragma Assert (Static => E.Na = Initial_Na);
      pragma Assert (Static => Activation (E) = Initial_Activation);
      if Result /= Success then return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      begin
         Controller_Forces.Publish (D, E.Qforce (0 .. D.Nv-1), Result);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
      end;
      if Result /= Success then return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      begin
         Inertia_Phase.Solve_Acceleration (D, Result, External);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
      end;
      if Result = Success then E.Acc (0 .. D.Nv-1) := D.Dynamics.Acceleration.all; E.Valid := True; end if;
      pragma Assert (Static => Activation (E) = Initial_Activation);
      pragma Assert (Static => Activation (E)'Length = Initial_Activation'Length);
   exception
      when Constraint_Error => D.Cache.Force_Valid := False; D.Cache.Actuation_Valid := False; Result := Numeric_Limit;
   end Evaluate_Ready;
   procedure Evaluate_Into (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => Output_Count (E) = Output_Count (E)'Old);
   pragma Postcondition (Static => Activation (E)'Length = Activation (E)'Old'Length);
   pragma Postcondition (Static => Velocity_Count (E) = Velocity_Count (E)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (Static => Activation (E) = Activation (E)'Old);
   pragma Postcondition (Static => Inputs (E) = Inputs (E)'Old);
   procedure Evaluate_Into (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      E.Valid := False;
      if not Ready (E) or else not Is_Ready (D) then Result := Not_Allocated; return; end if;
      if D.Nq /= E.Nq or else D.Nv /= E.Nv or else D.Nb /= E.Nb then Result := Invalid_Size; return; end if;
      if External'Length /= 0 and then (External'First /= 0 or else Int64 (External'Length) /= Int64 (D.Nb)) then Result := Invalid_Size; return; end if;
      Evaluate_Ready (D,E,Result,External);
   end Evaluate_Into;
   procedure Evaluate (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      Saved : constant Evaluation_State := Capture_Evaluation (E);
   begin
      Evaluate_Into (D, E, Result, External);
      if Result /= Success then
         Restore_Evaluation (E, Saved);
         D.Cache.Actuation_Valid := False; D.Cache.Force_Valid := False;
      end if;
   end Evaluate;
end MJ.Data.Advanced_Control.Evaluation;
