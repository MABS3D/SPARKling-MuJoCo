package body MJ.Flex_Ancestors with SPARK_Mode is
   procedure Unfold_Pair (Parents : Int_Array; P0, P1 : Integer) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Merged_Count);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Links_Valid);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Descending_Column);
   begin
      null;
   end Unfold_Pair;
   procedure Unfold_Column (Parents : Int_Array; P0, P1 : Integer; K : Positive) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Descending_Column);
   begin
      null;
   end Unfold_Column;
   procedure Shift_Suffix (Parents : Int_Array; P0, P1 : Integer; Offset : Natural) is
   begin
      for K in Integer(Offset)+1 .. Parents'Length-1 loop
         Unfold_Column(Parents,P0,P1,K-Offset);
         pragma Loop_Invariant (Static => (for all J in Integer(Offset)+1 .. K =>
           Descending_Column(Parents,P0,P1,J-Offset)=Descending_Column(Parents,
             Step_Model(Parents,P0,P1).Next0,Step_Model(Parents,P0,P1).Next1,(J-Offset)-1)));
      end loop;
   end Shift_Suffix;
   procedure Last_Dof (Weld, Address, Width : Int_Array; B, Nv : Natural;
                       Value : out Address_Result) is
      W : constant Integer := Weld(B);
   begin
      Value := (others => <>);
      if W not in 0 .. Weld'Length-1 then return; end if;
      if Width(W)<0 then return; end if;
      if Width(W)=0 then Value:=(True,-1); return; end if;
      if Address(W) not in 0 .. Nv then return; end if;
      if Width(W)>Nv-Address(W) then return; end if;
      Value := (True,Address(W)+Width(W)-1);
   end Last_Dof;
   procedure Advance (Parents : Int_Array; P0, P1 : Integer; Value : out Step_Result) is
      P : constant Integer := Integer'Max(P0,P1);
   begin
      Value := (others => <>);
      if Parents(P) not in -1 .. P-1 then return; end if;
      Value := (True,P,(if P0=P then Parents(P0) else P0),
                (if P1=P then Parents(P1) else P1));
   end Advance;
   procedure Reverse_Chain (Source : Chain; Value : out Chain) is
   begin
      Value := Empty_Chain;
      Value.Count := Source.Count;
      for K in 0 .. Integer(Source.Count)-1 loop
         Value.Col(K) := Source.Col((Source.Count-K)-1);
         pragma Loop_Invariant (Static => (Value.Count=Source.Count));
         pragma Loop_Invariant (Static => (for all J in 0 .. K =>
           Value.Col(J)=Source.Col((Source.Count-J)-1)));
         pragma Loop_Invariant (Static => (for all J in K+1 .. Max_Dofs-1 => Value.Col(J)=0));
      end loop;
   end Reverse_Chain;
   procedure Merge (Parents : Int_Array; P0, P1 : Integer;
                    Value : out Chain; Result : out Status) is
      A : Integer := P0;
      B : Integer := P1;
      Desc : Chain := Empty_Chain;
      T : Step_Result;
   begin
      Value := Empty_Chain; Result := Invalid_Topology;
      while Integer'Max(A,B)>=0 loop
         pragma Loop_Invariant (Static => (A in -1 .. Parents'Length-1 and then B in -1 .. Parents'Length-1));
         pragma Loop_Invariant (Static => (Desc.Count<=(Parents'Length-Integer'Max(A,B))-1));
         pragma Loop_Invariant (Static => (for all K in 0 .. Integer(Desc.Count)-1 =>
           Desc.Col(K) in 0 .. Parents'Length-1 and then Desc.Col(K)>Integer'Max(A,B)));
         pragma Loop_Invariant (Static => (for all K in 1 .. Integer(Desc.Count)-1 =>
           Desc.Col(K)<Desc.Col(K-1)));
         pragma Loop_Invariant (Static => (Links_Valid(Parents,A,B)=Links_Valid(Parents,P0,P1)));
         pragma Loop_Invariant (Static => (if Links_Valid(Parents,P0,P1) then
           Desc.Count+Merged_Count(Parents,A,B)=Merged_Count(Parents,P0,P1)));
         pragma Loop_Invariant (Static => (for all K in 0 .. Integer(Desc.Count)-1 =>
           Desc.Col(K)=Descending_Column(Parents,P0,P1,K)));
         pragma Loop_Invariant (Static => (for all K in Integer(Desc.Count) .. Parents'Length-1 =>
           Descending_Column(Parents,P0,P1,K)=Descending_Column(Parents,A,B,K-Desc.Count)));
         pragma Loop_Variant (Decreases => Integer'Max(A,B));
         Unfold_Pair(Parents,A,B);
         Advance(Parents,A,B,T);
         if not T.Valid then return; end if;
         Shift_Suffix(Parents,A,B,Desc.Count);
         Desc.Col(Desc.Count) := T.Selected;
         Desc.Count := Desc.Count+1;
         A := T.Next0; B := T.Next1;
      end loop;
      Unfold_Pair(Parents,A,B);
      Reverse_Chain(Desc,Value);
      Result := Success;
   end Merge;
   procedure Build (Weld, Address, Width, Parents : Int_Array; B0, B1 : Natural;
                    Value : out Chain; Result : out Status) is
      A, B : Address_Result;
   begin
      Value:=Empty_Chain;Result:=Invalid_Topology;
      Last_Dof(Weld,Address,Width,B0,Parents'Length,A);
      Last_Dof(Weld,Address,Width,B1,Parents'Length,B);
      if not A.Valid or else not B.Valid then return; end if;
      Merge(Parents,A.Last,B.Last,Value,Result);
   end Build;
end MJ.Flex_Ancestors;
