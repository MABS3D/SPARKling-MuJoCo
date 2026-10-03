with MJ.Data.Pipeline;
package body MJ.Data.Constrained.Advanced with SPARK_Mode is
   package Parent renames MJ.Data.Constrained;
   function Ready (E : Engine) return Boolean is (Parent.Ready (E.Base) and then AC.Ready (E.Control));
   function State (E : Engine) return Real_Array is (Parent.State (E.Base) & AC.Activation (E.Control));
   function Inputs (E : Engine) return Real_Array is (AC.Inputs (E.Control) & Input_Values (E.Base.D));
   function Activation (E : Engine) return Real_Array is (AC.Activation (E.Control));
   function Rates (E : Engine) return Real_Array is (AC.Rates (E.Control));
   function Control_Count (E : Engine) return Natural is (AC.Control_Count (E.Control));
   function Output_Count (E : Engine) return Natural is (AC.Output_Count (E.Control));
   function Position_Count (E : Engine) return Natural is (AC.Position_Count (E.Control));
   function Velocity_Count (E : Engine) return Natural is (AC.Velocity_Count (E.Control));
   function Lengths (E : Engine) return Real_Array is (AC.Lengths (E.Control));
   function Velocities (E : Engine) return Real_Array is (AC.Velocities (E.Control));
   function Forces (E : Engine) return Real_Array is (AC.Forces (E.Control));
   function Generalized (E : Engine) return Real_Array is (AC.Generalized (E.Control));
   function Accelerations (E : Engine) return Real_Array is
     ([for I in 0 .. Integer (Velocity_Count (E))-1 => E.Base.T.Acceleration (I+1)]);
   function Diagnostics (E : Engine) return Trace is (Parent.Diagnostics (E.Base));
   procedure Free (E : in out Engine) is
      Ignored : Status;
   begin
      Parent.Free (E.Base, Ignored); AC.Free (E.Control);
   end Free;
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status) is
   begin
      if not Is_Empty (E.Base.D) then Result := Already_Allocated; return; end if;
      AC.Configure (M, E.Control, Result);
      if Result /= Success then return; end if;
      Parent.Create_Core (M, E.Base, Result, Dynamics_Only => True);
      if Result /= Success then Free (E); end if;
   exception
      when Constraint_Error => Free (E); Result := Invalid_Model;
   end Create;
   procedure Reset (E : in out Engine; Result : out Status) is
   begin
      MJ.Data.Reset (E.Base.D, Result);
      if Result = Success then AC.Reset (E.Control); E.Base.T.Valid := False; end if;
   end Reset;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        Clock : Nonneg_Tier0; Result : out Status) is
   begin
      Parent.Set_State (E.Base, Qpos, Qvel, Clock, Result);
      if Result = Success then AC.Invalidate (E.Control); end if;
   end Set_State;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      AC.Set_Control (E.Control, Index, Value, Result);
      if Result = Success then E.Base.T.Valid := False; end if;
   end Set_Control;
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status) is
   begin
      AC.Set_Activation (E.Control, Values, Result);
      if Result = Success then E.Base.T.Valid := False; end if;
   end Set_Activation;
   procedure Set_Applied (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      Parent.Set_Applied_Force (E.Base, Index, Value, Result);
      if Result = Success then AC.Invalidate (E.Control); end if;
   end Set_Applied;
   procedure Evaluate (E : in out Engine; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      Saved : constant AC.Evaluation_State := AC.Capture_Evaluation (E.Control);
      procedure Reject is
      begin
         AC.Restore_Evaluation (E.Control, Saved);
         Invalidate (E.Base.D.Cache); E.Base.T.Valid := False;
      end Reject;
   begin
      E.Base.T.Valid := False;
      if not Ready (E) then Result := Not_Allocated; return; end if;
      AC.Evaluate (E.Base.D, E.Control, Result, External);
      if Result /= Success then Reject; return; end if;
      Parent.Generate_Contacts (E.Base, Result);
      if Result /= Success then Reject; return; end if;
      if E.Base.T.Ncontact > 0 then
         Pipeline.Ensure_Jacobians (E.Base.D, Result);
         if Result /= Success then Reject; return; end if;
      end if;
      Parent.Assemble (E.Base, Result);
      if Result /= Success then Reject; return; end if;
      Parent.Prepare_And_Solve (E.Base, Result);
      if Result /= Success then Reject; end if;
   exception
      when Constraint_Error => Reject; Result := Numeric_Limit;
   end Evaluate;
   procedure Step (E : in out Engine; Result : out Status;
                  External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      Saved : constant AC.Evaluation_State := AC.Capture_Evaluation (E.Control);
      procedure Reject is
      begin
         AC.Restore_Evaluation (E.Control, Saved);
         Invalidate (E.Base.D.Cache); E.Base.T.Valid := False;
      end Reject;
   begin
      Evaluate (E, Result, External);
      if Result /= Success then Reject; return; end if;
      AC.Stage_Advance (E.Base.D, E.Control, Result);
      if Result /= Success then Reject; return; end if;
      Parent.Advance (E.Base, Result);
      if Result = Success then AC.Publish (E.Control); else Reject; end if;
   exception
      when Constraint_Error => Reject; Result := Numeric_Limit;
   end Step;
end MJ.Data.Constrained.Advanced;
