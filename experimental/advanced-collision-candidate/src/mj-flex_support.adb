with MJ.Rigid_Math; use MJ.Rigid_Math;
package body MJ.Flex_Support with SPARK_Mode is
   function Select_Vertex (V : Vertex_Array; Direction : Vec) return Natural is
      K : Natural:=V'First;
      Best : Real:=Dot (V (K),Direction);
      Value : Real;
   begin
      for I in V'First+1 .. V'Last loop
         pragma Loop_Invariant (K in V'First .. I-1);
         pragma Loop_Invariant (Best=Dot (V (K),Direction));
         pragma Loop_Invariant (for all J in V'First .. I-1 => Best>=Dot (V (J),Direction));
         pragma Loop_Invariant (for all J in V'First .. K-1 => Dot (V (J),Direction)<Best);
         Value:=Dot (V (I),Direction);
         if Value>Best then Best:=Value; K:=I; end if;
      end loop;
      return K;
   end Select_Vertex;
end MJ.Flex_Support;
