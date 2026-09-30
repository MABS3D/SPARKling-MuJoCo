with MJ.Types; use MJ.Types;
with MJ.Contact_Rows; use MJ.Contact_Rows;
package MJ.Contact_Slider with SPARK_Mode is
   --  One sphere at its COM, one vertical slider, one horizontal fixed plane.
   --  No armature, joint damping, springs, actuators, friction or other contacts.
   type Configuration is record
      Mass : Positive_Parameter := 1.0;
      Radius : Positive_Parameter := 0.1;
      Plane_Height : Tier0_Real := 0.0;
      Gravity : Tier0_Real := -9.81;
      H : Nonneg_Tier0 := 0.002;
      Margin : Nonneg_Tier0 := 0.0;
      Gap : Nonneg_Tier0 := 0.0;
      Solver : Parameters;
   end record;
   type State is record
      Height, Velocity : Tier0_Real := 0.0;
      Time : Nonneg_Tier0 := 0.0;
   end record;
   type Status is (Success, Numeric_Limit);
   type Diagnostics is record
      Contact, Active : Boolean := False;
      Distance : Separation := 0.0;
      Row : Row_Result;
   end record;
   type Evaluation is record
      Info : Diagnostics;
      Result : Status := Success;
   end record;
   package Model with Ghost => Static is
      function Evaluated (C : Configuration; S : State; Applied : Tier0_Real;
                          E : Evaluation) return Boolean is
        (if C.Margin+C.Gap > Max_Val then E = (Result => Numeric_Limit, others => <>)
         else (declare Free_A : constant Smooth_Acceleration := MJ.Contact_Rows.Model.Smooth
                         (C.Mass, C.Gravity, Applied);
                       Dist : constant Separation := (S.Height-C.Plane_Height)-C.Radius;
                       Hit : constant Boolean := not ((S.Height-C.Plane_Height) > (C.Margin+C.Gap)+C.Radius);
               begin (if not Hit then
                 E = (Info => (Row => (Acceleration => Free_A, others => <>), others => <>), Result => Success)
               elsif Dist >= C.Margin then
                 E = (Info => (Contact => True, Distance => Dist,
                           Row => (Acceleration => Free_A, others => <>), others => <>), Result => Success)
               else E.Info.Contact and then E.Info.Active and then E.Info.Distance = Dist
                 and then MJ.Contact_Rows.Model.Matches
                   (C.Solver, C.H, MJ.Contact_Rows.Model.Mass_Inverse (C.Mass),
                    E.Info.Distance, C.Margin, S.Velocity, Free_A, E.Info.Row)
                 and then E.Result = (if E.Info.Row.Accepted then Success else Numeric_Limit))))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Next_Velocity (S : State; H : Nonneg_Tier0; A : Total_Acceleration)
        return Tier3_Real is (S.Velocity + H*A) with Global => null;
      function Next_Height (S : State; H : Nonneg_Tier0; V : Tier3_Real)
        return Real is (S.Height + H*V) with Global => null,
        Pre => V in -1.0e100 .. 1.0e100;
      function Step_Accepted (C : Configuration; S : State; E : Evaluation)
        return Boolean is
        (declare V : constant Real := Next_Velocity (S, C.H, E.Info.Row.Acceleration);
                 Z : constant Real := S.Height+C.H*V;
         begin E.Result = Success and then V in Tier0_Real and then Z in Tier0_Real
           and then S.Time+C.H in Nonneg_Tier0)
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;
   type Detection is record
      Contact : Boolean := False;
      Distance : Separation := 0.0;
   end record;
   function Detect (C : Configuration; S : State) return Detection with
     Inline_Always, Global => null, Pre => C.Margin+C.Gap <= Max_Val,
     Post => (Static => Detect'Result.Contact =
       (not ((S.Height-C.Plane_Height) > (C.Margin+C.Gap)+C.Radius))
       and then Detect'Result.Distance =
         (if Detect'Result.Contact then (S.Height-C.Plane_Height)-C.Radius else 0.0));
   procedure Evaluate (C : Configuration; S : State; Applied : Tier0_Real;
                       E : out Evaluation) with Inline_Always, Global => null,
     Post => (Static => Model.Evaluated (C, S, Applied, E));
   procedure Step (C : Configuration; S : in out State; Applied : Tier0_Real;
                   E : out Evaluation; Result : out Status) with
     Inline_Always, Global => null,
     Post => (Static => Model.Evaluated (C, S'Old, Applied, E)
       and then (Result = Success) = Model.Step_Accepted (C, S'Old, E)
       and then (if Result = Success then
         S.Velocity = Model.Next_Velocity (S'Old, C.H, E.Info.Row.Acceleration)
         and then S.Height = Model.Next_Height (S'Old, C.H, S.Velocity)
         and then S.Time = S.Time'Old + C.H
         else S = S'Old));
end MJ.Contact_Slider;
