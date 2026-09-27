with MJ.Types; use MJ.Types;
with MJ.Poses; use MJ.Poses;
with MJ.Quaternions;
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
      AP : Vector_3 with Import, Address => A;
      AQ : Quaternion with Import, Address => A + 24;
      BP : Vector_3 with Import, Address => B;
      BQ : Quaternion with Import, Address => B + 24;
      VV : Vector_3 with Import, Address => V;
      RR : Real_Array (0 .. 37) with Import, Address => R;
      P : Vector_3;
      Q : Quaternion;
      Pos : Natural := 0;
      procedure Put (Pose : Boolean := True) is
      begin
         for E of P loop RR (Pos) := E; Pos := Pos + 1; end loop;
         if Pose then
            for E of Q loop RR (Pos) := E; Pos := Pos + 1; end loop;
         end if;
      end Put;
   begin
      Compose (P, Q, AP, AQ, BP, BQ); Put;
      P := AP; Q := AQ; Compose (P, Q, BP, BQ); Put;
      Inverse (P, Q, AP, AQ); Put;
      P := AP; Q := AQ; Inverse (P, Q); Put;
      Transform (P, AP, AQ, VV); Put (False);
      P := VV; Transform (P, AP, AQ); Put (False);
      Q := MJ.Quaternions.Product (AQ, BQ);
      for E of Q loop RR (Pos) := E; Pos := Pos + 1; end loop;
   end Evaluate;
   procedure Run_7 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) with No_Inline;
   procedure Run_7 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) is
      AP : Vector_3 renames A.Position;
      AQ : Quaternion renames A.Orientation;
      BP : Vector_3 renames B.Position;
      BQ : Quaternion renames B.Orientation;
      VV : Vector_3 renames V.all;
      K : Interfaces.C.int := 0;
   begin
      while K < Reps loop
         declare
            Slot : constant System.Address := R + Storage_Offset (K) * 56;
            RP : Vector_3 with Import, Address => Slot;
            RQ : Quaternion with Import, Address => Slot + 24;
         begin
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
            RQ := MJ.Quaternions.Product (AQ, BQ);
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
         end;
         K := K + 1;
      end loop;
   end Run_7;
   procedure Run_1 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) with No_Inline;
   procedure Run_1 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) is
      AP : Vector_3 renames A.Position;
      AQ : Quaternion renames A.Orientation;
      BP : Vector_3 renames B.Position;
      BQ : Quaternion renames B.Orientation;
      VV : Vector_3 renames V.all;
      K : Interfaces.C.int := 0;
   begin
      while K < Reps loop
         declare
            Slot : constant System.Address := R + Storage_Offset (K) * 56;
            RP : Vector_3 with Import, Address => Slot;
            RQ : Quaternion with Import, Address => Slot + 24;
         begin
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
            Compose (RP, RQ, AP, AQ, BP, BQ);
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
         end;
         K := K + 1;
      end loop;
   end Run_1;
   procedure Run_2 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) with No_Inline;
   procedure Run_2 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) is
      AP : Vector_3 renames A.Position;
      AQ : Quaternion renames A.Orientation;
      BP : Vector_3 renames B.Position;
      BQ : Quaternion renames B.Orientation;
      VV : Vector_3 renames V.all;
      K : Interfaces.C.int := 0;
   begin
      while K < Reps loop
         declare
            Slot : constant System.Address := R + Storage_Offset (K) * 56;
            RP : Vector_3 with Import, Address => Slot;
            RQ : Quaternion with Import, Address => Slot + 24;
         begin
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
            Compose (RP, RQ, BP, BQ);
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
         end;
         K := K + 1;
      end loop;
   end Run_2;
   procedure Run_3 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) with No_Inline;
   procedure Run_3 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) is
      AP : Vector_3 renames A.Position;
      AQ : Quaternion renames A.Orientation;
      BP : Vector_3 renames B.Position;
      BQ : Quaternion renames B.Orientation;
      VV : Vector_3 renames V.all;
      K : Interfaces.C.int := 0;
   begin
      while K < Reps loop
         declare
            Slot : constant System.Address := R + Storage_Offset (K) * 56;
            RP : Vector_3 with Import, Address => Slot;
            RQ : Quaternion with Import, Address => Slot + 24;
         begin
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
            Inverse (RP, RQ, AP, AQ);
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
         end;
         K := K + 1;
      end loop;
   end Run_3;
   procedure Run_4 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) with No_Inline;
   procedure Run_4 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) is
      AP : Vector_3 renames A.Position;
      AQ : Quaternion renames A.Orientation;
      BP : Vector_3 renames B.Position;
      BQ : Quaternion renames B.Orientation;
      VV : Vector_3 renames V.all;
      K : Interfaces.C.int := 0;
   begin
      while K < Reps loop
         declare
            Slot : constant System.Address := R + Storage_Offset (K) * 56;
            RP : Vector_3 with Import, Address => Slot;
            RQ : Quaternion with Import, Address => Slot + 24;
         begin
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
            Inverse (RP, RQ);
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
         end;
         K := K + 1;
      end loop;
   end Run_4;
   procedure Run_5 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) with No_Inline;
   procedure Run_5 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) is
      AP : Vector_3 renames A.Position;
      AQ : Quaternion renames A.Orientation;
      BP : Vector_3 renames B.Position;
      BQ : Quaternion renames B.Orientation;
      VV : Vector_3 renames V.all;
      K : Interfaces.C.int := 0;
   begin
      while K < Reps loop
         declare
            Slot : constant System.Address := R + Storage_Offset (K) * 56;
            RP : Vector_3 with Import, Address => Slot;
            RQ : Quaternion with Import, Address => Slot + 24;
         begin
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
            Transform (RP, AP, AQ, VV);
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
         end;
         K := K + 1;
      end loop;
   end Run_5;
   procedure Run_6 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) with No_Inline;
   procedure Run_6 (Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address) is
      AP : Vector_3 renames A.Position;
      AQ : Quaternion renames A.Orientation;
      BP : Vector_3 renames B.Position;
      BQ : Quaternion renames B.Orientation;
      VV : Vector_3 renames V.all;
      K : Interfaces.C.int := 0;
   begin
      while K < Reps loop
         declare
            Slot : constant System.Address := R + Storage_Offset (K) * 56;
            RP : Vector_3 with Import, Address => Slot;
            RQ : Quaternion with Import, Address => Slot + 24;
         begin
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
            Transform (RP, AP, AQ);
            Barrier (A.all'Address, B.all'Address, V.all'Address, Slot);
         end;
         K := K + 1;
      end loop;
   end Run_6;
   function Run (Op, Reps : Interfaces.C.int; A, B : Pose_Pointer; V : Vector_Pointer; R : System.Address)
     return Interfaces.C.double is
   begin
      case Op is
         when 1 => Run_1 (Reps, A, B, V, R);
         when 2 => Run_2 (Reps, A, B, V, R);
         when 3 => Run_3 (Reps, A, B, V, R);
         when 4 => Run_4 (Reps, A, B, V, R);
         when 5 => Run_5 (Reps, A, B, V, R);
         when 6 => Run_6 (Reps, A, B, V, R);
         when 7 => Run_7 (Reps, A, B, V, R);
         when others => null;
      end case;
      return 0.0;
   end Run;
end Adapter;
