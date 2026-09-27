--  Public Simulation values satisfy Valid_State: empty or ready. The owned
--  representation makes the allocation bit an exact constant-time test here.
private package MJ.Data.Boundary with SPARK_Mode is
   function Ready (D : Simulation) return Boolean
     with Inline_Always, Global => null, Pre => Valid_State (D),
     Post => Ready'Result = Is_Ready (D);
end MJ.Data.Boundary;
