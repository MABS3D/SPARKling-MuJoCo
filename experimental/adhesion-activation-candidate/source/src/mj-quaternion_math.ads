--  Local instantiation of the standard runtime, so release LTO sees Sqrt's body.
--  This uses the unmodified Ada runtime implementation and SPARK contract.
with Ada.Numerics.Generic_Elementary_Functions;
with MJ.Types;
package MJ.Quaternion_Math is new Ada.Numerics.Generic_Elementary_Functions (MJ.Types.Real);
