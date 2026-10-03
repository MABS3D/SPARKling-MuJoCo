with MJ.Data.Kinematics;
with MJ.Data.Inertia;
with MJ.Data.Forces;
with MJ.Inverse_Kernels;
with MJ.Inverse_Mass;

package body MJ.Data.Inverse with SPARK_Mode is
   procedure Current
     (D : Simulation; Qacc : State_Vector; Required_Force : in out Real_Array;
      Result : out Status; Constraint_Force : Real_Array := No_Constraints) is
   begin
      Result := Not_Allocated;
      if not Is_Ready (D) then return; end if;
      Result := Invalid_Size;
      if Qacc'Length /= D.Nv or else Required_Force'Length /= D.Nv
        or else (Constraint_Force'Length /= 0 and then Constraint_Force'Length /= D.Nv)
      then return; end if;
      Result := Stale_Results;
      if not Mass_Current (D) or else not Passive_Current (D) then return; end if;
      Result := Numeric_Limit;
      if (for some X of Constraint_Force => X not in -1.0e60 .. 1.0e60) then return; end if;
      declare
         Acceleration : constant Real_Array (0 .. D.Nv - 1) := As_Reals (Qacc);
         Candidate : Real_Array (0 .. D.Nv - 1) := [others => 0.0];
         Ok : Boolean;
      begin
         MJ.Inverse_Mass.Multiply
           (D.Ancestors, D.Dynamics.Mass.all, Acceleration, Candidate, Ok);
         if not Ok then return; end if;
         for I in Candidate'Range loop
            declare
               F : constant Real := MJ.Inverse_Kernels.Required
                 (Candidate (I), D.Dynamics.Bias (I), D.Dynamics.Gravity (I),
                  D.Dynamics.Passive (I),
                  (if Constraint_Force'Length = 0 then 0.0
                   else Constraint_Force (Constraint_Force'First + I)));
            begin
               if F not in -1.0e60 .. 1.0e60 then return; end if;
               Candidate (I) := F;
            end;
         end loop;
         Required_Force := Candidate;
         Result := Success;
      end;
   end Current;

   procedure Evaluate
     (D : in out Simulation; Qacc : State_Vector; Required_Force : in out Real_Array;
      Result : out Status) is
   begin
      Result := Not_Allocated;
      if not Is_Ready (D) then return; end if;
      Result := Invalid_Size;
      if Qacc'Length /= D.Nv or else Required_Force'Length /= D.Nv then return; end if;
      MJ.Data.Kinematics.Update (D, Result);
      if Result /= Success then return; end if;
      MJ.Data.Inertia.Assemble (D, Result);
      if Result /= Success then return; end if;
      MJ.Data.Forces.Compute (D, Result);
      if Result /= Success then return; end if;
      Current (D, Qacc, Required_Force, Result);
   end Evaluate;
end MJ.Data.Inverse;
