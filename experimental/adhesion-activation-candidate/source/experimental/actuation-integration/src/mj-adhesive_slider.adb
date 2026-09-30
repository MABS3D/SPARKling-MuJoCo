package body MJ.Adhesive_Slider with SPARK_Mode is
   function Moment_For (C : MJ.Contact_Slider.Configuration; S : MJ.Contact_Slider.State) return Real is
      Hit : constant MJ.Contact_Slider.Detection := MJ.Contact_Slider.Detect (C,S);
   begin
      -- The one normal row is J=1; averaging this single contact yields -1.
      -- This specializes the general body transmission without temporary rows.
      return (if Hit.Contact then -1.0 else 0.0);
   end Moment_For;
   procedure Evaluate (C : Configuration; S : State; U, Applied : Tier0_Real; E : out Evaluation) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Matches);
      F : Real;
   begin
      E := (others => <>);
      if C.Kind = MJ.Activation.None then
         E.Next := S.Act; E.Drive := Control (C,U);
      else
         MJ.Activation.Prepare (C.Kind,Control (C,U),S.Act,C.Motion.H,C.Tau,C.Factor,
           C.Enabled,C.Early,C.Activation_Limited,C.Activation_Lower,C.Activation_Upper,
           E.Dot,E.Next,E.Drive,E.Can_Advance);
      end if;
      pragma Assert (Static => E.Dot = Expected_Dot (C,S,U));
      if C.Kind /= MJ.Activation.None and then C.Enabled then
         pragma Assert (Static => Expected_Next (C,S,U) =
           MJ.Activation.Next_Value (C.Kind,S.Act,E.Dot,C.Motion.H,C.Tau,C.Factor,
             C.Activation_Limited,C.Activation_Lower,C.Activation_Upper));
      else
         pragma Assert (Static => Expected_Next (C,S,U) = S.Act);
      end if;
      pragma Assert (Static => E.Can_Advance = (Expected_Next (C,S,U) in Tier0_Real));
      pragma Assert (Static => E.Next = (if E.Can_Advance then Expected_Next (C,S,U) else S.Act));
      pragma Assert (Static => E.Drive = Expected_Drive (C,S,U));
      F := Scalar_Force (C,E.Drive);
      if (C.Kind /= MJ.Activation.None and then C.Early and then not E.Can_Advance)
        or else F not in Tier0_Real or else C.Motion.Margin+C.Motion.Gap > Max_Val then
         E.Result := MJ.Contact_Slider.Numeric_Limit; return;
      end if;
      E.Force := F;
      E.Moment := Moment_For (C.Motion,S.Motion);
      E.Generalized := F*E.Moment;
      if Applied+E.Generalized not in Tier0_Real then
         E.Result := MJ.Contact_Slider.Numeric_Limit; return;
      end if;
      E.Total_Applied := Applied+E.Generalized;
      MJ.Contact_Slider.Evaluate (C.Motion,S.Motion,E.Total_Applied,E.Motion);
      E.Result := E.Motion.Result;
   end Evaluate;
   procedure Step (C : Configuration; S : in out State; U, Applied : Tier0_Real;
      E : out Evaluation; Result : out Status) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Accepted);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", MJ.Contact_Slider.Model.Step_Accepted);
      V,Z : Real;
      T : constant Real := S.Motion.Time+C.Motion.H;
   begin
      Evaluate (C,S,U,Applied,E);
      V := S.Motion.Velocity+C.Motion.H*E.Motion.Info.Row.Acceleration;
      Z := S.Motion.Height+C.Motion.H*V;
      if E.Result /= MJ.Contact_Slider.Success or else not E.Can_Advance
        or else V not in Tier0_Real or else Z not in Tier0_Real or else T not in Nonneg_Tier0 then
         Result := MJ.Contact_Slider.Numeric_Limit;
      else
         S := (Motion => (Height => Z, Velocity => V, Time => T), Act => E.Next);
         Result := MJ.Contact_Slider.Success;
      end if;
   end Step;
end MJ.Adhesive_Slider;
