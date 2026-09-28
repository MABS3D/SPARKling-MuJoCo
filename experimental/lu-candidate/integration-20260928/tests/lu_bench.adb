with Ada.Command_Line;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.LU; use MJ.LU;
procedure LU_Bench is
   Sparse : constant Boolean := Ada.Command_Line.Argument (1) = "S";
   N : constant Order := Order'Value (Ada.Command_Line.Argument (2));
   Repeats : constant Positive := Positive'Value (Ada.Command_Line.Argument (3));
   Source, A : Real_Array (0 .. N*N-1) := [others => 0.0];
   B, X : Real_Array (0 .. N-1) := [others => 1.0];
   P, Diagonal, Scratch : Int_Array (0 .. N-1);
   Row_Start : Int_Array (0 .. N);
   Column : Int_Array (0 .. N*N-1);
   Count : Natural := 0;
   Result : Status;
   First : Integer;
   Start, Stop : Time;
   Checksum : Real := 0.0;
   function Entry_Value (I, J : Natural) return Real is
     (if I=J then Real(N+1) else Real(Integer((I+3*J) mod 7)-3)*0.03125);
   function Connected (I, J : Natural) return Boolean is
      A : Natural := I;
   begin
      loop
         if A=J then return True; end if;
         exit when A=0; A := (A-1)/2;
      end loop;
      A := J;
      loop
         if A=I then return True; end if;
         exit when A=0; A := (A-1)/2;
      end loop;
      return False;
   end Connected;
begin
   for I in 0 .. N-1 loop
      Row_Start(I) := Count;
      for J in 0 .. N-1 loop
         if not Sparse or else Connected(I,J) then
            Source(Count) := Entry_Value(I,J); Column(Count) := J; Count := Count+1;
         end if;
      end loop;
   end loop;
   Row_Start(N) := Count;
   if Sparse then Analyze(N,Row_Start,Column(0..Count-1),Diagonal,Result); end if;
   Start := Clock;
   for Repeat in 1 .. Repeats loop
      A(0..Count-1) := Source(0..Count-1);
      if Sparse then
         Factor_Sparse(A(0..Count-1),N,Row_Start,Column(0..Count-1),Diagonal,Scratch,First,Result);
         if Result/=Success then raise Program_Error; end if;
         Solve_Sparse(A(0..Count-1),N,Row_Start,Column(0..Count-1),Diagonal,B,X,Result);
      else
         Factor_Dense(A,N,P,Result);
         if Result/=Success then raise Program_Error; end if;
         Solve_Dense(A,N,P,B,X,Result);
      end if;
      if Result/=Success then raise Program_Error; end if;
      Checksum := Checksum + X(Repeat mod N);
   end loop;
   Stop := Clock;
   Put_Line(Duration'Image(To_Duration(Stop-Start)) & " " & Real'Image(Checksum));
end LU_Bench;
