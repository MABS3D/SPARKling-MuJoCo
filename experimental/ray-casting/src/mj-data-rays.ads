with MJ.Rays;
package MJ.Data.Rays with SPARK_Mode is
   --  Scene owns its model data; source M may be freed after Initialize.
   --  Update kinematics explicitly before this read-only adapter.
   procedure Synchronize (D : Simulation; S : in out MJ.Rays.Scene;
                          Result : out Status);
end MJ.Data.Rays;
