pragma SPARK_Mode (On);
with MJ.SDF_Collisions;
with MJ.SDF_Provider;
package MJ.Builtin_SDF is new MJ.SDF_Collisions
  (Fields_Admitted => False, Custom_Query => MJ.SDF_Provider.Unavailable);
