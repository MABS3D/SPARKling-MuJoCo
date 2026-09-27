package body MJ.Pose_Arithmetic with SPARK_Mode is
   function "+" (A, B : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Sum_Matches);
   begin
      return MJ.Smooth_Math."+" (A, B);
   end "+";
   function "-" (A, B : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Difference_Matches);
   begin
      return MJ.Smooth_Math."-" (A, B);
   end "-";
   function "*" (S : Real; V : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Scale_Matches);
   begin
      return MJ.Smooth_Math."*" (S, V);
   end "*";
   function Cross (A, B : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Cross_Matches);
   begin
      return MJ.Smooth_Math.Cross (A, B);
   end Cross;
   function Apply_Config (R : Matrix; V : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Apply_Matches);
   begin
      return MJ.Smooth_Dynamics.Apply_Config (R, V);
   end Apply_Config;
end MJ.Pose_Arithmetic;
