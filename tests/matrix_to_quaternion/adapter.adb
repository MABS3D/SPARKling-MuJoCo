with MJ.Quaternions; use MJ.Quaternions;
with System.Machine_Code;
package body Adapter is
   use type Interfaces.C.int;
   procedure Barrier (A, R : System.Address) with Inline_Always;
   procedure Barrier (A, R : System.Address) is
   begin
      System.Machine_Code.Asm ("", Inputs => (
        System.Address'Asm_Input ("r", A), System.Address'Asm_Input ("r", R)),
        Clobber => "memory", Volatile => True);
   end Barrier;
   procedure Evaluate (A, R : System.Address; Status : out Interfaces.C.int) is
      Input : Matrix_3 with Import, Address => A;
      Output : Quaternion with Import, Address => R;
      Result : Conversion_Status;
   begin
      From_Matrix (Output, Input, Result);
      Status := Conversion_Status'Pos (Result);
   end Evaluate;
   procedure Run (Reps : Interfaces.C.int; A, R : System.Address) is
      type Matrices is array (0 .. 63) of Matrix_3;
      type Quaternions is array (0 .. 63) of Quaternion;
      Input : Matrices with Import, Address => A;
      Output : Quaternions with Import, Address => R;
      Result : Conversion_Status;
      K : Interfaces.C.int := 0;
   begin
      while K < Reps loop
         Barrier (A, R);
         for I in Input'Range loop
            From_Matrix (Output (I), Input (I), Result);
            if Result /= Success then
               raise Program_Error with "unexpected conversion rejection";
            end if;
         end loop;
         Barrier (A, R);
         K := K + 1;
      end loop;
   end Run;
end Adapter;
