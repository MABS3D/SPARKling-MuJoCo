with MJ.Types; use MJ.Types;
with MJ.Spatial_Kernels; use MJ.Spatial_Kernels;

--  C-compatible contiguous cinert/cdof slabs. The helpers specify both exact
--  packed entries and preservation of every cell outside the written record.
package MJ.Spatial_Storage with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   function Load_Inertia (Source : Real_Array; Base : Natural) return Inertia
     with Global => null,
     Pre => Source'Length >= 10 and then Base >= Source'First
       and then Base <= Source'Last - 9
       and then (for all K in Inertia'Range => Source (Base + K) in -1.0e36 .. 1.0e36),
     Post => Bounded (Load_Inertia'Result, 1.0e36)
       and then (for all K in Inertia'Range => Load_Inertia'Result (K) = Source (Base + K));
   pragma Inline (Load_Inertia);
   procedure Store_Inertia (Target : in out Real_Array; Base : Natural; Value : Inertia)
     with Global => null,
     Pre => Target'Length >= 10 and then Base >= Target'First
       and then Base <= Target'Last - 9 and then Bounded (Value, 1.0e36),
     Post => Target'First = Target'First'Old and then Target'Last = Target'Last'Old
       and then (for all K in Inertia'Range => Target (Base + K) = Value (K))
       and then (for all K in Target'Range =>
         (if K < Base or else K > Base + 9 then Target (K) = Target'Old (K)));
   pragma Inline (Store_Inertia);
   function Load_Motion (Source : Real_Array; Base : Natural) return Motion
     with Global => null,
     Pre => Source'Length >= 6 and then Base >= Source'First
       and then Base <= Source'Last - 5
       and then (for all K in Motion'Range => Source (Base + K) in -1.0e12 .. 1.0e12),
     Post => Bounded (Load_Motion'Result, 1.0e12)
       and then (for all K in Motion'Range => Load_Motion'Result (K) = Source (Base + K));
   pragma Inline (Load_Motion);
   procedure Store_Motion (Target : in out Real_Array; Base : Natural; Value : Motion)
     with Global => null,
     Pre => Target'Length >= 6 and then Base >= Target'First
       and then Base <= Target'Last - 5 and then Bounded (Value, 1.0e12),
     Post => Target'First = Target'First'Old and then Target'Last = Target'Last'Old
       and then (for all K in Motion'Range => Target (Base + K) = Value (K))
       and then (for all K in Target'Range =>
         (if K < Base or else K > Base + 5 then Target (K) = Target'Old (K)));
   pragma Inline (Store_Motion);
end MJ.Spatial_Storage;
