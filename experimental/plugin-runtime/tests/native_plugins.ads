with MJ.Plugin_Protocol; use MJ.Plugin_Protocol;
with MJ.Types; use MJ.Types;
package Native_Plugins with SPARK_Mode is
   procedure Invoke
     (H : Hook; Kind : Capability; Instance : Natural; C : Configuration;
      F : Frame; State : in out Values; Output : in out Outputs; Accepted : out Boolean)
     with Global => null,
     Post => (if Accepted and then H = Compute and then Kind = Passive then
       Output.Passive (0) = (Output.Passive'Old (0) - C.Parameters (0) * F.Qpos (0))
         - C.Parameters (1) * F.Qvel (0))
       and then (if Accepted and then H = Distance then
         Output.Distance = F.Point (2) - C.Parameters (10))
       and then (if Accepted and then H = Gradient then Output.Gradient = [0.0, 0.0, 1.0]);
end Native_Plugins;
