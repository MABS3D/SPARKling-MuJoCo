with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Rigid_Math;
package MJ.Flex_Support with SPARK_Mode is
   function Select_Vertex (V : Vertex_Array; Direction : Vec) return Natural
     with Global=>null,
       Pre=>V'Length in 1 .. 4 and then V'Last<Natural'Last
         and then (for all P of V => (for all X of P => X in Coordinate))
         and then MJ.Rigid_Math.Bounded (Direction),
       Post=>Select_Vertex'Result in V'Range
         and then (for all I in V'Range =>
           MJ.Rigid_Math.Dot (V (Select_Vertex'Result),Direction)>=MJ.Rigid_Math.Dot (V (I),Direction))
         and then (for all I in V'First .. Select_Vertex'Result-1 =>
           MJ.Rigid_Math.Dot (V (I),Direction)<MJ.Rigid_Math.Dot (V (Select_Vertex'Result),Direction));
end MJ.Flex_Support;
