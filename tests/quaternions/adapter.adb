with MJ.Types; use MJ.Types;
with MJ.Quaternions; use MJ.Quaternions;
with System.Machine_Code;
package body Adapter is
   use type Interfaces.C.int;
   procedure Barrier (A, B, V, R : System.Address) with Inline_Always;
   procedure Barrier (A, B, V, R : System.Address) is
   begin
      System.Machine_Code.Asm ("", Inputs => (
        System.Address'Asm_Input ("r", A), System.Address'Asm_Input ("r", B),
        System.Address'Asm_Input ("r", V), System.Address'Asm_Input ("r", R)),
        Clobber => "memory", Volatile => True);
   end Barrier;
   procedure Evaluate (A, B, V, R : System.Address) is
      QA : Quaternion with Import, Address => A;
      QB : Quaternion with Import, Address => B;
      VV : Vector_3 with Import, Address => V;
      RR : Real_Array (0 .. 37) with Import, Address => R;
      T : Quaternion;
      RV : Vector_3;
      RM : Matrix_3;
      L : Nonnegative_Real;
      Pos : Natural := 0;
      procedure Put (Value : Real) is
      begin
         RR (Pos) := Value;
         Pos := Pos + 1;
      end Put;
      procedure Put (Value : Quaternion) is
      begin
         for E of Value loop Put (E); end loop;
      end Put;
   begin
      Set_Identity (T); Put (T);
      Conjugate (T, QA); Put (T);
      T := QA; Conjugate (T); Put (T);
      Multiply (T, QA, QB); Put (T);
      T := QA; Multiply (T, QB); Put (T);
      Put (Norm (QA));
      T := QA; Normalize (T, L); Put (T); Put (L);
      Rotate (RV, QA, VV); for E of RV loop Put (E); end loop;
      To_Matrix (RM, QA);
      for I in Axis loop for J in Axis loop Put (RM (I, J)); end loop; end loop;
   end Evaluate;
   function Run (Op, Reps : Interfaces.C.int; A, B, V, R : System.Address)
     return Interfaces.C.double is
      QA : Quaternion with Import, Address => A;
      QB : Quaternion with Import, Address => B;
      VV : Vector_3 with Import, Address => V;
      RQ : Quaternion with Import, Address => R;
      RV : Vector_3 with Import, Address => R;
      RM : Matrix_3 with Import, Address => R;
      Acc : Real := 0.0;
      K : Interfaces.C.int := 0;
      L : Nonnegative_Real;
   begin
      case Op is
         when 1 =>
            while K < Reps loop
               Barrier (A, B, V, R);
               Set_Identity (RQ);
               Barrier (A, B, V, R);
               K := K + 1;
            end loop;
         when 2 =>
            while K < Reps loop
               Barrier (A, B, V, R);
               Conjugate (RQ, QA);
               Barrier (A, B, V, R);
               K := K + 1;
            end loop;
         when 3 =>
            while K < Reps loop
               Barrier (A, B, V, R);
               RQ := QA; Conjugate (RQ);
               Barrier (A, B, V, R);
               K := K + 1;
            end loop;
         when 4 =>
            while K < Reps loop
               Barrier (A, B, V, R);
               Multiply (RQ, QA, QB);
               Barrier (A, B, V, R);
               K := K + 1;
            end loop;
         when 5 =>
            while K < Reps loop
               Barrier (A, B, V, R);
               RQ := QA; Multiply (RQ, QB);
               Barrier (A, B, V, R);
               K := K + 1;
            end loop;
         when 6 =>
            while K < Reps loop
               Barrier (A, B, V, R);
               Acc := Acc + Norm (QA);
               Barrier (A, B, V, R);
               K := K + 1;
            end loop;
         when 7 =>
            while K < Reps loop
               Barrier (A, B, V, R);
               RQ := QA; Normalize (RQ, L); Acc := Acc + L;
               Barrier (A, B, V, R);
               K := K + 1;
            end loop;
         when 8 =>
            while K < Reps loop
               Barrier (A, B, V, R);
               Rotate (RV, QA, VV);
               Barrier (A, B, V, R);
               K := K + 1;
            end loop;
         when 9 =>
            while K < Reps loop
               Barrier (A, B, V, R);
               To_Matrix (RM, QA);
               Barrier (A, B, V, R);
               K := K + 1;
            end loop;
         when others => null;
      end case;
      return Interfaces.C.double (Acc);
   end Run;
end Adapter;
