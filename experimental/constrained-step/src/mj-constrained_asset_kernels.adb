package body MJ.Constrained_Asset_Kernels with SPARK_Mode is
   function Promote (X : Float) return Real is (Real (X));
   function Vertex_Index (First, Local, Length : Natural) return Natural is
     (First + Local);
   function Graph_Span (Vertices, Faces : Natural) return Natural is
     (2 + 3 * Vertices + 6 * Faces);
   procedure Copy_Vertices (Source : Float32_Array;
                            Target : in out MJ.Contact_Geometry.Vertex_Array) is
   begin
      for I in Target'Range loop
         Target (I) := [Promote (Source (3 * I)), Promote (Source (3 * I + 1)),
                       Promote (Source (3 * I + 2))];
         pragma Loop_Invariant (for all J in Target'First .. I =>
           (for all K in MJ.Rigid_Geometry.Axis =>
             Target (J) (K) = Real (Source (3 * J + K))
             and then Target (J) (K) in MJ.Rigid_Geometry.Coordinate));
      end loop;
   end Copy_Vertices;
end MJ.Constrained_Asset_Kernels;
