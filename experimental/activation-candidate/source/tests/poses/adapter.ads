with Interfaces.C;
with System;
with MJ.Poses;
package Adapter is
   type Pose_Buffer is record
      Position : MJ.Poses.Vector_3;
      Orientation : MJ.Poses.Quaternion;
   end record with Convention => C, Size => 448;
   for Pose_Buffer use record
      Position at 0 range 0 .. 191;
      Orientation at 24 range 0 .. 255;
   end record;
   type Pose_Pointer is access all Pose_Buffer with Convention => C;
   type Vector_Pointer is access all MJ.Poses.Vector_3 with Convention => C;
   procedure Evaluate (A, B, V, R : System.Address) with
     Export, Convention => C, External_Name => "pose_evaluate";
   function Run (Op, Reps : Interfaces.C.int; A, B : Pose_Pointer;
                 V : Vector_Pointer; R : System.Address)
     return Interfaces.C.double with Export, Convention => C,
     External_Name => "pose_run", No_Inline;
end Adapter;
