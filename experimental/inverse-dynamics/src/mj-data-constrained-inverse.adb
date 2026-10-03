with MJ.Data.Inverse;
with MJ.Inverse_Constraints;
package body MJ.Data.Constrained.Inverse with SPARK_Mode is
   procedure Current
     (E : Engine; Qacc : State_Vector; Required_Force, Row_Force : in out Real_Array;
      Result : out Status) is
   begin
      Result := Not_Allocated;
      if not Ready (E) then return; end if;
      Result := Stale_Results;
      if not E.T.Valid then return; end if;
      Result := Invalid_Size;
      if Qacc'Length /= E.D.Nv or else Required_Force'Length /= E.D.Nv
        or else Row_Force'Length /= E.Rows.Rows then return; end if;
      declare
         Constraint_Force : Real_Array (0 .. E.D.Nv - 1) := [others => 0.0];
         Candidate : Real_Array (Required_Force'Range) := Required_Force;
         F : Real_Array (Row_Force'Range) := Row_Force;
         Ok : Boolean;
      begin
         MJ.Inverse_Constraints.Evaluate
           (E.Rows, E.Solver_Rows (1 .. E.Rows.Rows), E.T.Aref (1 .. E.Rows.Rows),
            As_Reals (Qacc), F, Constraint_Force, Ok, E.Settings.Sparse);
         if not Ok then Result := Numeric_Limit; return; end if;
         MJ.Data.Inverse.Current (E.D, Qacc, Candidate, Result, Constraint_Force);
         if Result /= Success then return; end if;
         Required_Force := Candidate;
         Row_Force := F;
      end;
   end Current;
end MJ.Data.Constrained.Inverse;
