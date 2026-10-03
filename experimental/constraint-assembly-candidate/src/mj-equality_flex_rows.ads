--  Copyright 2021 DeepMind Technologies Limited.
--  Licensed under the Apache License, Version 2.0; see repository LICENSE.
--  Modified: sparse FLEX equality row assembly, MuJoCo 3.14.0.
with MJ.Types; use MJ.Types;
with MJ.Constraint_Assembly;
package MJ.Equality_Flex_Rows with SPARK_Mode is
   package CA renames MJ.Constraint_Assembly;
   use type CA.Result;
   use type CA.Storage;
   use type CA.Row;
   procedure Append
     (B : in out CA.Storage; Eq_Id : Natural; Chain : CA.Column_Array;
      Values : CA.Value_Array; Length, Rest : Nonneg_Tier0;
      Status : out CA.Result) with
     Global => null,
     Pre => CA.Valid (B) and then CA.Valid_Chain (Chain, B.Dofs)
       and then Values'First = 1 and then Values'Length = Chain'Length,
     Post => (Static => CA.Valid (B) and then B.Dofs = B.Dofs'Old
       and then Status = (if Chain'Length = 0 then CA.Skipped
         elsif not CA.Fits (B'Old, 1, Chain'Length) then CA.Capacity_Limit
         else CA.Success)
       and then (if Status /= CA.Success then B = B'Old else
         B.Rows = B.Rows'Old + 1 and then B.Used = B.Used'Old + Chain'Length
         and then B.Ne = B.Ne'Old + 1 and then B.Nf = B.Nf'Old and then B.Nl = B.Nl'Old
         and then CA.Row_Is (B.Descriptors (B.Rows), B.Used'Old, Chain'Length,
           (Length-Rest, 0.0), 0.0, CA.Equality, Eq_Id)
         and then (for all K in Chain'Range =>
           B.Columns (B.Used'Old + K) = Chain (K))
         and then (for all K in Chain'Range =>
           B.Values (B.Used'Old + K) = Values (K))
         and then (for all R in B.Descriptors'Range =>
           (if R /= B.Rows then B.Descriptors (R) = B.Descriptors'Old (R)))
         and then (for all K in B.Values'Range =>
           (if K <= B.Used'Old or else K > B.Used then
             B.Values (K) = B.Values'Old (K) and then B.Columns (K) = B.Columns'Old (K)))));
end MJ.Equality_Flex_Rows;
