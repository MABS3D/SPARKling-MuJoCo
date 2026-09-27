with MJ.Types; use MJ.Types;
with MJ.Rotations; use MJ.Rotations;
with System.Machine_Code;
with System.Storage_Elements; use System.Storage_Elements;
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
      QQ : Quaternion with Import, Address => A;
      MM : Matrix_3 with Import, Address => B;
      VV : Vector_3 with Import, Address => V;
      RR : Real_Array (0 .. 23) with Import, Address => R;
      RV : Vector_3;
      Pos : Natural := 0;
      procedure Put is
      begin
         for E of RV loop
            RR (Pos) := E;
            Pos := Pos + 1;
         end loop;
      end Put;
   begin
      Rotate (RV, QQ, VV); Put;
      RV := VV; Rotate (RV, QQ); Put;
      Rotate_Conjugate (RV, QQ, VV); Put;
      RV := VV; Rotate_Conjugate (RV, QQ); Put;
      Rotate (RV, MM, VV); Put;
      RV := VV; Rotate (RV, MM); Put;
      Rotate_Transpose (RV, MM, VV); Put;
      RV := VV; Rotate_Transpose (RV, MM); Put;
   end Evaluate;
   function Run (Op, Reps : Interfaces.C.int; A, B, V, R : System.Address)
     return Interfaces.C.double is
      QQ : Quaternion with Import, Address => A;
      MM : Matrix_3 with Import, Address => B;
      VV : Vector_3 with Import, Address => V;
      K : Interfaces.C.int := 0;
   begin
      case Op is
         when 1 =>
            while K < Reps loop
               declare
                  Slot : constant System.Address := R + Storage_Offset (K) * 24;
                  RV : Vector_3 with Import, Address => Slot;
               begin
                  Barrier (A, B, V, Slot);
                  Rotate (RV, QQ, VV);
                  Barrier (A, B, V, Slot);
               end;
               K := K + 1;
            end loop;
         when 2 =>
            while K < Reps loop
               declare
                  Slot : constant System.Address := R + Storage_Offset (K) * 24;
                  RV : Vector_3 with Import, Address => Slot;
               begin
                  Barrier (A, B, V, Slot);
                  Rotate (RV, QQ);
                  Barrier (A, B, V, Slot);
               end;
               K := K + 1;
            end loop;
         when 3 =>
            while K < Reps loop
               declare
                  Slot : constant System.Address := R + Storage_Offset (K) * 24;
                  RV : Vector_3 with Import, Address => Slot;
               begin
                  Barrier (A, B, V, Slot);
                  Rotate_Conjugate (RV, QQ, VV);
                  Barrier (A, B, V, Slot);
               end;
               K := K + 1;
            end loop;
         when 4 =>
            while K < Reps loop
               declare
                  Slot : constant System.Address := R + Storage_Offset (K) * 24;
                  RV : Vector_3 with Import, Address => Slot;
               begin
                  Barrier (A, B, V, Slot);
                  Rotate_Conjugate (RV, QQ);
                  Barrier (A, B, V, Slot);
               end;
               K := K + 1;
            end loop;
         when 5 =>
            while K < Reps loop
               declare
                  Slot : constant System.Address := R + Storage_Offset (K) * 24;
                  RV : Vector_3 with Import, Address => Slot;
               begin
                  Barrier (A, B, V, Slot);
                  Rotate (RV, MM, VV);
                  Barrier (A, B, V, Slot);
               end;
               K := K + 1;
            end loop;
         when 6 =>
            while K < Reps loop
               declare
                  Slot : constant System.Address := R + Storage_Offset (K) * 24;
                  RV : Vector_3 with Import, Address => Slot;
               begin
                  Barrier (A, B, V, Slot);
                  Rotate (RV, MM);
                  Barrier (A, B, V, Slot);
               end;
               K := K + 1;
            end loop;
         when 7 =>
            while K < Reps loop
               declare
                  Slot : constant System.Address := R + Storage_Offset (K) * 24;
                  RV : Vector_3 with Import, Address => Slot;
               begin
                  Barrier (A, B, V, Slot);
                  Rotate_Transpose (RV, MM, VV);
                  Barrier (A, B, V, Slot);
               end;
               K := K + 1;
            end loop;
         when 8 =>
            while K < Reps loop
               declare
                  Slot : constant System.Address := R + Storage_Offset (K) * 24;
                  RV : Vector_3 with Import, Address => Slot;
               begin
                  Barrier (A, B, V, Slot);
                  Rotate_Transpose (RV, MM);
                  Barrier (A, B, V, Slot);
               end;
               K := K + 1;
            end loop;
         when others => null;
      end case;
      return 0.0;
   end Run;
end Adapter;
