with MJ.Flex_Shell_Weights;
with MJ.Flex_Response_Kernels;

--  A response is computed once, then must follow its contact during sorting.
--  This child does not publish into the parent's Engine or admit new models.
package MJ.Data.Constrained.Signed_Contacts with SPARK_Mode is
   package SW renames MJ.Flex_Shell_Weights;
   package RK renames MJ.Flex_Response_Kernels;
   type Input is record
      Jacobian0, Jacobian1, Diagonal0, Diagonal1 : SW.Endpoint;
   end record;
   type Response is record
      Width : Natural range 0 .. Max_V := 0;
      Columns : MJ.Constraint_Assembly.Column_Array (1 .. Max_V) := [others => 0];
      J : MJ.Constraint_Assembly.Matrix (1 .. 6, 1 .. Max_V) := [others => [others => 0.0]];
      Translation, Rotation : RK.Work := 0.0;
   end record;
   function Valid_Endpoint (Side : SW.Endpoint; Bodies : Natural) return Boolean is
     (for all K in 0 .. Integer (Side.Count)-1 =>
       Side.Items (K).Body_Id < Bodies and then Side.Items (K).Weight in RK.Body_Weight);
   procedure Build (E : Engine; Contact : MJ.Full_Contacts.Full_Contact;
     Weights : Input; Value : out Response; Result : out Status)
     with Global => null,
       Post => (if Result /= Success then Value = Response'(others => <>))
         and then (if Result = Success then
           (for all K in 1 .. Value.Width => Value.Columns (K) < Max_V));
end MJ.Data.Constrained.Signed_Contacts;
