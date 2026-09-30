with MJ.Types; use MJ.Types;
with MJ.Muscle_Kernels; use MJ.Muscle_Kernels;
with MJ.Muscle_Actuation; use MJ.Muscle_Actuation;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
procedure Muscle_Probe is
   package FIO is new Ada.Text_IO.Float_IO (Real);
   Op, Flag : Integer;
   L,V,C,A,H,Acc,X,Y,W,Z : Real;
   R : Length_Range;
   GP,BP : Parameters;
   DP : Dynamics_Parameters;
   P : Configuration;
   S : State;
   E : Evaluation;
   Status : Step_Status;
   procedure Read_Range (R : out Length_Range) is
   begin FIO.Get(R(0)); FIO.Get(R(1)); end;
   procedure Read_P (P : out Parameters) is
   begin for I in P'Range loop FIO.Get(P(I)); end loop; end;
   procedure Read_D (D : out Dynamics_Parameters) is
   begin for I in D'Range loop FIO.Get(D(I)); end loop; end;
   procedure Put (N : Real) is
   begin FIO.Put(N,Fore=>1,Aft=>17,Exp=>3); Put(" "); end;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get(Op);
      case Op is
         when 1 =>
            FIO.Get(L); FIO.Get(X); FIO.Get(Y); Put(Length_Gain(L,X,Y));
         when 2 =>
            FIO.Get(L); FIO.Get(V); FIO.Get(Acc); Read_Range(R); Read_P(GP);
            Put(Gain(L,V,R,Acc,GP));
         when 3 =>
            FIO.Get(L); FIO.Get(Acc); Read_Range(R); Read_P(BP);
            Put(Bias(L,R,Acc,BP));
         when 4 =>
            FIO.Get(X); FIO.Get(Y); FIO.Get(Z); FIO.Get(W); Put(Timescale(X,Y,Z,W));
         when 5 =>
            FIO.Get(C); FIO.Get(A); Read_D(DP); Put(MJ.Muscle_Kernels.Dynamics(C,A,DP));
         when 6 =>
            FIO.Get(L); FIO.Get(V); FIO.Get(Acc); FIO.Get(C); FIO.Get(A); FIO.Get(H);
            Read_Range(R); Read_P(GP); Read_P(BP); Read_D(DP);
            P := (Gain_Parameters=>GP, Bias_Parameters=>BP, Dynamics=>DP,
              Range_Of_Length=>R, Acc0=>Acc, others=><>);
            Ada.Integer_Text_IO.Get(Flag); P.Control_Limited := Flag/=0;
            Ada.Integer_Text_IO.Get(Flag); P.Activation_Limited := Flag/=0;
            Ada.Integer_Text_IO.Get(Flag); P.Force_Limited := Flag/=0;
            Ada.Integer_Text_IO.Get(Flag); P.Actearly := Flag/=0;
            Read_Range(P.Control_Range); Read_Range(P.Activation_Range); Read_Range(P.Force_Range);
            S.Activation := A;
            Step(P,S,C,L,V,H,E,Status);
            Put(Real(Step_Status'Pos(Status))); Put(S.Activation);
            Put(E.Gain); Put(E.Bias); Put(E.Derivative); Put(E.Next_Activation); Put(E.Force);
         when 7 => FIO.Get(X); Put(Sigmoid(X));
         when others => raise Program_Error;
      end case;
      New_Line;
      Skip_Line;
   end loop;
end Muscle_Probe;
