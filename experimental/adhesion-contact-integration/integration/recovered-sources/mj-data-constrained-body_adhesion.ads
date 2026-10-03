with MJ.External_Forces;

private package MJ.Data.Constrained.Body_Adhesion with SPARK_Mode is
   procedure Apply
     (E : in out Engine; Result : out Status;
      External : MJ.External_Forces.Wrench_Array)
     with Global => null, Pre => Ready (E),
       Post => (Static => Complete_State (E) = Complete_State (E)'Old);
end MJ.Data.Constrained.Body_Adhesion;
