with MJ.Smooth_Math;
with MJ.Ray_Kernels;
package body MJ.Data.Rays with SPARK_Mode is
   procedure Synchronize (D : Simulation; S : in out MJ.Rays.Scene;
                          Result : out Status) is
      package K renames MJ.Ray_Kernels;
      package SM renames MJ.Smooth_Math;
      P : SM.Vector; Q : SM.Quaternion; R : SM.Matrix;
   begin
      if not Is_Ready (D) then Result:=Not_Allocated; return; end if;
      if not Positions_Current (D) then Result:=Stale_Results; return; end if;
      if not MJ.Rays.Ready (S) or else MJ.Rays.Body_Count (S)/=Body_Count (D)
      then Result:=Invalid_Model; return; end if;
      --  Validate all body positions before publishing any pose. Metadata
      --  and unit orientations were validated by the Model/Data producers.
      for B in 0 .. Body_Count (D)-1 loop
         Get_Body_Pose (D,B,P,Q,Result);
         if Result/=Success then return; end if;
         if not (for all V of P => V in -1.0e10 .. 1.0e10) then Result:=Numeric_Limit; return; end if;
      end loop;
      for B in 0 .. Body_Count (D)-1 loop
         Get_Body_Pose (D,B,P,Q,Result);
         if Result/=Success then return; end if;
         R:=SM.Rotation (Q);
         MJ.Rays.Set_Body_Pose (S,B,K.Vector'([for I in K.Axis => P (I)]),
           K.Matrix'([for I in K.Axis => [for J in K.Axis => R (I,J)]]));
      end loop;
      Result:=Success;
   end Synchronize;
end MJ.Data.Rays;
