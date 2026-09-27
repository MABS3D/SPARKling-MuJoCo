with Ada.Numerics.Big_Numbers.Big_Reals;
--  Ghost-only accounting for the products in the pose traversal.
--  The numerical meaning of Units_Per_Product is established separately in
--  numerical/tree-error.md and the Gappa/SMT certificates, not assumed here.
package MJ.Tree_Error_Budgets with SPARK_Mode, Ghost => Static is
   Max_Bodies : constant := 4_096;
   Max_Joints : constant := 256;
   Units_Per_Product : constant := 512;
   subtype Body_Index is Natural range 0 .. Max_Bodies - 1;
   subtype Joint_Count is Natural range 0 .. Max_Joints;
   subtype Product_Count is Natural range 0 .. (Max_Bodies - 1) * (Max_Joints + 1);
   subtype Error_Units is Natural range 0 .. Units_Per_Product * Product_Count'Last;
   type Parent_Array is array (Natural range <>) of Body_Index;
   type Count_Array is array (Natural range <>) of Joint_Count;
   type Depth_Array is array (Natural range <>) of Body_Index;
   type Product_Array is array (Natural range <>) of Product_Count;
   type Budget_Array is array (Natural range <>) of Error_Units;

   procedure Propagate
     (Parent : Parent_Array; Joints : Count_Array;
      Depth : out Depth_Array; Products : out Product_Array; Budget : out Budget_Array)
     with Global => null,
     Pre => Parent'First = 0 and then Parent'Length in 1 .. Max_Bodies
       and then Joints'First = 0 and then Joints'Last = Parent'Last
       and then Depth'First = 0 and then Depth'Last = Parent'Last
       and then Products'First = 0 and then Products'Last = Parent'Last
       and then Budget'First = 0 and then Budget'Last = Parent'Last
       and then Parent (0) = 0 and then Joints (0) = 0
       and then (for all B in 1 .. Parent'Last => Parent (B) < B),
     Post => Depth (0) = 0 and then Products (0) = 0 and then Budget (0) = 0
       and then (for all B in Parent'Range => Depth (B) <= B
         and then Products (B) <= (Max_Joints + 1) * Depth (B)
         and then Budget (B) = Units_Per_Product * Products (B))
       and then (for all B in 1 .. Parent'Last =>
         Depth (B) = Depth (Parent (B)) + 1
         and then Products (B) = Products (Parent (B)) + 1 + Joints (B)
         and then Budget (B) = Budget (Parent (B))
           + Units_Per_Product * (1 + Joints (B)));
   use Ada.Numerics.Big_Numbers.Big_Reals;
   function Unit_Roundoff return Valid_Big_Real is (1.0 / 9007199254740992.0);
   type Error_Array is array (Natural range <>) of Valid_Big_Real;
   procedure Propagate_Errors
     (Parent : Parent_Array; Joints : Count_Array;
      Local_Error : Error_Array; Error : out Error_Array)
     with Global => null,
     Pre => Parent'First = 0 and then Parent'Length in 1 .. Max_Bodies
       and then Joints'First = 0 and then Joints'Last = Parent'Last
       and then Local_Error'First = 0 and then Local_Error'Last = Parent'Last
       and then Error'First = 0 and then Error'Last = Parent'Last
       and then Parent (0) = 0 and then Joints (0) = 0
       and then (for all B in 1 .. Parent'Last => Parent (B) < B)
       and then (for all B in Local_Error'Range =>
         Local_Error (B) >= 0.0
         and then Local_Error (B) <= To_Real (Units_Per_Product * (1 + Joints (B))) * Unit_Roundoff),
     Post => Error (0) = 0.0
       and then (for all B in Parent'Range => Error (B) >= 0.0
         and then Error (B) <= To_Real (Units_Per_Product * (Max_Joints + 1) * B) * Unit_Roundoff)
       and then (for all B in 1 .. Parent'Last => Error (B) = Error (Parent (B)) + Local_Error (B));
   --  Unlike Propagate_Errors, this theorem bounds an independently supplied
   --  error sequence satisfying the local inequality; it does not construct
   --  the error by assuming equality with its upper bound.
   procedure Bound_Accumulated_Error
     (Parent : Parent_Array; Joints : Count_Array;
      Actual_Error, Factor_Error : Error_Array;
      Products : out Product_Array; Accumulated_Factor_Error : out Error_Array)
     with Global => null,
     Pre => Parent'First = 0 and then Parent'Length in 1 .. Max_Bodies
       and then Joints'First = 0 and then Joints'Last = Parent'Last
       and then Actual_Error'First = 0 and then Actual_Error'Last = Parent'Last
       and then Factor_Error'First = 0 and then Factor_Error'Last = Parent'Last
       and then Products'First = 0 and then Products'Last = Parent'Last
       and then Accumulated_Factor_Error'First = 0
       and then Accumulated_Factor_Error'Last = Parent'Last
       and then Parent (0) = 0 and then Joints (0) = 0
       and then Actual_Error (0) = 0.0
       and then (for all B in Parent'Range =>
         Actual_Error (B) >= 0.0 and then Factor_Error (B) >= 0.0)
       and then (for all B in 1 .. Parent'Last => Parent (B) < B
         and then Actual_Error (B) <= Actual_Error (Parent (B))
           + To_Real (Units_Per_Product * (1 + Joints (B))) * Unit_Roundoff
           + Factor_Error (B)),
     Post => Products (0) = 0 and then Accumulated_Factor_Error (0) = 0.0
       and then (for all B in Parent'Range =>
         Accumulated_Factor_Error (B) >= 0.0
         and then Actual_Error (B) <= To_Real (Units_Per_Product * Products (B)) * Unit_Roundoff
           + Accumulated_Factor_Error (B))
       and then (for all B in 1 .. Parent'Last =>
         Products (B) = Products (Parent (B)) + 1 + Joints (B)
         and then Accumulated_Factor_Error (B) =
           Accumulated_Factor_Error (Parent (B)) + Factor_Error (B));
end MJ.Tree_Error_Budgets;
