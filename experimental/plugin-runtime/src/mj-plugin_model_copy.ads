with MJ.Models;
package MJ.Plugin_Model_Copy with SPARK_Mode is
   --  An independent owned projection for the smooth subengine. Source stays intact.
   procedure Build (Source : MJ.Models.Model; Base : in out MJ.Models.Model)
     with Pre => MJ.Models.Valid_Layout (Source) and then MJ.Models.All_Null (Base);
end MJ.Plugin_Model_Copy;
