pragma SPARK_Mode (On);
with Native_Plugins;
with MJ.Plugin_Runtime;
package Test_Runtime is new MJ.Plugin_Runtime (Native_Plugins.Invoke);
