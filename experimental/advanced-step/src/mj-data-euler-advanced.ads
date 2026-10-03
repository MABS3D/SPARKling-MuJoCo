package MJ.Data.Euler.Advanced with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   --  Advance an already evaluated extension without recomputing actuation.
   procedure Advance (D : in out Simulation; Result : out Status) with
     Global => null, Pre => Is_Ready (D) and then Forces_Current (D),
     Post => Is_Ready (D) and then Shape (D) = Shape (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then (if Result /= Success then State_Values (D) = State_Values (D)'Old);
end MJ.Data.Euler.Advanced;
