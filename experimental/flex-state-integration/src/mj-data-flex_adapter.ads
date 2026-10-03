with MJ.Flex_State;
package MJ.Data.Flex_Adapter with SPARK_Mode is
   --  Model topology must refer to the bodies represented by D. The adapter
   --  adds no ownership alias and does not weaken MJ.Data.Create's admission.
   procedure Update (D : Simulation; Flex : in out MJ.Flex_State.State;
                     Result : out MJ.Flex_State.Status)
     with Pre => Is_Ready (D) and Positions_Current (D)
       and MJ.Flex_State.Ready (Flex)
       and Body_Count (D) = MJ.Flex_State.Body_Count (Flex);
end MJ.Data.Flex_Adapter;
