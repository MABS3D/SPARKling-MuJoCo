with MJ.Types; use MJ.Types;
with MJ.Contact_Slider; use MJ.Contact_Slider;
package body Bench_Adapter is
   procedure Run (Input, Output : System.Address; Steps : Interfaces.C.int) is
      type Input_Array is array (0 .. 16) of Real;
      type Output_Array is array (0 .. 4) of Real;
      A : Input_Array with Import, Address => Input;
      R : Output_Array with Import, Address => Output;
      C : constant Configuration :=
        (Mass => A (0), Radius => A (1), Plane_Height => A (2), Gravity => A (3),
         H => A (4), Margin => A (5), Gap => A (6),
         Solver => (A (7), A (8), A (9), A (10), A (11), A (12)));
      S : State := (A (13), A (14), A (15));
      E : Evaluation;
      Result : Status := Success;
   begin
      for K in 1 .. Steps loop
         Step (C, S, A (16), E, Result);
         exit when Result /= Success;
      end loop;
      R := [S.Height, S.Velocity, S.Time, E.Info.Row.Force, Real (Status'Pos (Result))];
   end Run;
end Bench_Adapter;
