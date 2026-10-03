with MJ.Data;
with MJ.Data.Forward;
with MJ.Data.Euler;
with MJ.External_Forces;
with MJ.Models;
with MJ.Types; use MJ.Types;
--  Native Ada bindings preserve the backend's domains, statuses and contracts.
--  These are renames: no extra work is added to the movement call path.
package MJ.API.Runtime with SPARK_Mode is
   subtype Data is MJ.Data.Simulation;
   subtype Data_Status is MJ.Data.Status;
   subtype State_Vector is MJ.Data.State_Vector;
   subtype Inertia_Policy is MJ.Data.Inertia_Policy;
   procedure Make_Data (M : MJ.Models.Model; D : in out Data; Result : out Data_Status;
                        Solver_Policy : Inertia_Policy := MJ.Data.Compatible)
     renames MJ.Data.Create;
   procedure Delete_Data (D : in out Data) renames MJ.Data.Free;
   procedure Reset_Data (D : in out Data; Result : out Data_Status) renames MJ.Data.Reset;
   procedure Step (D : in out Data; Result : out Data_Status;
                   External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     renames MJ.Data.Euler.Step;
   procedure Forward (D : in out Data; Result : out Data_Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     renames MJ.Data.Forward.Evaluate;
   procedure Get_State (D : Data; Qpos, Qvel : out Real_Array;
                        Current_Time : out Real; Result : out Data_Status)
     renames MJ.Data.Get_State;
   procedure Set_State (D : in out Data; Qpos, Qvel : State_Vector;
                        New_Time : Nonneg_Tier0; Result : out Data_Status)
     renames MJ.Data.Set_State;
   procedure Set_Activation (D : in out Data; Values : State_Vector; Result : out Data_Status)
     renames MJ.Data.Set_Activation;
   procedure Set_Control (D : in out Data; Index : Natural; Value : Tier0_Real;
                          Result : out Data_Status) renames MJ.Data.Set_Control;
   procedure Set_Applied_Force (D : in out Data; Index : Natural; Value : Tier0_Real;
                                Result : out Data_Status) renames MJ.Data.Set_Applied_Force;
end MJ.API.Runtime;
