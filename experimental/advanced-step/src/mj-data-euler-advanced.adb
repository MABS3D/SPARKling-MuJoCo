with MJ.Data.Inertia_Phase;
package body MJ.Data.Euler.Advanced with SPARK_Mode is
   procedure Advance (D : in out Simulation; Result : out Status) is
   begin
      Inertia_Phase.Solve_Euler (D, Result);
      if Result /= Success then return; end if;
      Integrate (D, Result);
   end Advance;
end MJ.Data.Euler.Advanced;
