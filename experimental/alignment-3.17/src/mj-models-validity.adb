package body MJ.Models.Validity with SPARK_Mode is
   procedure Reveal_Mesh_Layout (M : Model) is
   begin
      null;
   end Reveal_Mesh_Layout;

   function Mesh_Faces_At (M : Model; I : Integer) return Boolean is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mesh_Faces_Core);
   begin
      Reveal_Mesh_Layout (M);
      return Mesh_Faces_Core (M, I);
   end Mesh_Faces_At;
end MJ.Models.Validity;
