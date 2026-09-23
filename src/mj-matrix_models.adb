package body MJ.Matrix_Models with SPARK_Mode is
   procedure Unfold_Sequential (A, B : Real_Array; Count : Size_Type) is null;
   procedure Unfold_Bilinear (A, B : Real_Array; Count : Size_Type) is null;
   procedure Unfold_Weighted (A, B, D : Real_Array; Count : Size_Type) is null;
end MJ.Matrix_Models;
