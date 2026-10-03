with MJ.Types; use MJ.Types;

--  Ordered MuJoCo 3.14.0 power curve. The numerical runtime has no assumed
--  range/accuracy contract. Invalid intermediates produce an explicit result.
package MJ.Solimp_Curve with SPARK_Mode is
   subtype Fraction is Real range 0.0 .. 1.0;
   subtype Midpoint is Real range 0.0001 .. 0.9999;
   subtype Exponent is Real range 1.0 .. Real'Last;
   subtype Value is Real range -2.0e4 .. 2.0e4;
   subtype Slope is Real range 0.0 .. 1.0e20;
   subtype Coefficient is Real range 1.0 .. 1.1e307;
   subtype Product is Real range 0.0 .. 1.1e307;
   type Power_Result is record
      Valid : Boolean := False;
      Number : Fraction := 0.0;
   end record;
   type Coefficient_Result is record
      Valid : Boolean := False;
      Number : Coefficient := 1.0;
   end record;
   type Product_Result is record
      Valid : Boolean := False;
      Number : Product := 0.0;
   end record;
   type Result is record
      Valid : Boolean := False;
      Y : Value := 0.0;
      YP : Slope := 0.0;
   end record;

   function Runtime_Pow (Base, P : Real) return Real
     with Import, Convention => C, External_Name => "pow", Global => null;
   function Power (Base : Fraction; P : Real) return Power_Result
     with Inline, Global => null, Pre => P >= 0.0,
     Post => (Static => Power'Result =
       (if P = 1.0 then (True, Base) elsif P = 2.0 then (True, Base * Base)
        else (declare V : constant Real := Runtime_Pow (Base, P);
              begin (if V in Fraction then (True, V) else (others => <>)))));
   function Inverse_Power (Base : Fraction; P : Real) return Coefficient_Result
     with Inline, Global => null, Pre => Base >= 0.00009 and then P >= 0.0,
     Post => (Static => Inverse_Power'Result =
       (declare V : constant Power_Result := Power (Base, P);
        begin (if not V.Valid or else V.Number < 1.0e-307 then (others => <>)
               else (True, 1.0 / V.Number))));
   function Scaled_Coefficient (P : Exponent; A : Coefficient) return Product_Result
     with Inline, Global => null,
     Post => (Static => Scaled_Coefficient'Result =
       (if P > 1.0e307 / A then (others => <>) else (True, P * A)));

   package Model with Ghost => Static is
      function Build (Left : Boolean; A : Coefficient; XP, XM : Fraction;
                      Scaled : Product) return Result is
        (declare Y : constant Real := (if Left then A * XP else 1.0 - A * XP);
                 YP : constant Real := Scaled * XM;
         begin (if Y in Value and then YP in Slope then (True, Y, YP)
                else (others => <>)))
        with Global => null,
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;
   function Build (Left : Boolean; A : Coefficient; XP, XM : Fraction;
                   Scaled : Product) return Result with Inline, Global => null,
     Post => (Static => Build'Result = Model.Build (Left, A, XP, XM, Scaled));

   package Composition with Ghost => Static is
      function Evaluate (X : Fraction; Mid : Midpoint; P : Exponent) return Result is
        (if P = 1.0 then (True, X, 1.0) else
          (declare Left : constant Boolean := X <= Mid;
                   Base : constant Fraction := (if Left then Mid else 1.0 - Mid);
                   Arg : constant Fraction := (if Left then X else 1.0 - X);
                   A : constant Coefficient_Result := Inverse_Power (Base, P - 1.0);
                   XP : constant Power_Result := Power (Arg, P);
                   XM : constant Power_Result := Power (Arg, P - 1.0);
                   Scaled : constant Product_Result := Scaled_Coefficient (P, A.Number);
           begin (if A.Valid and then XP.Valid and then XM.Valid and then Scaled.Valid
             then Model.Build (Left, A.Number, XP.Number, XM.Number, Scaled.Number)
             else (others => <>))))
        with Global => null,
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Composition;
   function Evaluate (X : Fraction; Mid : Midpoint; P : Exponent) return Result
     with Inline, Global => null,
     Post => (Static => Evaluate'Result = Composition.Evaluate (X, Mid, P));
end MJ.Solimp_Curve;
