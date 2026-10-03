with MJ.Flex_Node_Weights;
with MJ.Flex_Shell_Weights;

--  Owned-state adapter for signed shell interpolation. This only produces
--  one contact endpoint; the dynamics/equality admission remains the caller's
--  responsibility. Positive interpolation keeps its separate 27-entry adapter.
package MJ.Flex_State.Shell_Contacts with SPARK_Mode is
   package NW renames MJ.Flex_Node_Weights;
   package SW renames MJ.Flex_Shell_Weights;
   type Vertex_Ids is array (NW.Vertex_Index) of Natural;

   procedure Weights (S : State; F : Natural; Vertices : Vertex_Ids;
     Coefficients : NW.Vertex_Weights; Count : NW.Vertex_Count;
     Value : out SW.Endpoint; Result : out Status)
     with Global => null,
       Post => (if Result /= Success then Value.Count = 0)
         and then (if Result = Success then
           (for all J in 0 .. Integer (Value.Count) - 1 =>
             Value.Items (J).Body_Id < Body_Count (S)));
end MJ.Flex_State.Shell_Contacts;
