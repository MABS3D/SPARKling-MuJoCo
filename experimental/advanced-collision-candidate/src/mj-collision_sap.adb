package body MJ.Collision_SAP with SPARK_Mode is
   type Event is record
      Value : Float;
      Id : Natural;
      Is_Max : Boolean;
   end record;
   function Before (A,B : Event) return Boolean is
     (A.Value<B.Value or else (A.Value=B.Value and not A.Is_Max and B.Is_Max));
   procedure Sweep (B : MJ.BVH.Box_Array; Active : Mask_Array; K : Axis;
                    Pairs : out MJ.BVH.Pair_Array; Count : out Natural; Result : out Status) is
      type Events_Array is array (Natural range 0 .. 2*MJ.BVH.Max_Leaves-1) of Event with Relaxed_Initialization;
      Events, Tmp : Events_Array;
      List : array (Natural range 0 .. MJ.BVH.Max_Leaves-1) of Natural := [others=>0];
      N, N_Active : Natural:=0;
      Width, Lo, Mid, Hi, I,J,Dest, Pos : Natural;
      First, Second : Natural;
      Hit : Boolean;
   begin
      Count:=0; Result:=Invalid_Input;
      if B'Length>MJ.BVH.Max_Leaves or else B'First/=0 or else B'First/=Active'First or else B'Last/=Active'Last
        or else (for some X of B => not MJ.BVH.Valid (X)) then return; end if;
      for A in B'Range loop
         pragma Loop_Invariant (for all Q in 0 .. N-1 => Events (Q)'Initialized);
         if Active (A) then
            Events (N):=(Float (B (A).Center (K)-B (A).Half (K)),A,False);
            Events (N+1):=(Float (B (A).Center (K)+B (A).Half (K)),A,True); N:=N+2;
         end if;
      end loop;
      Result:=Success; if N<4 then return; end if;
      --  Stable merge sort; C also compares rounded binary32 endpoints,
      --  and orders minima before maxima at coincident endpoints.
      Width:=1;
      while Width<N loop
         pragma Loop_Invariant (for all Q in 0 .. N-1 => Events (Q)'Initialized);
         Lo:=0;
         while Lo<N loop
            pragma Loop_Invariant (for all Q in 0 .. Lo-1 => Tmp (Q)'Initialized);
            Mid:=Natural'Min (N,Lo+Width); Hi:=Natural'Min (N,Lo+2*Width);
            I:=Lo; J:=Mid; Dest:=Lo;
            while I<Mid or J<Hi loop
               pragma Loop_Invariant (for all Q in 0 .. Dest-1 => Tmp (Q)'Initialized);
               if J=Hi or else (I<Mid and then not Before (Events (J),Events (I))) then
                  Tmp (Dest):=Events (I); I:=I+1;
               else Tmp (Dest):=Events (J); J:=J+1; end if;
               Dest:=Dest+1;
            end loop;
            Lo:=Hi;
         end loop;
         Events (0 .. N-1):=Tmp (0 .. N-1); Width:=Width*2;
      end loop;
      pragma Assert (for all Q in 0 .. N-1 => Events (Q)'Initialized);
      for Q in 0 .. N-1 loop
         Second:=Events (Q).Id;
         if not Events (Q).Is_Max then
            for L in 0 .. N_Active-1 loop
               First:=List (L); Hit:=True;
               for Axis_Other in Axis loop
                  if Axis_Other/=K and then
                    (B (First).Center (Axis_Other)-B (First).Half (Axis_Other)>
                       B (Second).Center (Axis_Other)+B (Second).Half (Axis_Other)
                     or else B (Second).Center (Axis_Other)-B (Second).Half (Axis_Other)>
                       B (First).Center (Axis_Other)+B (First).Half (Axis_Other)) then Hit:=False; end if;
               end loop;
               if Hit then
                  if Count=Pairs'Length then Result:=Capacity_Limit; Count:=0; return; end if;
                  Pairs (Pairs'First+Count):=(First,Second); Count:=Count+1;
               end if;
            end loop;
            List (N_Active):=Second; N_Active:=N_Active+1;
         else
            Pos:=0;
            while Pos<N_Active and then List (Pos)/=Second loop Pos:=Pos+1; end loop;
            if Pos=N_Active then Result:=Invalid_Input; Count:=0; return; end if;
            for L in Pos .. N_Active-2 loop List (L):=List (L+1); end loop;
            N_Active:=N_Active-1;
         end if;
      end loop;
   end Sweep;
end MJ.Collision_SAP;
