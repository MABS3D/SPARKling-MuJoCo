with MJ.Collision;
package body MJ.Contact_Slider with SPARK_Mode is

   function Detect (C : Configuration; S : State) return Detection is
      Hit : constant MJ.Collision.Contact_Set := MJ.Collision.Plane_Sphere
        ([0.0, 0.0, C.Plane_Height], [0.0, 0.0, 1.0],
         [0.0, 0.0, S.Height], C.Radius, C.Margin+C.Gap);
   begin
      pragma Assert (Static => MJ.Collision.Projected_Distance
        ([0.0, 0.0, C.Plane_Height], [0.0, 0.0, S.Height], [0.0, 0.0, 1.0])
          = S.Height-C.Plane_Height);
      return (Contact => Hit.Count = 1,
              Distance => (if Hit.Count = 1 then Hit.Contacts (0).Distance else 0.0));
   end Detect;
   procedure Evaluate (C : Configuration; S : State; Applied : Tier0_Real;
                       E : out Evaluation) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Evaluated);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", MJ.Contact_Rows.Model.Matches);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", MJ.Contact_Rows.Model.Regularizer);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", MJ.Contact_Rows.Model.Reference);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", MJ.Contact_Rows.Model.Projected_Force);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", MJ.Contact_Rows.Model.Accelerated);

      Inv_M : constant Inverse_Mass := Mass_Inverse (C.Mass);
      Free_A : constant Smooth_Acceleration := Smooth (C.Mass, C.Gravity, Applied);
      Hit : Detection;
   begin
      E := (others => <>);
      if C.Margin+C.Gap > Max_Val then E.Result := Numeric_Limit; return; end if;
      Hit := Detect (C, S);
      E.Info.Row.Acceleration := Free_A;
      E.Info.Contact := Hit.Contact;
      if not E.Info.Contact then
         pragma Assert (Static => Model.Evaluated (C, S, Applied, E));
         return;
      end if;
      E.Info.Distance := Hit.Distance;
      E.Info.Active := E.Info.Distance < C.Margin;
      if E.Info.Active then
         Assemble (E.Info.Row, C.Solver, C.H, Inv_M, E.Info.Distance,
                   C.Margin, S.Velocity, Free_A);
         --  Substitute the inverse mass and smooth acceleration separately;
         --  these proved steps keep the floating-point composition local.
         pragma Assert (Static => MJ.Contact_Rows.Model.Matches
           (C.Solver, C.H, Inv_M, E.Info.Distance, C.Margin, S.Velocity, Free_A, E.Info.Row));
         pragma Assert (Static => MJ.Contact_Rows.Model.Matches
           (C.Solver, C.H, MJ.Contact_Rows.Model.Mass_Inverse (C.Mass), E.Info.Distance,
            C.Margin, S.Velocity, Free_A, E.Info.Row));
         pragma Assert (Static => MJ.Contact_Rows.Model.Matches
           (C.Solver, C.H, MJ.Contact_Rows.Model.Mass_Inverse (C.Mass), E.Info.Distance,
            C.Margin, S.Velocity, MJ.Contact_Rows.Model.Smooth (C.Mass, C.Gravity, Applied), E.Info.Row));
         if not E.Info.Row.Accepted then E.Result := Numeric_Limit; end if;
         pragma Assert (Static => Model.Evaluated (C, S, Applied, E));
      else
         pragma Assert (Static => Model.Evaluated (C, S, Applied, E));
      end if;
   end Evaluate;
   procedure Step (C : Configuration; S : in out State; Applied : Tier0_Real;
                   E : out Evaluation; Result : out Status) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Step_Accepted);
      V, Z : Real;
      T : constant Real := S.Time+C.H;
   begin
      Evaluate (C, S, Applied, E);
      V := S.Velocity + C.H*E.Info.Row.Acceleration;
      Z := S.Height + C.H*V;
      if E.Result /= Success or else V not in Tier0_Real or else Z not in Tier0_Real
        or else T not in Nonneg_Tier0
      then
         Result := Numeric_Limit;
      else
         S := (Height => Z, Velocity => V, Time => T);
         Result := Success;
      end if;
   end Step;
end MJ.Contact_Slider;
