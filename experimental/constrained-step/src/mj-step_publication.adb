package body MJ.Step_Publication with SPARK_Mode is
   function Has_Iterate (Outcome : Solver_Status) return Boolean is
     (Outcome in Converged | Iteration_Limit | Stalled | Line_Search_Limit);

   procedure Publish
     (Qpos, Qvel : out Real_Array; Activation : out Activation_Array;
      Clock : out Nonneg_Tier0;
      Next_Qpos, Next_Qvel : Real_Array; Next_Activation : Activation_Array;
      Next_Time : Nonneg_Tier0)
   is
   begin
      Qpos := Next_Qpos;
      Qvel := Next_Qvel;
      Activation := Next_Activation;
      Clock := Next_Time;
   end Publish;
end MJ.Step_Publication;
