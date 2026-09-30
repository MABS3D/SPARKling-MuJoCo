with Ada.Command_Line;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO;
with Interfaces.C;
with MJ.Types; use MJ.Types;
with MJ.Muscle_Actuation; use MJ.Muscle_Actuation;
procedure Muscle_Bench is
   function Bench_C (Rounds, Pattern : Interfaces.C.int; Sum : access Real) return Real
     with Import, Convention => C, External_Name => "muscle_bench_c";
   Rounds : constant Positive := Positive'Value(Ada.Command_Line.Argument(1));
   Pattern : constant Natural := Natural'Value(Ada.Command_Line.Argument(2));
   First_Ada : constant Boolean := Ada.Command_Line.Argument(3)="A";
   ASum,CSum : aliased Real := 0.0;
   Ada_Time,C_Time : Real;
   procedure Bench_Ada (Elapsed, Sum : out Real) is
      type Inputs is array (Natural range 0 .. 127) of Tier0_Real;
      L,V,C : Inputs;
      P : Configuration;
      S : State := (Activation=>0.3);
      E : Evaluation;
      Status : Step_Status;
      Start : Time;
   begin
      P.Activation_Limited:=True;
      if Pattern/=0 then P.Dynamics(2):=0.2; P.Actearly:=True; end if;
      if Pattern=2 then P.Force_Limited:=True; P.Force_Range:=(-150.0,0.0); end if;
      for J in L'Range loop
         L(J):=0.15+Real(J)*(1.7/127.0);
         V(J):=-3.0+Real(J)*(6.0/127.0);
         C(J):=(if J mod 2=0 then 0.2 else 0.8);
      end loop;
      Sum:=0.0;
      Start:=Clock;
      for I in 1 .. Rounds loop
         for J in L'Range loop
            Step(P,S,C(J),L(J),V(J),0.001,E,Status);
            if Status/=Success then raise Program_Error; end if;
            Sum:=Sum+E.Force;
         end loop;
      end loop;
      Elapsed:=Real(To_Duration(Clock-Start));
      Sum:=Sum+S.Activation;
   end Bench_Ada;
begin
   if First_Ada then
      Bench_Ada(Ada_Time,ASum); C_Time:=Bench_C(Interfaces.C.int(Rounds),Interfaces.C.int(Pattern),CSum'Access);
   else
      C_Time:=Bench_C(Interfaces.C.int(Rounds),Interfaces.C.int(Pattern),CSum'Access); Bench_Ada(Ada_Time,ASum);
   end if;
   Ada.Text_IO.Put_Line(Ada_Time'Image & " " & C_Time'Image & " " & ASum'Image & " " & CSum'Image);
end Muscle_Bench;
