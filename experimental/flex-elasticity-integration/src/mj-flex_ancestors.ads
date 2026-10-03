with MJ.Types; use MJ.Types;

--  Flat compiled-topology kernel corresponding to mj_mergeChain(..., 0).
--  C's negative last address for an immovable weld root is represented by -1.
package MJ.Flex_Ancestors with SPARK_Mode is
   Max_Dofs : constant := 256;
   type Columns is array (Natural range 0 .. Max_Dofs-1) of Natural;
   type Chain is record
      Count : Natural range 0 .. Max_Dofs := 0;
      Col : Columns := [others => 0];
   end record;
   Empty_Chain : constant Chain := (others => <>);
   function Valid_Chain (Value : Chain; Nv : Natural) return Boolean is
     (Value.Count<=Nv and then
      (for all K in 0 .. Integer(Value.Count)-1 => Value.Col(K) in 0 .. Nv-1)
      and then (for all K in 1 .. Integer(Value.Count)-1 => Value.Col(K-1)<Value.Col(K)))
     with Ghost => Static, Pre => Nv<=Max_Dofs;
   type Status is (Success, Invalid_Topology);
   type Address_Result is record
      Valid : Boolean := False;
      Last : Integer := -1;
   end record;
   type Step_Result is record
      Valid : Boolean := False;
      Selected, Next0, Next1 : Integer := -1;
   end record;

   function Body_Shape (Weld, Address, Width : Int_Array) return Boolean is
     (Weld'First=0 and then Address'First=0 and then Width'First=0
      and then Weld'Length<=Int64(Integer'Last)
      and then Weld'Length=Address'Length and then Weld'Length=Width'Length)
     with Ghost;
   function Body_Model (Weld, Address, Width : Int_Array; B, Nv : Natural)
     return Address_Result is
     (if Weld(B) not in 0 .. Weld'Length-1 then (False,-1)
      elsif Width(Weld(B)) < 0 then (False,-1)
      elsif Width(Weld(B)) = 0 then (True,-1)
      elsif Address(Weld(B)) not in 0 .. Nv then (False,-1)
      elsif Width(Weld(B)) > Nv-Address(Weld(B)) then (False,-1)
      else (True,(Address(Weld(B))+Width(Weld(B)))-1))
     with Ghost => Static, Pre => Body_Shape(Weld,Address,Width) and then B<Weld'Length
       and then Nv<=Max_Dofs,
       Post => (if Body_Model'Result.Valid then Body_Model'Result.Last in -1 .. Nv-1);
   function Step_Model (Parents : Int_Array; P0, P1 : Integer) return Step_Result is
     (if Parents(Integer'Max(P0,P1)) not in -1 .. Integer'Max(P0,P1)-1
      then (others => <>)
      else (True,Integer'Max(P0,P1),
        (if P0>=P1 then Parents(P0) else P0),
        (if P1>=P0 then Parents(P1) else P1)))
     with Ghost, Pre => Parents'First=0 and then Parents'Length<=Max_Dofs
       and then P0 in -1 .. Parents'Length-1 and then P1 in -1 .. Parents'Length-1
       and then Integer'Max(P0,P1)>=0;
   function Merged_Count (Parents : Int_Array; P0, P1 : Integer) return Natural is
     (if Integer'Max(P0,P1)<0 then 0
      elsif not Step_Model(Parents,P0,P1).Valid then 0
      else 1+Merged_Count(Parents,Step_Model(Parents,P0,P1).Next0,
                         Step_Model(Parents,P0,P1).Next1))
     with Ghost => Static, Pre => Parents'First=0 and then Parents'Length<=Max_Dofs
       and then P0 in -1 .. Parents'Length-1 and then P1 in -1 .. Parents'Length-1,
       Post => Merged_Count'Result<=Integer'Max(P0,P1)+1,
       Subprogram_Variant => (Decreases => Integer'Max(P0,P1)),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Links_Valid (Parents : Int_Array; P0, P1 : Integer) return Boolean is
     (Integer'Max(P0,P1)<0 or else (Step_Model(Parents,P0,P1).Valid and then
        Links_Valid(Parents,Step_Model(Parents,P0,P1).Next0,
                    Step_Model(Parents,P0,P1).Next1)))
     with Ghost => Static, Pre => Parents'First=0 and then Parents'Length<=Max_Dofs
       and then P0 in -1 .. Parents'Length-1 and then P1 in -1 .. Parents'Length-1,
       Subprogram_Variant => (Decreases => Integer'Max(P0,P1)),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Descending_Column (Parents : Int_Array; P0, P1 : Integer; K : Natural)
     return Integer is
     (if Integer'Max(P0,P1)<0 then -1
      elsif not Step_Model(Parents,P0,P1).Valid then -1
      elsif K=0 then Step_Model(Parents,P0,P1).Selected
      else Descending_Column(Parents,Step_Model(Parents,P0,P1).Next0,
                             Step_Model(Parents,P0,P1).Next1,K-1))
     with Ghost => Static,
       Pre => Parents'First=0 and then Parents'Length<=Max_Dofs
         and then P0 in -1 .. Parents'Length-1 and then P1 in -1 .. Parents'Length-1,
       Subprogram_Variant => (Decreases => K),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   --  These lemmas prove one unfolding step; their bodies are checked and
   --  static ghost calls add no admission or per-step runtime work.
   procedure Unfold_Pair (Parents : Int_Array; P0, P1 : Integer) with
     Ghost => Static, Global => null,
     Pre => Parents'First=0 and then Parents'Length<=Max_Dofs
       and then P0 in -1 .. Parents'Length-1 and then P1 in -1 .. Parents'Length-1,
     Post => (if Integer'Max(P0,P1)<0 then
       Links_Valid(Parents,P0,P1) and then Merged_Count(Parents,P0,P1)=0
       else Links_Valid(Parents,P0,P1)=
         (Step_Model(Parents,P0,P1).Valid and then Links_Valid(Parents,
           Step_Model(Parents,P0,P1).Next0,Step_Model(Parents,P0,P1).Next1))
         and then (if Step_Model(Parents,P0,P1).Valid then
           Merged_Count(Parents,P0,P1)=1+Merged_Count(Parents,
             Step_Model(Parents,P0,P1).Next0,Step_Model(Parents,P0,P1).Next1)
           and then Descending_Column(Parents,P0,P1,0)=Integer'Max(P0,P1)));
   procedure Unfold_Column (Parents : Int_Array; P0, P1 : Integer; K : Positive) with
     Ghost => Static, Global => null,
     Pre => Parents'First=0 and then Parents'Length<=Max_Dofs
       and then P0 in -1 .. Parents'Length-1 and then P1 in -1 .. Parents'Length-1
       and then Integer'Max(P0,P1)>=0 and then Step_Model(Parents,P0,P1).Valid,
     Post => Descending_Column(Parents,P0,P1,K)=Descending_Column(Parents,
       Step_Model(Parents,P0,P1).Next0,Step_Model(Parents,P0,P1).Next1,K-1);
   procedure Shift_Suffix (Parents : Int_Array; P0, P1 : Integer; Offset : Natural) with
     Ghost => Static, Global => null,
     Pre => Parents'First=0 and then Parents'Length<=Max_Dofs
       and then P0 in -1 .. Parents'Length-1 and then P1 in -1 .. Parents'Length-1
       and then Integer'Max(P0,P1)>=0 and then Step_Model(Parents,P0,P1).Valid
       and then Offset<Parents'Length,
     Post => (for all K in Integer(Offset)+1 .. Parents'Length-1 =>
       Descending_Column(Parents,P0,P1,K-Offset)=Descending_Column(Parents,
         Step_Model(Parents,P0,P1).Next0,Step_Model(Parents,P0,P1).Next1,(K-Offset)-1));

   procedure Last_Dof (Weld, Address, Width : Int_Array; B, Nv : Natural;
                       Value : out Address_Result)
     with Global => null, Pre => (Static => Body_Shape(Weld,Address,Width)
       and then B<Weld'Length and then Nv<=Max_Dofs),
       Post => (Static => Value=Body_Model(Weld,Address,Width,B,Nv)
         and then (if Value.Valid then Value.Last in -1 .. Nv-1));
   procedure Advance (Parents : Int_Array; P0, P1 : Integer; Value : out Step_Result)
     with Global => null, Pre => (Static => Parents'First=0 and then Parents'Length<=Max_Dofs
       and then P0 in -1 .. Parents'Length-1 and then P1 in -1 .. Parents'Length-1
       and then Integer'Max(P0,P1)>=0),
       Post => (Static => Value=Step_Model(Parents,P0,P1)
         and then (if Value.Valid then Value.Selected in 0 .. Parents'Length-1
           and then Value.Next0 in -1 .. Value.Selected-1
           and then Value.Next1 in -1 .. Value.Selected-1));
   procedure Reverse_Chain (Source : Chain; Value : out Chain)
     with Global => null, Post => (Static => Value.Count=Source.Count
       and then (for all K in 0 .. Integer(Value.Count)-1 =>
         Value.Col(K)=Source.Col((Source.Count-K)-1))
       and then (for all K in Integer(Value.Count) .. Max_Dofs-1 => Value.Col(K)=0));
   procedure Merge (Parents : Int_Array; P0, P1 : Integer;
                    Value : out Chain; Result : out Status)
     with Global => null, Pre => (Static => Parents'First=0 and then Parents'Length<=Max_Dofs
       and then P0 in -1 .. Parents'Length-1 and then P1 in -1 .. Parents'Length-1),
       Post => (Static => (Result=Success)=Links_Valid(Parents,P0,P1)
         and then (if Result=Success then Valid_Chain(Value,Parents'Length)
           and then Value.Count=Merged_Count(Parents,P0,P1)
           and then (for all K in 0 .. Integer(Value.Count)-1 =>
             Value.Col(K)=Descending_Column(Parents,P0,P1,(Value.Count-K)-1))
           else Value=Empty_Chain));
   procedure Build (Weld, Address, Width, Parents : Int_Array; B0, B1 : Natural;
                    Value : out Chain; Result : out Status)
     with Global => null, Pre => (Static => Body_Shape(Weld,Address,Width)
       and then B0<Weld'Length and then B1<Weld'Length
       and then Parents'First=0 and then Parents'Length<=Max_Dofs),
       Post => (Static => (Result=Success)=
         (Body_Model(Weld,Address,Width,B0,Parents'Length).Valid and then
          Body_Model(Weld,Address,Width,B1,Parents'Length).Valid and then
          Links_Valid(Parents,Body_Model(Weld,Address,Width,B0,Parents'Length).Last,
            Body_Model(Weld,Address,Width,B1,Parents'Length).Last))
         and then (if Result=Success then Valid_Chain(Value,Parents'Length)
           and then Value.Count=Merged_Count(Parents,
           Body_Model(Weld,Address,Width,B0,Parents'Length).Last,
           Body_Model(Weld,Address,Width,B1,Parents'Length).Last)
           and then (for all K in 0 .. Integer(Value.Count)-1 =>
             Value.Col(K)=Descending_Column(Parents,
               Body_Model(Weld,Address,Width,B0,Parents'Length).Last,
               Body_Model(Weld,Address,Width,B1,Parents'Length).Last,(Value.Count-K)-1))
           else Value=Empty_Chain));
end MJ.Flex_Ancestors;
