with MJ.Types; use MJ.Types;
with MJ.Constraint_Assembly;

--  MuJoCo 3.14.0 mj_instantiateFriction / mj_instantiateLimit.
--  Exact binary64 row arithmetic; the caller supplies owned tendon kinematics.
package MJ.Tendon_Constraint_Kernels with SPARK_Mode is
   package CA renames MJ.Constraint_Assembly;
   use type CA.Limit_Side, CA.Result, CA.Storage;
   function Distance (Length, Bound : Tier0_Real; Side : CA.Limit_Side)
     return Tier1_Real with Global => null,
     Post => Distance'Result =
       (if Side = CA.Lower then -1.0 else 1.0) * (Bound - Length);
   function Scale (Side : CA.Limit_Side) return Real is
     (if Side = CA.Lower then 1.0 else -1.0);
   function Signed_Value (Value : Tier2_Real; Side : CA.Limit_Side)
     return Tier2_Real with Global => null,
     Post => Signed_Value'Result = Scale (Side) * Value
       and then Signed_Value'Result = (if Side = CA.Lower then Value else -Value);
   procedure Build_Row (Values : CA.Value_Array; Side : CA.Limit_Side;
                        J : out CA.Matrix) with
     Global => null,
     Relaxed_Initialization => J,
     Pre => Values'First = 1 and then Values'Length <= CA.Max_Dofs
       and then J'First (1) = 1 and then J'Length (1) = 1
       and then J'First (2) = 1 and then J'Length (2) = Values'Length,
     Post => J'Initialized and then
       (for all K in Values'Range => J (1, K) = Signed_Value (Values (K), Side));
   procedure Add_Friction (B : in out CA.Storage; Id : Natural;
                           Chain : CA.Column_Array; Values : CA.Value_Array;
                           Loss : Nonneg_Tier0; Result : out CA.Result) with
     Global => null,
     Pre => CA.Valid (B) and then CA.Valid_Chain (Chain, B.Dofs)
       and then Values'First = 1 and then Values'Length = Chain'Length,
     Post => (Static => CA.Valid (B) and then B.Dofs = B.Dofs'Old
       and then (if Loss = 0.0 or else Chain'Length = 0 then Result = CA.Skipped
         elsif not CA.Fits (B'Old, 1, Chain'Length) then Result = CA.Capacity_Limit
         else Result = CA.Success)
       and then (if Result /= CA.Success then B = B'Old));
   pragma Postcondition (Static => (if Result = CA.Success then
     B.Rows = B.Rows'Old + 1 and then B.Nf = B.Nf'Old + 1
       and then B.Ne = B.Ne'Old and then B.Nl = B.Nl'Old));
   pragma Postcondition (Static => (if Result = CA.Success then
     CA.Row_Is (B.Descriptors (B.Rows), B.Used'Old, Chain'Length,
       (0.0, 0.0), Loss, CA.Friction_Tendon, Id)));
   pragma Postcondition (Static => (if Result = CA.Success then
     (for all K in Values'Range => B.Values (B.Used'Old + K) = Values (K))));
   procedure Add_Limit (B : in out CA.Storage; Id : Natural;
                        Chain : CA.Column_Array; Values : CA.Value_Array;
                        Length, Bound, Margin : Tier0_Real;
                        Side : CA.Limit_Side; Result : out CA.Result) with
     Global => null,
     Pre => CA.Valid (B) and then CA.Valid_Chain (Chain, B.Dofs)
       and then Values'First = 1 and then Values'Length = Chain'Length,
     Post => (Static => CA.Valid (B) and then B.Dofs = B.Dofs'Old
       and then (if Distance (Length, Bound, Side) >= Margin or else Chain'Length = 0
         then Result = CA.Skipped
         elsif not CA.Fits (B'Old, 1, Chain'Length) then Result = CA.Capacity_Limit
         else Result = CA.Success)
       and then (if Result /= CA.Success then B = B'Old));
   pragma Postcondition (Static => (if Result = CA.Success then
     B.Rows = B.Rows'Old + 1 and then B.Nl = B.Nl'Old + 1
       and then B.Ne = B.Ne'Old and then B.Nf = B.Nf'Old));
   pragma Postcondition (Static => (if Result = CA.Success then
     CA.Row_Is (B.Descriptors (B.Rows), B.Used'Old, Chain'Length,
       (Distance (Length, Bound, Side), Margin), 0.0, CA.Limit_Tendon, Id)));
   pragma Postcondition (Static => (if Result = CA.Success then
     (for all K in Values'Range => B.Values (B.Used'Old + K) = Signed_Value (Values (K), Side))));
end MJ.Tendon_Constraint_Kernels;
