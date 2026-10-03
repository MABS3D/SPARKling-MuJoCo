with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry;
with MJ.Contact_Geometry;

--  Exact indexing and binary32 promotion at the compiled-asset boundary.
package MJ.Constrained_Asset_Kernels with SPARK_Mode is
   function Promote (X : Float) return Real
     with Global => null, Inline,
       Pre => X in -1.0e10 .. 1.0e10,
       Post => Promote'Result = Real (X)
         and then Promote'Result in MJ.Rigid_Geometry.Coordinate;
   function Vertex_Index (First, Local, Length : Natural) return Natural
     with Global => null, Inline,
       Pre => Local < Length and then Length - 1 <= Natural'Last - First,
       Post => Vertex_Index'Result = First + Local
         and then Vertex_Index'Result in First .. First + (Length - 1);
   function Graph_Span (Vertices, Faces : Natural) return Natural
     with Global => null, Inline,
       Pre => Vertices <= (Natural'Last - 2) / 3
         and then Faces <= (Natural'Last - 2 - 3 * Vertices) / 6,
       Post => Graph_Span'Result = 2 + 3 * Vertices + 6 * Faces;
   procedure Copy_Vertices (Source : Float32_Array;
                            Target : in out MJ.Contact_Geometry.Vertex_Array)
     with Global => null,
       Pre => Source'First = 0 and then Target'First = 0
         and then Target'Length <= 65_536
         and then Source'Length = 3 * Target'Length
         and then (for all X of Source => X in -1.0e10 .. 1.0e10),
       Post => (for all I in Target'Range =>
         (for all K in MJ.Rigid_Geometry.Axis =>
           Target (I) (K) = Real (Source (3 * I + K))
           and then Target (I) (K) in MJ.Rigid_Geometry.Coordinate));
end MJ.Constrained_Asset_Kernels;
