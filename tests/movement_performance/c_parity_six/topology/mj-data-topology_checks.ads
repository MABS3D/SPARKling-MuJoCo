--  Test-only access, excluded from shipping source and formal claims.
package MJ.Data.Topology_Checks is
   procedure Check (M : MJ.Models.Model; D : Simulation; Expect_All_Simple : Boolean);
   procedure General_Only (D : Simulation);
   procedure Same (A, B : Simulation);
end MJ.Data.Topology_Checks;
