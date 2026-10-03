with MJ.Adhesion;
with MJ.External_Forces;

private package MJ.Data.Constrained.Body_Adhesion with SPARK_Mode is
   -- Sparse reduction preserves compressed-index lane and tail order from C.
   function Sparse_Velocity
     (Moment : MJ.Adhesion.Moment_Array; Velocity : Real_Array) return Real
     with Global => null,
       Pre => Moment'First = Velocity'First and then Moment'Last = Velocity'Last;
   procedure Apply
     (E : in out Engine; Result : out Status;
      External : MJ.External_Forces.Wrench_Array)
     with Global => null, Pre => Ready (E),
       Post => (Static => Complete_State (E) = Complete_State (E)'Old);
end MJ.Data.Constrained.Body_Adhesion;
