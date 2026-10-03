with MJ.Flex_Shell_Weights;

--  Owned contact-side producer matching mj_contactJacobian/diagApprox.
--  Negative=True is used only for the first Jacobian side, before expansion.
--  Both diagonal-weight sides use Negative=False. Geometry endpoints are
--  supplied by the parent; this producer accepts only actual flex endpoints.
package MJ.Flex_State.Response_Contacts with SPARK_Mode is
   package SW renames MJ.Flex_Shell_Weights;
   procedure Side (S : State; F : Natural; Element, Vertex, Opposite : Integer;
     Point : MJ.Rigid_Geometry.Vec; Negative : Boolean;
     Value : out SW.Endpoint; Result : out Status)
     with Global => null,
       Post => (if Result /= Success then Value.Count = 0)
         and then (if Result = Success then
           (for all J in 0 .. Integer (Value.Count) - 1 =>
              Value.Items (J).Body_Id < Body_Count (S)));
end MJ.Flex_State.Response_Contacts;
