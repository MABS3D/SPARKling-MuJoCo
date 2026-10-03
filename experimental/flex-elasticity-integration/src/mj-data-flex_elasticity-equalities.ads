with MJ.Constraint_Assembly;
--  FLEX edge rows consume the force model's owned CSR cache. The caller owns
--  equality activity, source IDs and ordering relative to all other rows.
package MJ.Data.Flex_Elasticity.Equalities with SPARK_Mode is
   package CA renames MJ.Constraint_Assembly;
   use type CA.Storage;
   type Response is record
      Weight : Nonneg_Tier0 := 0.0;
      Position : Tier1_Real := 0.0;
   end record;
   type Response_Array is array (Positive range <>) of Response;
   procedure Append_Edges
     (Model : Force_Model; Flex_Id, Eq_Id : Natural;
      Rows : in out CA.Storage; Responses : in out Response_Array;
      Result : out Status; Sparse : Boolean := True) with
     Global => null,
     Pre => CA.Valid (Rows) and then Responses'First = 1
       and then Responses'Length = Rows.Row_Cap,
     Post => (Static => CA.Valid (Rows) and then
       (if Result /= Success then Rows = Rows'Old and then Responses = Responses'Old));
   procedure Append_Edges
     (E : Engine; Flex_Id, Eq_Id : Natural;
      Rows : in out CA.Storage; Responses : in out Response_Array;
      Result : out Status; Sparse : Boolean := True) with
     Global => null,
     Pre => CA.Valid (Rows) and then Responses'First = 1
       and then Responses'Length = Rows.Row_Cap,
     Post => (Static => CA.Valid (Rows) and then
       (if Result /= Success then Rows = Rows'Old and then Responses = Responses'Old));
end MJ.Data.Flex_Elasticity.Equalities;
