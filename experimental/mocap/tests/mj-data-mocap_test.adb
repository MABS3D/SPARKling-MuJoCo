package body MJ.Data.Mocap_Test is
   procedure Create_Dynamics
     (M : MJ.Models.Model; D : in out Simulation; Result : out Status) is
   begin
      MJ.Data.Create_Dynamics (M, D, Result);
   end Create_Dynamics;
end MJ.Data.Mocap_Test;
