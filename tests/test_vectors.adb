with Check;    use Check;
with MJ.Types; use MJ.Types;
with MJ.BLAS;  use MJ.BLAS;

procedure Test_Vectors is
   V : Vector_3;
   Q : Vector_4;
   Length : Nonnegative_Real;
   A : constant Vector_3 := [3.0, 4.0, 0.0];
   X : constant Vector_3 := [1.0, 0.0, 0.0];
   Y : constant Vector_3 := [0.0, 1.0, 0.0];
   procedure Near (Actual, Expected : Real; Label : String) is
   begin
      Assert (abs (Actual - Expected) <= 1.0e-14, Label);
   end Near;
begin
   Assert (Zero3 = [0.0, 0.0, 0.0], "zero3");
   Assert (Zero4 = [0.0, 0.0, 0.0, 0.0], "zero4");
   Assert (Unit4 = [1.0, 0.0, 0.0, 0.0], "unit4");
   Assert (Copy3 (A) = A, "copy3");
   Assert (Copy4 (Unit4) = Unit4, "copy4");
   Assert (Cross3 (X, Y) = [0.0, 0.0, 1.0], "right handed cross");
   Assert (Cross3 (Y, X) = [0.0, 0.0, -1.0], "cross orientation");
   Assert (Cross3 (A, A) = Zero3, "self cross");
   Assert (Equal3 (Zero3, [Real'Adjacent (Min_Val, 0.0), 0.0, 0.0]), "equal below threshold");
   Assert (not Equal3 (Zero3, [Min_Val, 0.0, 0.0]), "equal threshold is strict");
   Assert (not Equal3 (Zero3, [0.0, 0.0, -Min_Val]), "equal checks final component");
   Near (Norm3 (A), 5.0, "3-4-5 norm");
   Near (Dist3 (A, [3.0, 0.0, 0.0]), 4.0, "distance");
   V := A; Normalize3 (V, Length);
   Near (Length, 5.0, "normalize returns input norm");
   Near (V (0), 0.6, "normalized x");
   Near (V (1), 0.8, "normalized y");
   V := Zero3; Normalize3 (V, Length);
   Assert (V = X and then Length = 0.0, "zero3 fallback");
   V := [0.0, -1.0e-300, 0.0]; Normalize3 (V, Length);
   Assert (V = X and then Length = 0.0, "underflow norm fallback");
   V := [0.0, -Min_Val, 0.0]; Normalize3 (V, Length);
   Assert (V (1) < -0.99 and then V (0) = 0.0, "at threshold normalize direction");
   Q := Zero4; Normalize4 (Q, Length);
   Assert (Q = Unit4 and then Length = 0.0, "zero4 fallback");
   Q := [Real'Adjacent (1.0, 2.0), 0.0, 0.0, 0.0];
   declare
      Old_Q : constant Vector_4 := Q;
   begin
      Normalize4 (Q, Length);
      Assert (Q = Old_Q, "normalize4 preserves nearly unit input exactly");
      V := [Old_Q (0), 0.0, 0.0]; Normalize3 (V, Length);
      Assert (V /= [Old_Q (0), 0.0, 0.0], "normalize3 has no near-unit shortcut");
   end;
   Q := [0.0, 0.0, 3.0, 4.0]; Normalize4 (Q, Length);
   Near (Length, 5.0, "four-component norm");
   Near (Q (2), 0.6, "four-component normalization");

   declare
      P : constant Real_Array (7 .. 11) := [1.0, -2.0, 3.0, -4.0, 5.0];
      B : constant Real_Array (7 .. 11) := [2.0, 2.0, 2.0, 2.0, 2.0];
      R : Real_Array (7 .. 11);
   begin
      Zero (R); Assert ((for all C of R => C = 0.0), "generic zero");
      Fill (R, -7.0); Assert ((for all C of R => C = -7.0), "generic fill");
      Copy (R, P); Assert (R = P, "generic copy with shifted bounds");
      Scl (R, P, -2.0); Assert (R = [-2.0, 4.0, -6.0, 8.0, -10.0], "generic scale");
      Add (R, P, B); Assert (R = [3.0, 0.0, 5.0, -2.0, 7.0], "generic add");
      Sub (R, P, B); Assert (R = [-1.0, -4.0, 1.0, -6.0, 3.0], "generic sub");
      R := P; AddTo (R, B); Assert (R = [3.0, 0.0, 5.0, -2.0, 7.0], "generic addTo");
      R := P; SubFrom (R, B); Assert (R = [-1.0, -4.0, 1.0, -6.0, 3.0], "generic subFrom");
      R := P; AddToScl (R, B, -2.0);
      Assert (R = [-3.0, -6.0, -1.0, -8.0, 1.0], "generic addToScl");
      AddScl (R, P, B, -2.0);
      Assert (R = [-3.0, -6.0, -1.0, -8.0, 1.0], "generic addScl");
      Assert (Sum (P) = 3.0 and then L1 (P) = 15.0, "signed and absolute reductions");
      Assert (Dot (P, B) = 6.0, "four lanes plus tail");
      R := [others => 0.0]; Normalize (R, Length);
      Assert (R = [1.0, 0.0, 0.0, 0.0, 0.0] and then Length = 0.0, "shifted fallback");
      R := P; Normalize (R, Length);
      Near (Norm (R), 1.0, "generic normalized norm");
   end;
   declare
      --  A naive sequential dot would round away the middle +1.
      P : constant Real_Array := [1.0e10, 1.0, -1.0e10, 1.0];
      B : constant Real_Array := [1.0e10, 1.0, 1.0e10, 1.0];
   begin
      Assert (Dot (P, B) = 2.0, "MuJoCo four-lane addition order");
   end;
   declare
      P : constant Real_Array (Natural'Last - 2 .. Natural'Last) := [1.0, 2.0, 3.0];
      R : Real_Array (P'Range);
   begin
      Copy (R, P); Assert (R = P, "copy at maximum index");
      Assert (Dot (P, P) = 14.0, "dot tail at maximum index");
      Assert (Sum (P) = 6.0, "sum at maximum index");
      Normalize (R, Length); Near (Norm (R), 1.0, "normalize at maximum index");
   end;
   declare
      E : Real_Array (0 .. -2);
      F : Real_Array (0 .. -2);
   begin
      Zero (E); Fill (E, 2.0); Copy (F, E);
      Add (F, E, E); Sub (F, E, E); Scl (F, E, 2.0); AddScl (F, E, E, 2.0);
      AddTo (F, E); SubFrom (F, E); AddToScl (F, E, 2.0);
      Assert (E'Length = 0 and then F'Last = -2, "extreme null bounds preserved");
      Assert (Sum (E) = 0.0 and then L1 (E) = 0.0 and then Dot (E, F) = 0.0
              and then Norm (E) = 0.0, "empty reductions");
   end;
   declare
      P : constant Real_Array (0 .. 4095) := [others => Max_Val];
   begin
      Assert (Sum (P) = 4096.0 * Max_Val, "long sum at tier limit");
      Assert (Dot (P, P) in 4.095e23 .. 4.097e23, "long dot at tier limit");
   end;
   Assert (Norm3 ([Max_Val, Max_Val, Max_Val]) > Max_Val, "norm can exceed input tier");
   Assert (Dist3 ([Max_Val, 0.0, 0.0], [-Max_Val, 0.0, 0.0]) = 2.0 * Max_Val,
           "distance accepts differences outside Tier0");
   Assert (Norm3 ([Tier1_Real'Last, 0.0, 0.0]) = Tier1_Real'Last,
           "norm3 accepts Tier1 inputs");
   Assert (Norm4 ([0.0, 0.0, 0.0, Tier1_Real'Last]) = Tier1_Real'Last,
           "norm4 accepts Tier1 inputs");
   Report_And_Exit;
end Test_Vectors;
