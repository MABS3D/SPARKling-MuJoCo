with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Models;
package MJ.API.State with SPARK_Mode is
   use type Interfaces.Unsigned_32;
   type Element is (Time, Qpos, Qvel, Activation, History, Warmstart,
                    Control, Applied_Force, Body_Load, Equality_Active,
                    Mocap_Position, Mocap_Quaternion, User_Data, Plugin);
   subtype Signature is Interfaces.Unsigned_32;
   All_State : constant Signature := 16_383;
   Physics : constant Signature := 30;
   Full_Physics : constant Signature := Physics or 1 or 8_192;
   User_State : constant Signature := 8_128;
   Integration : constant Signature := All_State;
   subtype Width is Natural range 0 .. 6 * Max_Size;
   type Layout is array (Element) of Width;
   subtype Prefix_Count is Natural range 0 .. 14;
   function Valid (Sig : Signature) return Boolean is (Sig <= All_State)
     with Global => null;
   function Bit (E : Element) return Signature is (2 ** Element'Pos (E))
     with Global => null;
   function Includes (Sig : Signature; E : Element) return Boolean is
     ((Sig and Bit (E)) /= 0) with Global => null;
   function Subset (Small, Large : Signature) return Boolean is
     ((Small and Large) = Small) with Global => null;
   function From_Model (S : MJ.Models.Sizes) return Layout with Global => null,
     Post => From_Model'Result = Layout'(1, S.Nq, S.Nv, S.Na, S.Nhistory,
       S.Nv, S.Nu, S.Nv, 6 * S.Nbody, S.Neq, 3 * S.Nmocap,
       4 * S.Nmocap, S.Nuserdata, S.Npluginstate);
   function Prefix_Size (L : Layout; Sig : Signature; N : Prefix_Count) return Int64
     with Global => null, Subprogram_Variant => (Decreases => N),
       Post => Prefix_Size'Result in 0 .. Int64 (N) * Int64 (Width'Last);
   pragma Postcondition (Static => Prefix_Size'Result = (if N = 0 then 0 else
     Prefix_Size (L, Sig, N - 1)
       + (if Includes (Sig, Element'Val (N - 1)) then Int64 (L (Element'Val (N - 1))) else 0)));
   function State_Size (L : Layout; Sig : Signature) return Int64 with
     Global => null, Pre => Valid (Sig),
     Post => State_Size'Result = Prefix_Size (L, Sig, 14);
   function Offset (L : Layout; Sig : Signature; E : Element) return Int64 is
     (Prefix_Size (L, Sig, Element'Pos (E))) with Global => null;
   function Fits (L : Layout) return Boolean is
     (Prefix_Size (L, All_State, 14) <= Int64 (Natural'Last)) with Global => null;

   procedure Prefix_Bound (L : Layout; A, B : Signature; N, K : Prefix_Count)
     with Ghost => Static, Global => null,
     Pre => N <= K and then Subset (A, B),
     Post => Prefix_Size (L, A, N) <= Prefix_Size (L, B, K),
     Subprogram_Variant => (Decreases => K);
   procedure Prior_Blocks (L : Layout; Sig : Signature; N : Prefix_Count)
     with Ghost => Static, Global => null,
     Post => (for all E in Element =>
       (if Element'Pos (E) < N and then Includes (Sig, E) then
         Offset (L, Sig, E) + Int64 (L (E)) <= Prefix_Size (L, Sig, N)));
   function Stored (Value : Real; As_Bool : Boolean) return Real is
     (if As_Bool then (if Value = 0.0 then 0.0 else 1.0) else Value)
     with Global => null;
   function Matches (L : Layout; A, B : Signature; Source, Target : Real_Array;
                     Through : Prefix_Count; As_Bool : Boolean := False) return Boolean is
     (for all E in Element =>
       (if Element'Pos (E) < Through and then Includes (B, E) then
         Offset (L, A, E) + Int64 (L (E)) <= Int64 (Source'Length)
         and then Offset (L, B, E) + Int64 (L (E)) <= Int64 (Target'Length)
         and then (for all J in 0 .. Integer (L (E)) - 1 =>
           Target (Natural (Offset (L, B, E) + Int64 (J))) =
             Stored (Source (Natural (Offset (L, A, E) + Int64 (J))),
                     As_Bool and E = Equality_Active))))
     with Ghost => Static, Global => null,
     Pre => Fits (L) and then Valid (A) and then Valid (B) and then Subset (B, A)
       and then Source'First = 0 and then Target'First = 0
       and then Int64 (Source'Length) = Prefix_Size (L, A, 14)
       and then Int64 (Target'Length) = Prefix_Size (L, B, 14);
   procedure Preserve_Matches
     (L : Layout; A, B : Signature; Source, Before, After : Real_Array; Through : Prefix_Count)
     with Ghost => Static, Global => null,
     Pre => Fits (L) and then Valid (A) and then Valid (B) and then Subset (B, A)
       and then Source'First = 0 and then Before'First = 0 and then After'First = 0
       and then Int64 (Source'Length) = Prefix_Size (L, A, 14)
       and then Int64 (Before'Length) = Prefix_Size (L, B, 14)
       and then After'Length = Before'Length
       and then Matches (L, A, B, Source, Before, Through)
       and then (for all I in After'Range =>
         (if Int64 (I) < Prefix_Size (L, B, Through) then After (I) = Before (I))),
     Post => Matches (L, A, B, Source, After, Through);
   procedure Extract_Block (L : Layout; Source_Sig, Target_Sig : Signature;
                            Source : Real_Array; Values : in out Real_Array; E : Element)
     with Global => null, Inline,
     Pre => Fits (L) and then Valid (Source_Sig) and then Valid (Target_Sig)
       and then Subset (Target_Sig, Source_Sig)
       and then Source'First = 0 and then Values'First = 0
       and then Int64 (Source'Length) = Prefix_Size (L, Source_Sig, 14)
       and then Int64 (Values'Length) = Prefix_Size (L, Target_Sig, 14);
   pragma Precondition (Static => Matches (L, Source_Sig, Target_Sig, Source, Values, Element'Pos (E)));
   pragma Postcondition (Static => Matches (L, Source_Sig, Target_Sig, Source, Values, Element'Pos (E) + 1));
   --  Packed caller-owned storage in C state order; it supplies no missing
   --  physics producers. Equality-active values are normalized on writes.
   procedure Get_State (L : Layout; Full : Real_Array; Sig : Signature;
                        Values : in out Real_Array; Result : out Status) with
     Global => null, Pre => Fits (L) and then Full'First = 0 and then Values'First = 0,
     Post => (if Result /= Success then Values = Values'Old);
   pragma Postcondition (Static => (if Result = Success then
     Valid (Sig) and then Int64 (Full'Length) = Prefix_Size (L, All_State, 14)
       and then Int64 (Values'Length) = Prefix_Size (L, Sig, 14)
       and then Matches (L, All_State, Sig, Full, Values, 14)));
   procedure Extract_State (L : Layout; Source : Real_Array; Source_Sig : Signature;
                            Values : in out Real_Array; Target_Sig : Signature;
                            Result : out Status) with
     Global => null, Pre => Fits (L) and then Source'First = 0 and then Values'First = 0,
     Post => (if Result /= Success then Values = Values'Old);
   pragma Postcondition (Static => (if Result = Success then
     Valid (Source_Sig) and then Valid (Target_Sig) and then Subset (Target_Sig, Source_Sig)
       and then Int64 (Source'Length) = Prefix_Size (L, Source_Sig, 14)
       and then Int64 (Values'Length) = Prefix_Size (L, Target_Sig, 14)
       and then Matches (L, Source_Sig, Target_Sig, Source, Values, 14)));
   procedure Set_State (L : Layout; Full : in out Real_Array; Sig : Signature;
                        Values : Real_Array; Result : out Status) with
     Global => null, Pre => Fits (L) and then Full'First = 0 and then Values'First = 0,
     Post => (if Result /= Success then Full = Full'Old);
   procedure Copy_State (L : Layout; Source : Real_Array; Target : in out Real_Array;
                         Sig : Signature; Result : out Status) with
     Global => null, Pre => Fits (L) and then Source'First = 0 and then Target'First = 0,
     Post => (if Result /= Success then Target = Target'Old);
   procedure Copy_Block (Source : Real_Array; Target : in out Real_Array;
                         Src, Dst, Count : Natural; As_Bool : Boolean := False) with
     Global => null,
     Pre => Source'First = 0 and then Target'First = 0
       and then Int64 (Src) + Int64 (Count) <= Int64 (Source'Length)
       and then Int64 (Dst) + Int64 (Count) <= Int64 (Target'Length),
     Post => (for all I in Target'Range =>
       (if I >= Dst and then Int64 (I) < Int64 (Dst) + Int64 (Count)
        then Target (I) = Stored (Source (Src + (I - Dst)), As_Bool)
        else Target (I) = Target'Old (I)));
end MJ.API.State;
