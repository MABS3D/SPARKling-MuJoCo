with MJ.Types; use MJ.Types;
with MJ.Ancestor_Rows;

-- Read the existing dense publication through its immutable ancestor pattern.
-- No packing, matrix scan, factorization or allocation is performed here.
package MJ.Inverse_Mass with SPARK_Mode is
   function Work (A : Real_Array) return Boolean is
     (for all X of A => X in -1.0e100 .. 1.0e100) with Global => null;
   -- Ordered reference, including C's diagonal/reverse-lower/upper-scatter order.
   -- This functional relation remains a separate obligation from local safety.
   function Model (Pattern : MJ.Ancestor_Rows.Pattern; Mass, Acceleration : Real_Array)
     return Real_Array with Ghost => Static, Global => null,
       Pre => Acceleration'First = 0
         and then Acceleration'Length <= MJ.Ancestor_Rows.Max_Dofs
         and then Acceleration'Length = MJ.Ancestor_Rows.Size (Pattern)
         and then (for all X of Acceleration => X in -1.0e10 .. 1.0e10)
         and then Mass'First = 0
         and then Mass'Length = Acceleration'Length * Acceleration'Length
         and then (for all X of Mass => X in -1.0e60 .. 1.0e60),
       Post => Model'Result'First = Acceleration'First
         and then Model'Result'Length = Acceleration'Length and then Work (Model'Result);
   procedure Multiply
     (Pattern : MJ.Ancestor_Rows.Pattern; Mass, Acceleration : Real_Array;
      Value : in out Real_Array; Accepted : out Boolean)
     with Global => null,
       Pre => Acceleration'First = 0
         and then Acceleration'Length <= MJ.Ancestor_Rows.Max_Dofs
         and then Acceleration'Length = MJ.Ancestor_Rows.Size (Pattern)
         and then (for all X of Acceleration => X in -1.0e10 .. 1.0e10)
         and then Mass'First = 0
         and then Mass'Length = Acceleration'Length * Acceleration'Length
         and then (for all X of Mass => X in -1.0e60 .. 1.0e60)
         and then Value'First = 0 and then Value'Length = Acceleration'Length,
       Post => (if Accepted then Work (Value) else Value = Value'Old);
   pragma Postcondition (Static => (if Accepted then Value = Model (Pattern, Mass, Acceleration)));
end MJ.Inverse_Mass;
