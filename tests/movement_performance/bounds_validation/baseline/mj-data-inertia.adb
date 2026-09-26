with MJ.Data.Inertia_Phase;

package body MJ.Data.Inertia with SPARK_Mode is
   procedure Assemble (D : in out Simulation; Result : out Status) is
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      end if;
      Inertia_Phase.Assemble (D, Result);
   end Assemble;
   procedure Solve_Acceleration (D : in out Simulation; Result : out Status) is
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      end if;
      Inertia_Phase.Solve_Acceleration (D, Result);
   end Solve_Acceleration;
   procedure Solve_Euler (D : in out Simulation; Result : out Status) is
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      end if;
      Inertia_Phase.Solve_Euler (D, Result);
   end Solve_Euler;
end MJ.Data.Inertia;
