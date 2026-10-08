package body MJ.Constraint_Solvers.Cone_Kernels with SPARK_Mode is
   function Add_Scaled (Acc : Folded_Value; Value : Jacobian_Value;
                        Scale : Factor_Value; Count : Natural) return Folded_Value is
   begin
      return Acc + Value * Scale;
   end Add_Scaled;

   procedure Fold_Column (L : Local_Matrix; J : Local_Vector;
                          Dim : Component; Output : out Local_Vector) is
      Acc : Folded_Value;
   begin
      Output := (others => 0.0);
      for C in 1 .. Dim loop
         Acc := 0.0;
         for K in 1 .. Dim - C + 1 loop
            pragma Loop_Invariant (Acc = Fold_Value (L, J, C, K - 1));
            pragma Loop_Invariant (abs Acc <= Real (K - 1) * Step_Bound);
            Acc := Add_Scaled (Acc, J (C + K - 1), L (C + K - 1, C), K - 1);
            declare
               pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Fold_Value);
            begin
               pragma Assert (Acc = Fold_Value (L, J, C, K));
            end;
         end loop;
         Output (C) := Acc;
         pragma Loop_Invariant (for all P in 1 .. C =>
           Output (P) = Fold_Value (L, J, P, Dim - P + 1));
         pragma Loop_Invariant (for all P in C + 1 .. 6 => Output (P) = 0.0);
         pragma Loop_Invariant (for all V of Output => V in Folded_Value);
      end loop;
   end Fold_Column;

   function Gram_Update (Previous : Real; Left, Right : Folded_Value;
                         Weight : Real) return Real is
   begin
      return Previous + (Weight * Left) * Right;
   end Gram_Update;
end MJ.Constraint_Solvers.Cone_Kernels;
