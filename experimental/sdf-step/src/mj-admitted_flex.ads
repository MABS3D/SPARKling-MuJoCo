with MJ.Flex_Driver;
with MJ.SDF_Provider;
package MJ.Admitted_Flex is new MJ.Flex_Driver
  (Custom_Query => MJ.SDF_Provider.Unavailable, Fields_Admitted => True);
