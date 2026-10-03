package body MJ.Mocap_Kernels with SPARK_Mode is
   procedure Write_Pose
     (Positions, Quaternions : in out Real_Array; Index : Natural;
      Position, Quaternion : Real_Array) is
   begin
      Positions (3 * Index .. 3 * Index + 2) := Position;
      Quaternions (4 * Index .. 4 * Index + 3) := Quaternion;
   end Write_Pose;
end MJ.Mocap_Kernels;
