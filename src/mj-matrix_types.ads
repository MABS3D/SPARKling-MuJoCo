--  Row-major, zero-based dense storage. Dimensions are independent, including zero.
with MJ.Types; use MJ.Types;
with MJ.BLAS;
package MJ.Matrix_Types with SPARK_Mode is
   type Matrix is array (Natural range <>, Natural range <>) of Real;
   subtype Matrix_3 is Matrix (0 .. 2, 0 .. 2);

   function Valid (A : Matrix) return Boolean is
     (A'First (1) = 0 and then A'First (2) = 0
      and then A'Length (1) <= Max_Size and then A'Length (2) <= Max_Size
      and then (A'Length (1) = 0 or else A'Length (2) <= Max_Size / A'Length (1)))
     with Global => null;
   function In_Tier0 (A : Matrix) return Boolean is
     (for all I in A'Range (1) => (for all J in A'Range (2) => A (I, J) in Tier0_Real))
     with Global => null;
   function In_Tier1 (A : Matrix) return Boolean is
     (for all I in A'Range (1) => (for all J in A'Range (2) => A (I, J) in Tier1_Real))
     with Global => null;
   function In_Tier2 (A : Matrix) return Boolean is
     (for all I in A'Range (1) => (for all J in A'Range (2) => A (I, J) in Tier2_Real))
     with Global => null;

   function Row (A : Matrix; I : Natural) return Real_Array with
     Global => null, Pre => Valid (A) and then I in A'Range (1),
     Post => Row'Result'First = 0 and then Row'Result'Last = A'Length (2) - 1
       and then (for all J in Row'Result'Range => Row'Result (J) = A (I, J))
       and then (if In_Tier0 (A) then MJ.BLAS.In_Tier0 (Row'Result));
   function Column (A : Matrix; J : Natural) return Real_Array with
     Global => null, Pre => Valid (A) and then J in A'Range (2),
     Post => Column'Result'First = 0 and then Column'Result'Last = A'Length (1) - 1
       and then (for all I in Column'Result'Range => Column'Result (I) = A (I, J))
       and then (if In_Tier0 (A) then MJ.BLAS.In_Tier0 (Column'Result));
end MJ.Matrix_Types;
