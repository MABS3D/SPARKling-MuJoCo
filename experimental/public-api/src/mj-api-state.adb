package body MJ.API.State with SPARK_Mode is
   function From_Model (S : MJ.Models.Sizes) return Layout is
   begin
      return (1, S.Nq, S.Nv, S.Na, S.Nhistory, S.Nv, S.Nu, S.Nv,
              6 * S.Nbody, S.Neq, 3 * S.Nmocap, 4 * S.Nmocap,
              S.Nuserdata, S.Npluginstate);
   end From_Model;
   function Prefix_Size (L : Layout; Sig : Signature; N : Prefix_Count) return Int64 is
   begin
      if N = 0 then return 0; end if;
      declare E : constant Element := Element'Val (N - 1);
      begin
         return Prefix_Size (L, Sig, N - 1) +
           (if Includes (Sig, E) then Int64 (L (E)) else 0);
      end;
   end Prefix_Size;
   function State_Size (L : Layout; Sig : Signature) return Int64 is
      Size : Int64 := 0;
   begin
      for E in Element loop
         pragma Loop_Invariant (Static => Size = Prefix_Size (L, Sig, Element'Pos (E)));
         if Includes (Sig, E) then Size := Size + Int64 (L (E)); end if;
      end loop;
      return Size;
   end State_Size;
   procedure Prefix_Bound (L : Layout; A, B : Signature; N, K : Prefix_Count) is
   begin
      if N < K then
         Prefix_Bound (L, A, B, N, K - 1);
      elsif K > 0 then
         Prefix_Bound (L, A, B, N - 1, K - 1);
         declare E : constant Element := Element'Val (K - 1);
         begin
            pragma Assert (Static => (if Includes (A, E) then Includes (B, E)));
         end;
      end if;
   end Prefix_Bound;
   procedure Prior_Blocks (L : Layout; Sig : Signature; N : Prefix_Count) is
   begin
      for E in Element loop
         if Element'Pos (E) < N and then Includes (Sig, E) then
            Prefix_Bound (L, Sig, Sig, Element'Pos (E) + 1, N);
         end if;
         pragma Loop_Invariant (Static => (for all P in Element =>
           (if P <= E and then Element'Pos (P) < N and then Includes (Sig, P) then
             Offset (L, Sig, P) + Int64 (L (P)) <= Prefix_Size (L, Sig, N))));
      end loop;
   end Prior_Blocks;
   procedure Copy_Block (Source : Real_Array; Target : in out Real_Array;
                         Src, Dst, Count : Natural; As_Bool : Boolean := False) is
   begin
      for J in 0 .. Integer (Count) - 1 loop
         Target (Dst + J) := Stored (Source (Src + J), As_Bool);
         pragma Loop_Invariant (Static => (for all I in Target'Range =>
           (if I >= Dst and then Int64 (I) <= Int64 (Dst) + Int64 (J)
            then Target (I) = Stored (Source (Src + (I - Dst)), As_Bool)
            else Target (I) = Target'Loop_Entry (I))));
      end loop;
   end Copy_Block;
   procedure Preserve_Matches
     (L : Layout; A, B : Signature; Source, Before, After : Real_Array; Through : Prefix_Count) is
   begin
      Prior_Blocks (L, B, Through);
   end Preserve_Matches;
   procedure Extract_Block (L : Layout; Source_Sig, Target_Sig : Signature;
                            Source : Real_Array; Values : in out Real_Array; E : Element) is
      Before : constant Real_Array := Values with Ghost => Static;
   begin
         if Includes (Target_Sig, E) then
            Prefix_Bound (L, Target_Sig, Source_Sig, Element'Pos (E) + 1, 14);
            Prefix_Bound (L, Source_Sig, Source_Sig, Element'Pos (E) + 1, 14);
            Prefix_Bound (L, Target_Sig, Target_Sig, Element'Pos (E) + 1, 14);
            Prefix_Bound (L, Target_Sig, All_State, Element'Pos (E), 14);
            Prefix_Bound (L, Source_Sig, All_State, Element'Pos (E), 14);
            Prior_Blocks (L, Target_Sig, Element'Pos (E));
            Copy_Block (Source, Values, Natural (Offset (L, Source_Sig, E)),
                        Natural (Offset (L, Target_Sig, E)), L (E));
            Preserve_Matches (L, Source_Sig, Target_Sig, Source, Before, Values, Element'Pos (E));
         end if;
   end Extract_Block;
   procedure Extract_State (L : Layout; Source : Real_Array; Source_Sig : Signature;
                            Values : in out Real_Array; Target_Sig : Signature;
                            Result : out Status) is
   begin
      if not Valid (Source_Sig) or else not Valid (Target_Sig)
        or else not Subset (Target_Sig, Source_Sig) then
         Result := Invalid_Signature; return;
      end if;
      if Int64 (Source'Length) /= State_Size (L, Source_Sig)
        or else Int64 (Values'Length) /= State_Size (L, Target_Sig) then
         Result := Invalid_Size; return;
      end if;
      for E in Element loop
         Extract_Block (L, Source_Sig, Target_Sig, Source, Values, E);
         pragma Loop_Invariant (Static => Matches (L, Source_Sig, Target_Sig, Source, Values, Element'Pos (E) + 1));
      end loop;
      Result := Success;
   end Extract_State;
   procedure Get_State (L : Layout; Full : Real_Array; Sig : Signature;
                        Values : in out Real_Array; Result : out Status) is
   begin
      Extract_State (L, Full, All_State, Values, Sig, Result);
   end Get_State;
   procedure Set_State (L : Layout; Full : in out Real_Array; Sig : Signature;
                        Values : Real_Array; Result : out Status) is
   begin
      if not Valid (Sig) then Result := Invalid_Signature; return; end if;
      if Int64 (Full'Length) /= State_Size (L, All_State)
        or else Int64 (Values'Length) /= State_Size (L, Sig) then
         Result := Invalid_Size; return;
      end if;
      for E in Element loop
         if Includes (Sig, E) then
            Prefix_Bound (L, Sig, Sig, Element'Pos (E) + 1, 14);
            Prefix_Bound (L, All_State, All_State, Element'Pos (E) + 1, 14);
            Copy_Block (Values, Full, Natural (Offset (L, Sig, E)),
                        Natural (Offset (L, All_State, E)), L (E), E = Equality_Active);
         end if;
      end loop;
      Result := Success;
   end Set_State;
   procedure Copy_State (L : Layout; Source : Real_Array; Target : in out Real_Array;
                         Sig : Signature; Result : out Status) is
   begin
      if not Valid (Sig) then Result := Invalid_Signature; return; end if;
      if Int64 (Source'Length) /= State_Size (L, All_State)
        or else Int64 (Target'Length) /= State_Size (L, All_State) then
         Result := Invalid_Size; return;
      end if;
      for E in Element loop
         if Includes (Sig, E) then
            Prefix_Bound (L, Sig, Sig, Element'Pos (E) + 1, 14);
            Prefix_Bound (L, All_State, All_State, Element'Pos (E) + 1, 14);
            Copy_Block (Source, Target, Natural (Offset (L, All_State, E)),
                        Natural (Offset (L, All_State, E)), L (E), E = Equality_Active);
         end if;
      end loop;
      Result := Success;
   end Copy_State;
end MJ.API.State;
