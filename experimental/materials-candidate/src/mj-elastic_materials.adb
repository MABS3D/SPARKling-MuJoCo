package body MJ.Elastic_Materials with SPARK_Mode is
   type Edge_Map is array (Packed_Index) of Edge_Index;
   Volume_Row : constant Edge_Map :=
     [0,0,0,0,0,0,1,1,1,1,1,2,2,2,2,3,3,3,4,4,5];
   Volume_Column : constant Edge_Map :=
     [0,1,2,3,4,5,1,2,3,4,5,2,3,4,5,3,4,5,4,5,5];
   Shell_Row : constant Edge_Map := [0,0,0,1,1,2, others => 0];
   Shell_Column : constant Edge_Map := [0,1,2,1,2,2, others => 0];

   function Row (Kind : Element_Kind; K : Packed_Index) return Edge_Index is
     (if Kind = Triangle then Shell_Row (K) else Volume_Row (K));
   function Column (Kind : Element_Kind; K : Packed_Index) return Edge_Index is
     (if Kind = Triangle then Shell_Column (K) else Volume_Column (K));

   procedure Compile_Metric
     (M : Material; Kind : Element_Kind; Measure : Measure_Value;
      Basis : Element_Basis; Result : out Element_Metric)
   is
      Mu : constant Weighted_Value := Weighted_Shear (M, Kind, Measure);
      Lambda : constant Weighted_Value := Weighted_Lame (M, Kind, Measure);
   begin
      if Kind = Triangle then
         --  Fixed edge pairs let the compiler share the three traces and
         --  vectorize the six contractions, without changing their order.
         Result :=
           [Metric_Entry (Mu, Lambda, Basis (0), Basis (0)),
            Metric_Entry (Mu, Lambda, Basis (0), Basis (1)),
            Metric_Entry (Mu, Lambda, Basis (0), Basis (2)),
            Metric_Entry (Mu, Lambda, Basis (1), Basis (1)),
            Metric_Entry (Mu, Lambda, Basis (1), Basis (2)),
            Metric_Entry (Mu, Lambda, Basis (2), Basis (2)),
            others => 0.0];
      else
         Result := [for K in Packed_Index => Metric_Entry
           (Mu, Lambda, Basis (Row (Kind, K)), Basis (Column (Kind, K)))];
      end if;
   end Compile_Metric;
end MJ.Elastic_Materials;
