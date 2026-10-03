with MJ.Types; use MJ.Types;

package MJ.Mocap_Kernels with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   --  Raw inputs are retained: C normalizes a local quaternion in kinematics.
   procedure Write_Pose
     (Positions, Quaternions : in out Real_Array; Index : Natural;
      Position, Quaternion : Real_Array)
     with Global => null,
       Pre => Positions'First = 0 and then Quaternions'First = 0
         and then Positions'Length <= 3 * 4_096
         and then Quaternions'Length <= 4 * 4_096
         and then Positions'Length mod 3 = 0
         and then Quaternions'Length = 4 * (Positions'Length / 3)
         and then Index < Positions'Length / 3
         and then Position'Length = 3 and then Quaternion'Length = 4,
       Post => (Static => Positions'First = Positions'First'Old
         and then Positions'Last = Positions'Last'Old
         and then Quaternions'First = Quaternions'First'Old
         and then Quaternions'Last = Quaternions'Last'Old
         and then (for all I in Positions'Range =>
           Positions (I) = (if I in 3 * Index .. 3 * Index + 2
             then Position (Position'First + (I - 3 * Index))
             else Positions'Old (I)))
         and then (for all I in Quaternions'Range =>
           Quaternions (I) = (if I in 4 * Index .. 4 * Index + 3
             then Quaternion (Quaternion'First + (I - 4 * Index))
             else Quaternions'Old (I))));
end MJ.Mocap_Kernels;
