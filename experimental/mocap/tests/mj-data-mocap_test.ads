-- Test-only access to the alternate constructor used by native adapters.
with MJ.Models;
package MJ.Data.Mocap_Test is
   procedure Create_Dynamics
     (M : MJ.Models.Model; D : in out Simulation; Result : out Status);
end MJ.Data.Mocap_Test;
