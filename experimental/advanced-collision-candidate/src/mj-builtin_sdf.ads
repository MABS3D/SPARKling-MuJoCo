pragma SPARK_Mode (On);
with MJ.SDF_Collisions;
with MJ.SDF_Provider;
package MJ.Builtin_SDF is new MJ.SDF_Collisions (MJ.SDF_Provider.Unavailable);
