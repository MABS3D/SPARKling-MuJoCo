package body MJ.Equality_Scalar with SPARK_Mode is
   function Offset (Position, Reference : Tier0_Real) return Offset_Value is
   begin
      return Position-Reference;
   end Offset;

   function Scale (N : Degree; A : Tier0_Real) return Scaled_Coefficient is
   begin
      return Real (N)*A;
   end Scale;

   function Linear (A : Scaled_Coefficient; D : Offset_Value) return Linear_Value is
   begin
      return A*D;
   end Linear;

   function Quadratic (A : Scaled_Coefficient; D : Offset_Value) return Quadratic_Value is
   begin
      return Linear (A, D)*D;
   end Quadratic;

   function Cubic (A : Scaled_Coefficient; D : Offset_Value) return Cubic_Value is
   begin
      return Quadratic (A, D)*D;
   end Cubic;

   function Quartic (A : Scaled_Coefficient; D : Offset_Value) return Quartic_Value is
   begin
      return Cubic (A, D)*D;
   end Quartic;

   function Polynomial (C : Coefficients; D : Offset_Value) return Polynomial_Value is
   begin
      return ((Linear (C (1), D)+Quadratic (C (2), D))+Cubic (C (3), D))+Quartic (C (4), D);
   end Polynomial;

   function Slope (C : Coefficients; D : Offset_Value) return Slope_Value is
   begin
      return ((C (1)+Linear (Scale (2, C (2)), D))+Quadratic (Scale (3, C (3)), D))
        + Cubic (Scale (4, C (4)), D);
   end Slope;

   function Base_Error (Position, Reference, Constant_Term : Tier0_Real)
                        return Base_Value is
   begin
      return (Position-Reference)-Constant_Term;
   end Base_Error;

   function Coupled_Error (Base : Base_Value; Tail : Polynomial_Value)
                           return Residual_Value is
   begin
      return Base-Tail;
   end Coupled_Error;

   function Evaluate
     (Position0, Reference0, Position1, Reference1 : Tier0_Real;
      C : Coefficients; Has_Second : Boolean) return Geometry is
      Base : constant Base_Value := Base_Error (Position0, Reference0, C (0));
   begin
      if Has_Second then
         declare
            D : constant Offset_Value := Offset (Position1, Reference1);
         begin
            return (Coupled_Error (Base, Polynomial (C, D)), Slope (C, D));
         end;
      else
         return (Base, 0.0);
      end if;
   end Evaluate;

   function Jacobian (J0, J1 : Tier2_Real; Derivative : Slope_Value)
                      return Tier3_Real is
   begin
      return J0+(-Derivative)*J1;
   end Jacobian;
end MJ.Equality_Scalar;
