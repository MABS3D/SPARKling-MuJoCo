with MJ.Data.Sensors;
package MJ.Data.Constrained.Sensors with SPARK_Mode is
   subtype Context is MJ.Data.Sensors.Context;
   procedure Create (M : in out MJ.Models.Model; E : in out Engine;
                     S : in out Context; Result : out Status);
   procedure Evaluate (E : in out Engine; S : in out Context; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads);
   procedure Step (E : in out Engine; S : in out Context; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads);
end MJ.Data.Constrained.Sensors;
