with MJ.Types; use MJ.Types;
with MJ.BLAS;
with MJ.Matrix_Types; use MJ.Matrix_Types;
with MJ.Matrices; use MJ.Matrices;
with System.Machine_Code;
package body Bench_Ada is
   procedure Barrier (A, B, U, V, D, R, Ind : System.Address) with Inline_Always;
   procedure Barrier (A, B, U, V, D, R, Ind : System.Address) is
   begin
      System.Machine_Code.Asm ("", Inputs => (
        System.Address'Asm_Input ("r", A), System.Address'Asm_Input ("r", B),
        System.Address'Asm_Input ("r", U), System.Address'Asm_Input ("r", V),
        System.Address'Asm_Input ("r", D), System.Address'Asm_Input ("r", R),
        System.Address'Asm_Input ("r", Ind)), Clobber => "memory", Volatile => True);
   end Barrier;
   function Run_1 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_1 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               RR3 := Copy9 (AA3);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_1;

   function Run_2 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_2 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               MulMatVec3 (RV3, AA3, VV3);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_2;

   function Run_3 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_3 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               MulMatTVec3 (RV3, AA3, VV3);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_3;

   function Run_4 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_4 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               RR3 := MulMatMat3 (AA3, BB3);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_4;

   function Run_5 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_5 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               RR3 := MulMatTMat3 (AA3, BB3);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_5;

   function Run_6 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_6 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               RR3 := MulMatMatT3 (AA3, BB3);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_6;

   function Run_7 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_7 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               MulMatVec (RV_N, AA, VV);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_7;

   function Run_8 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_8 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               MulMatTVec (RV_M, AA, UU);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_8;

   function Run_9 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_9 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               Acc := Acc + MulVecMatVec (UU, ASquare, VSquare);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_9;

   function Run_10 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_10 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               Transpose (RT, AA);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_10;

   function Run_11 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_11 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               Symmetrize (RS, ASquare);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_11;

   function Run_12 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_12 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               Eye (RS);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_12;

   function Run_13 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_13 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               CopyRows (RC, AA, II);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_13;

   function Run_14 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_14 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               MulMatMat (RP, AA, BB);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_14;

   function Run_15 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_15 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               MulMatTMat (RTP, AA, BE);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_15;

   function Run_16 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_16 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               MulMatMatT (RP, AA, BT);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_16;

   function Run_17 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_17 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               SqrMatTD (RG, AA);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_17;

   function Run_18 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_18 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               SqrMatTD (RG, AA, DD);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_18;

   function Run_19 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_19 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               SqrMatTD (RG, AA, DD, False);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_19;

   function Run_20 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double with No_Inline;
   function Run_20 (NR, NC, NK, Reps : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      N : constant Natural := Natural (NR); M : constant Natural := Natural (NC); P : constant Natural := Natural (NK);
      AA : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => A;
      ASquare : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => A;
      VSquare : Real_Array (0 .. N-1) with Import, Address => V;
      BB : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => B;
      BT : Matrix (0 .. P-1, 0 .. M-1) with Import, Address => B;
      BE : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => B;
      RP : Matrix (0 .. N-1, 0 .. P-1) with Import, Address => R;
      RTP : Matrix (0 .. M-1, 0 .. P-1) with Import, Address => R;
      RT : Matrix (0 .. M-1, 0 .. N-1) with Import, Address => R;
      RS : Matrix (0 .. N-1, 0 .. N-1) with Import, Address => R;
      RC : Matrix (0 .. N-1, 0 .. M-1) with Import, Address => R;
      RG : Matrix (0 .. M-1, 0 .. M-1) with Import, Address => R;
      UU : Real_Array (0 .. N-1) with Import, Address => U;
      VV : Real_Array (0 .. M-1) with Import, Address => V;
      DD : Real_Array (0 .. N-1) with Import, Address => D;
      II : Int_Array (0 .. N/2-1) with Import, Address => Ind;
      RV_N : Real_Array (0 .. N-1) with Import, Address => R;
      RV_M : Real_Array (0 .. M-1) with Import, Address => R;
      AA3 : Matrix_3 with Import, Address => A;
      BB3 : Matrix_3 with Import, Address => B;
      RR3 : Matrix_3 with Import, Address => R;
      VV3 : MJ.BLAS.Vector_3 with Import, Address => V;
      RV3 : MJ.BLAS.Vector_3 with Import, Address => R;
      Acc : Real := 0.0;
   begin
            for I in 1 .. Integer (Reps) loop
               Barrier (A, B, U, V, D, R, Ind);
               SqrMatTD (RG, AA, Upper => False);
               Barrier (A, B, U, V, D, R, Ind);
            end loop;
      return Interfaces.C.double (Acc);
   end Run_20;
   function Run (Op, NR, NC, NK, Reps, Pattern : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double is
      pragma Unreferenced (Pattern);
   begin
      case Op is
         when 1 => return Run_1 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 2 => return Run_2 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 3 => return Run_3 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 4 => return Run_4 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 5 => return Run_5 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 6 => return Run_6 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 7 => return Run_7 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 8 => return Run_8 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 9 => return Run_9 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 10 => return Run_10 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 11 => return Run_11 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 12 => return Run_12 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 13 => return Run_13 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 14 => return Run_14 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 15 => return Run_15 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 16 => return Run_16 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 17 => return Run_17 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 18 => return Run_18 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 19 => return Run_19 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when 20 => return Run_20 (NR, NC, NK, Reps, A, B, U, V, D, R, Ind);
         when others => return 0.0;
      end case;
   end Run;
end Bench_Ada;
