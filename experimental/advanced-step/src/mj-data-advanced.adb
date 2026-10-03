with MJ.Data.Euler.Advanced;
package body MJ.Data.Advanced with SPARK_Mode is
   function Ready (E : Engine) return Boolean is (AC.Ready (E.C) and then Is_Ready (E.D));
   function State (E : Engine) return Real_Array is (State_Values (E.D) & AC.Activation (E.C));
   function Inputs (E : Engine) return Real_Array is (AC.Inputs (E.C) & Input_Values (E.D));
   function Activation (E : Engine) return Real_Array is (AC.Activation (E.C));
   function Rates (E : Engine) return Real_Array is (AC.Rates (E.C));
   function Lengths (E : Engine) return Real_Array is (AC.Lengths (E.C));
   function Velocities (E : Engine) return Real_Array is (AC.Velocities (E.C));
   function Forces (E : Engine) return Real_Array is (AC.Forces (E.C));
   function Generalized (E : Engine) return Real_Array is (AC.Generalized (E.C));
   function Accelerations (E : Engine) return Real_Array is (AC.Accelerations (E.C));
   function Control_Count (E : Engine) return Natural is (AC.Control_Count (E.C));
   function Output_Count (E : Engine) return Natural is (AC.Output_Count (E.C));
   function Position_Count (E : Engine) return Natural is (AC.Position_Count (E.C));
   function Velocity_Count (E : Engine) return Natural is (AC.Velocity_Count (E.C));
   procedure Free (E : in out Engine) is
   begin
      MJ.Data.Free (E.D); AC.Free (E.C);
   end Free;
   procedure Reset (E : in out Engine; Result : out Status) is
   begin
      MJ.Data.Reset (E.D, Result);
      if Result = Success then AC.Reset (E.C); end if;
   end Reset;
   procedure Create (M : MJ.Models.Model; E : in out Engine; Result : out Status) is
   begin
      if not Is_Empty (E.D) then Result := Already_Allocated; return; end if;
      AC.Configure (M, E.C, Result);
      if Result /= Success then return; end if;
      Create_Dynamics (M, E.D, Result);
      if Result /= Success then Free (E); return; end if;
      Reset (E, Result);
   exception
      when Constraint_Error => Free (E); Result := Invalid_Model;
   end Create;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        Clock : Nonneg_Tier0; Result : out Status) is
   begin
      MJ.Data.Set_State (E.D, Qpos, Qvel, Clock, Result);
      if Result = Success then AC.Invalidate (E.C); end if;
   end Set_State;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real;
                          Result : out Status) is
   begin
      AC.Set_Control (E.C, Index, Value, Result);
   end Set_Control;
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status) is
   begin
      AC.Set_Activation (E.C, Values, Result);
   end Set_Activation;
   procedure Set_Applied (E : in out Engine; Index : Natural; Value : Tier0_Real;
                         Result : out Status) is
   begin
      MJ.Data.Set_Applied_Force (E.D, Index, Value, Result);
      if Result = Success then AC.Invalidate (E.C); end if;
   end Set_Applied;
   procedure Evaluate (E : in out Engine; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      AC.Evaluate (E.D, E.C, Result, External);
   end Evaluate;
   procedure Step (E : in out Engine; Result : out Status;
                  External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      Saved : constant AC.Evaluation_State := AC.Capture_Evaluation (E.C);
      procedure Reject is
      begin
         AC.Restore_Evaluation (E.C, Saved);
         Invalidate (E.D.Cache);
      end Reject;
   begin
      AC.Evaluate (E.D, E.C, Result, External);
      if Result /= Success then Reject; return; end if;
      AC.Stage_Advance (E.D, E.C, Result);
      if Result /= Success then Reject; return; end if;
      MJ.Data.Euler.Advanced.Advance (E.D, Result);
      if Result = Success then AC.Publish (E.C); else Reject; end if;
   exception
      when Constraint_Error => Reject; Result := Numeric_Limit;
   end Step;
end MJ.Data.Advanced;
