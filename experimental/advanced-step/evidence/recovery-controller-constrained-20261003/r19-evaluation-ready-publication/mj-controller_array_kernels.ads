with MJ.Types; use MJ.Types;
--  Component-only operations avoid importing the controller's configuration.
package MJ.Controller_Array_Kernels with SPARK_Mode is
   function Prefix (Source : Real_Array; Count : Natural) return Real_Array is
     (Source (0 .. Integer (Count)-1))
     with Global => null, Inline_Always,
       Pre => Source'First = 0 and then Int64 (Count) <= Int64 (Source'Length),
       Post => Prefix'Result'First = 0 and then Prefix'Result'Length = Count
         and then Prefix'Result = Source (0 .. Integer (Count)-1);
   procedure Copy_Prefix (Target : in out Real_Array; Source : Real_Array; Count : Natural)
     with Global => null, Inline_Always,
       Pre => Target'First = 0 and then Source'First = 0
         and then Int64 (Count) <= Int64 (Target'Length)
         and then Int64 (Count) <= Int64 (Source'Length),
       Post => (for all I in Target'Range =>
         Target (I) = (if I < Count then Source (I) else Target'Old (I)));
   procedure Publish_Acceleration
     (Target : in out Real_Array; Valid : out Boolean; Source : Real_Array; Count : Natural)
     with Global => null,
       Pre => Target'First = 0 and then Source'First = 0
         and then Int64 (Count) <= Int64 (Target'Length)
         and then Int64 (Count) <= Int64 (Source'Length),
       Post => Valid and then (for all I in Target'Range =>
         Target (I) = (if I < Count then Source (I) else Target'Old (I)));
end MJ.Controller_Array_Kernels;
