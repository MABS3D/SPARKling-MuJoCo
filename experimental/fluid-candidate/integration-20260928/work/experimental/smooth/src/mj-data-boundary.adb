package body MJ.Data.Boundary with SPARK_Mode is
   function Ready (D : Simulation) return Boolean is
   begin
      return D.Allocated;
   end Ready;
end MJ.Data.Boundary;
