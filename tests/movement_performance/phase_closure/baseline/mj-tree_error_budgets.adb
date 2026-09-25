package body MJ.Tree_Error_Budgets with SPARK_Mode is
   procedure Propagate
     (Parent : Parent_Array; Joints : Count_Array;
      Depth : out Depth_Array; Products : out Product_Array; Budget : out Budget_Array)
   is
   begin
      Depth := [others => 0];
      Products := [others => 0];
      Budget := [others => 0];
      for B in 1 .. Parent'Last loop
         --  The parent of this body belongs to the established prefix.
         pragma Loop_Invariant (Depth (0) = 0 and then Products (0) = 0 and then Budget (0) = 0);
         pragma Loop_Invariant (for all K in 0 .. B - 1 =>
           Depth (K) <= K
           and then Products (K) <= (Max_Joints + 1) * Depth (K)
           and then Budget (K) = Units_Per_Product * Products (K));
         pragma Loop_Invariant (for all K in 1 .. B - 1 =>
           Depth (K) = Depth (Parent (K)) + 1
           and then Products (K) = Products (Parent (K)) + 1 + Joints (K)
           and then Budget (K) = Budget (Parent (K))
             + Units_Per_Product * (1 + Joints (K)));
         Depth (B) := Depth (Parent (B)) + 1;
         Products (B) := Products (Parent (B)) + 1 + Joints (B);
         Budget (B) := Budget (Parent (B)) + Units_Per_Product * (1 + Joints (B));
      end loop;
   end Propagate;
   procedure Propagate_Errors
     (Parent : Parent_Array; Joints : Count_Array;
      Local_Error : Error_Array; Error : out Error_Array)
   is
      Depth : Depth_Array (Parent'Range);
      Products : Product_Array (Parent'Range);
      Budget : Budget_Array (Parent'Range);
   begin
      Propagate (Parent, Joints, Depth, Products, Budget);
      pragma Assert (for all B in Parent'Range =>
        Products (B) <= (Max_Joints + 1) * Depth (B)
        and then Budget (B) <= Units_Per_Product * (Max_Joints + 1) * B);
      Error := [others => 0.0];
      for B in 1 .. Parent'Last loop
         pragma Loop_Invariant (Error (0) = 0.0);
         pragma Loop_Invariant (for all K in 0 .. B - 1 => Error (K) >= 0.0
           and then Error (K) <= To_Real (Budget (K)) * Unit_Roundoff);
         pragma Loop_Invariant (for all K in 1 .. B - 1 => Error (K) = Error (Parent (K)) + Local_Error (K));
         Error (B) := Error (Parent (B)) + Local_Error (B);
      end loop;
   end Propagate_Errors;
   procedure Bound_Accumulated_Error
     (Parent : Parent_Array; Joints : Count_Array;
      Actual_Error, Factor_Error : Error_Array;
      Products : out Product_Array; Accumulated_Factor_Error : out Error_Array)
   is
      Depth : Depth_Array (Parent'Range);
      Budget : Budget_Array (Parent'Range);
   begin
      Propagate (Parent, Joints, Depth, Products, Budget);
      pragma Assert (for all B in Parent'Range => Products (B) <= (Max_Joints + 1) * Depth (B));
      Accumulated_Factor_Error := [others => 0.0];
      for B in 1 .. Parent'Last loop
         pragma Loop_Invariant (Accumulated_Factor_Error (0) = 0.0);
         pragma Loop_Invariant (for all K in 0 .. B - 1 =>
           Accumulated_Factor_Error (K) >= 0.0
           and then Actual_Error (K) <= To_Real (Budget (K)) * Unit_Roundoff
             + Accumulated_Factor_Error (K));
         pragma Loop_Invariant (for all K in 1 .. B - 1 =>
           Accumulated_Factor_Error (K) = Accumulated_Factor_Error (Parent (K)) + Factor_Error (K));
         Accumulated_Factor_Error (B) := Accumulated_Factor_Error (Parent (B)) + Factor_Error (B);
      end loop;
   end Bound_Accumulated_Error;
end MJ.Tree_Error_Budgets;
