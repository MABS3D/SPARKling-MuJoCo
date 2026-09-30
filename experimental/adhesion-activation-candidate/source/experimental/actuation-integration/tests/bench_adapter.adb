with MJ.Types; use MJ.Types;
with MJ.Activation;
with MJ.Adhesive_Slider; use MJ.Adhesive_Slider;
with MJ.Contact_Slider;
package body Bench_Adapter is
   procedure Run (Input, Output : System.Address; Steps : Interfaces.C.int) is
      use type MJ.Contact_Slider.Status;
      type Input_Array is array (0 .. 34) of Real;
      type Output_Array is array (0 .. 6) of Real;
      A : Input_Array with Import, Address => Input;
      R : Output_Array with Import, Address => Output;
      C : Configuration :=
        (Motion => (Mass=>A(0),Radius=>A(1),Plane_Height=>A(2),Gravity=>A(3),H=>A(4),
           Margin=>A(5),Gap=>A(6),Solver=>(A(7),A(8),A(9),A(10),A(11),A(12))),
         Kind=>MJ.Activation.Dynamics'Val(Integer(A(13))),Tau=>Real'Max(1.0e-15,A(14)),
         Factor=>0.0,Gain=>A(15),Enabled=>A(16)/=0.0,Clamp_Control=>A(17)/=0.0,Early=>A(18)/=0.0,
         Control_Limited=>A(19)/=0.0,Control_Lower=>A(20),Control_Upper=>A(21),
         Activation_Limited=>A(22)/=0.0,Activation_Lower=>A(23),Activation_Upper=>A(24),
         Force_Limited=>A(25)/=0.0,Force_Lower=>A(26),Force_Upper=>A(27));
      S : State := (Motion=>(A(28),A(29),A(30)),Act=>A(31));
      E : Evaluation;
      Result : Status := MJ.Contact_Slider.Success;
   begin
      C.Factor:=MJ.Activation.Exact_Factor(C.Motion.H,C.Tau);
      for K in 1 .. Steps loop
         Step (C,S,A(32),A(33),E,Result);
         exit when Result /= MJ.Contact_Slider.Success;
      end loop;
      R := [S.Motion.Height,S.Motion.Velocity,S.Motion.Time,S.Act,E.Force,E.Motion.Info.Row.Force,
        Real(MJ.Contact_Slider.Status'Pos(Result))];
   end Run;
end Bench_Adapter;
