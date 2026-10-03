with MJ.Types; use MJ.Types;
--  Component-only operations avoid importing the controller's configuration.
package MJ.Controller_Array_Kernels with SPARK_Mode is
   procedure Copy_Prefix (Target : in out Real_Array; Source : Real_Array; Count : Natural)
     with Global => null, Inline,
       Pre => Target'First = 0 and then Source'First = 0
         and then Int64 (Count) <= Int64 (Target'Length)
         and then Int64 (Count) <= Int64 (Source'Length),
       Post => (for all I in Target'Range =>
         Target (I) = (if I < Count then Source (I) else Target'Old (I)));
end MJ.Controller_Array_Kernels;
