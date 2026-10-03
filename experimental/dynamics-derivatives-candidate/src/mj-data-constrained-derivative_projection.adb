with MJ.Inverse_Constraints;
package body MJ.Data.Constrained.Derivative_Projection with SPARK_Mode is
   function Actuation (E : Engine) return Real_Array is (E.D.Dynamics.Actuator.all);
   procedure Evaluate (E : Engine; Acc : State_Vector; Sparse : Boolean;
                       Force : out Real_Array; Result : out Status) is
   begin
      Result := Stale_Results;
      if not E.T.Valid then return; end if;
      if Acc'First /= 0 or else Acc'Length /= E.T.Nv
        or else Force'First /= 0 or else Force'Length /= E.T.Nv
      then Result := Invalid_Size; return; end if;
      declare
         Rows : Real_Array (1 .. E.T.Nrow) := [others => 0.0];
         Generalized : Real_Array (Force'Range) := [others => 0.0];
         Accepted : Boolean;
      begin
         MJ.Inverse_Constraints.Evaluate
           (E.Rows, E.Solver_Rows (1 .. E.T.Nrow), E.T.Aref (1 .. E.T.Nrow),
            As_Reals (Acc), Rows, Generalized, Accepted, Sparse);
         if not Accepted then Result := Numeric_Limit; return; end if;
         Force := Generalized;
         Result := Success;
      end;
   end Evaluate;
end MJ.Data.Constrained.Derivative_Projection;
