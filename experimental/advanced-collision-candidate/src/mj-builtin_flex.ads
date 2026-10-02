pragma SPARK_Mode (On);
with MJ.Flex_Driver;
with MJ.SDF_Provider;
package MJ.Builtin_Flex is new MJ.Flex_Driver (MJ.SDF_Provider.Unavailable);
