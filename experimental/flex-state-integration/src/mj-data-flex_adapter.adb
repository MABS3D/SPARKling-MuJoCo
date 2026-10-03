with MJ.Rigid_Geometry;
package body MJ.Data.Flex_Adapter with SPARK_Mode is
   procedure Update (D : Simulation; Flex : in out MJ.Flex_State.State;
                     Result : out MJ.Flex_State.Status) is
      package RG renames MJ.Rigid_Geometry;
      Poses : RG.Pose_Array (0 .. Body_Count (D)-1);
      R : Matrix;
      V : Vector;
   begin
      for B in Poses'Range loop
         V := Body_Position (D,B); R := Rotation (Body_Orientation (D,B));
         for I in RG.Axis loop
            Poses (B).Position (I) := V (I);
            for J in RG.Axis loop Poses (B).Rotation (3*I+J) := R (I,J); end loop;
         end loop;
      end loop;
      MJ.Flex_State.Update (Flex,Poses,Result);
   end Update;
end MJ.Data.Flex_Adapter;
