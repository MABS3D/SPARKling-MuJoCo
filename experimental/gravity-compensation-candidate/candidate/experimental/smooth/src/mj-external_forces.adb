package body MJ.External_Forces with SPARK_Mode is
   function Dot_Load (Column : Vector; Load : Input_Vector) return Projection_Real is
     ((Column (0) * Load (0) + Column (1) * Load (1)) + Column (2) * Load (2));
   function Contribution
     (Previous : MJ.Smooth_Dynamics.Work_Real;
      Linear, Angular : Vector; Load : Wrench) return Contribution_Real is
     ((Previous + Dot_Load (Linear, Load.Force)) + Dot_Load (Angular, Load.Torque));
end MJ.External_Forces;
