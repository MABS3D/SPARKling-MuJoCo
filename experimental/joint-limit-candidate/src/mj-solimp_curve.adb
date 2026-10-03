package body MJ.Solimp_Curve with SPARK_Mode is
   function Power (Base : Fraction; P : Real) return Power_Result is
      V : Real;
   begin
      if P = 1.0 then return (True, Base);
      elsif P = 2.0 then return (True, Base * Base); end if;
      V := Runtime_Pow (Base, P);
      if V not in Fraction then return (others => <>); end if;
      return (True, V);
   end Power;

   function Inverse_Power (Base : Fraction; P : Real) return Coefficient_Result is
      V : constant Power_Result := Power (Base, P);
   begin
      if not V.Valid or else V.Number < 1.0e-307 then return (others => <>); end if;
      return (True, 1.0 / V.Number);
   end Inverse_Power;

   function Scaled_Coefficient (P : Exponent; A : Coefficient) return Product_Result is
   begin
      if P > 1.0e307 / A then return (others => <>); end if;
      return (True, P * A);
   end Scaled_Coefficient;

   function Build (Left : Boolean; A : Coefficient; XP, XM : Fraction;
                   Scaled : Product) return Result is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Build);
      Y : constant Real := (if Left then A * XP else 1.0 - A * XP);
      YP : constant Real := Scaled * XM;
   begin
      if Y not in Value or else YP not in Slope then return (others => <>); end if;
      return (True, Y, YP);
   end Build;

   function Evaluate (X : Fraction; Mid : Midpoint; P : Exponent) return Result is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Composition.Evaluate);
      Left : constant Boolean := X <= Mid;
      Base : constant Fraction := (if Left then Mid else 1.0 - Mid);
      Arg : constant Fraction := (if Left then X else 1.0 - X);
      A : Coefficient_Result;
      XP, XM : Power_Result;
      Scaled : Product_Result;
   begin
      if P = 1.0 then return (True, X, 1.0); end if;
      A := Inverse_Power (Base, P - 1.0);
      if not A.Valid then return (others => <>); end if;
      XP := Power (Arg, P);
      if not XP.Valid then return (others => <>); end if;
      XM := Power (Arg, P - 1.0);
      if not XM.Valid then return (others => <>); end if;
      Scaled := Scaled_Coefficient (P, A.Number);
      if not Scaled.Valid then return (others => <>); end if;
      return Build (Left, A.Number, XP.Number, XM.Number, Scaled.Number);
   end Evaluate;
end MJ.Solimp_Curve;
