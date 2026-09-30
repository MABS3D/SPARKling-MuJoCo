package body MJ.Transmissions with SPARK_Mode is
   subtype Large_Operand is Real range -1.0e60 .. 1.0e60;
   subtype Small_Operand is Real range -1.0e11 .. 1.0e11;
   subtype Term_Value is Real range -2.0e71 .. 2.0e71;
   subtype Pair_Value is Real range -5.0e71 .. 5.0e71;
   subtype Two_Pairs is Real range -1.0e73 .. 1.0e73;
   subtype Three_Pairs is Real range -1.0e74 .. 1.0e74;
   subtype Initial_Force is Real range -1.0e90 .. 1.0e90;
   subtype Updated_Force is Real range -1.0e91 .. 1.0e91;
   subtype Moment_Value is Real range -1.0e71 .. 1.0e71;
   function Product (A : Large_Operand; B : Small_Operand) return Term_Value is
     (A*B) with Post => Product'Result=A*B;
   function Add_Force (G : Initial_Force; V : Moment_Value; F : Input) return Updated_Force is
     (G+V*F) with Post => Add_Force'Result=G+V*F;
   function Scale_Moment (A : Large_Operand; Gear : Input) return Moment_Value is
     (A*Gear) with Post => Scale_Moment'Result=A*Gear;
   function Dot (A, B : Vector) return Real is
      P0 : constant Term_Value := Product (A (0),B (0));
      P1 : constant Term_Value := Product (A (1),B (1));
      P2 : constant Term_Value := Product (A (2),B (2));
      S : constant Pair_Value := P0+P1;
   begin return S+P2; end Dot;
   function Site_Column (JP, JR, Force, Torque : Vector) return Scalar is
   begin return Dot (JP,Force)+Dot (JR,Torque); end Site_Column;
   function Reference_Column (JP, JR, JP_Ref, JR_Ref, Force, Torque : Vector;
                              Common : Boolean; Translate, Rotate : Boolean) return Scalar is
   begin
      return (if Common then 0.0 else
        (if Translate then Dot ((JP (0)-JP_Ref (0),JP (1)-JP_Ref (1),JP (2)-JP_Ref (2)),Force) else 0.0)
        +(if Rotate then Dot ((JR (0)-JR_Ref (0),JR (1)-JR_Ref (1),JR (2)-JR_Ref (2)),Torque) else 0.0));
   end Reference_Column;
   function Slider_Column (DA, DV, JA, JV : Vector) return Scalar is
      P0 : constant Pair_Value := 0.0+(Product (DA (0),JA (0))+Product (DV (0),JV (0)));
      P1 : constant Pair_Value := Product (DA (1),JA (1))+Product (DV (1),JV (1));
      P2 : constant Pair_Value := Product (DA (2),JA (2))+Product (DV (2),JV (2));
      S1 : constant Two_Pairs := P0+P1;
      S2 : constant Three_Pairs := S1+P2;
   begin return S2; end Slider_Column;
   function Adhesion_Column (Active, Gap : Real; Counter : Count) return Scalar is
   begin
      if Counter=0 then return 0.0; end if;
      return (Active+Gap)*(-1.0/Real (Counter));
   end Adhesion_Column;
   function Pyramidal_Weight (Dimension : Positive) return Real is
   begin return 0.5/Real (Dimension-1); end Pyramidal_Weight;
   procedure Rank_Bounds (A : Dense_Row; N : Count) is
   begin
      if N>0 then Rank_Bounds (A,N-1); end if;
   end Rank_Bounds;
   procedure Compress (A : Dense_Row; Gear : Input; R : in out Row) is
   begin
      R.N := 0;
      for J in A'Range loop
         pragma Loop_Invariant (Static => R.N=Nonzeros (A,J));
         pragma Loop_Invariant (R.N<=J);
         pragma Loop_Invariant (for all K in 0 .. Integer (R.N)-1 => R.Col (K)<J
           and then R.Val (K) in -1.0e71 .. 1.0e71
           and then (for all I in 0 .. K-1 => R.Col (I)<R.Col (K)));
         pragma Loop_Invariant (Static => (for all I in 0 .. Integer (J)-1 => (if A (I)/=0.0 then
           Nonzeros (A,I)<R.N and then R.Col (Nonzeros (A,I))=I and then R.Val (Nonzeros (A,I))=A (I)*Gear)));
         Rank_Bounds (A,J+1);
         if A (J)/=0.0 then
            R.Col (R.N) := J;
            R.Val (R.N) := A (J)*Gear;
            R.N := R.N+1;
         end if;
      end loop;
   end Compress;
   procedure Compress_Into (A : Dense_Row; Gear : Input; Col : in out Columns; Val : in out Values; N : out Count) is
   begin
      N := 0;
      for J in A'Range loop
         pragma Loop_Invariant (Static => N=Nonzeros (A,J));
         pragma Loop_Invariant (N<=J);
         pragma Loop_Invariant (for all K in Col'First .. Col'First+Integer (N)-1 => Col (K)<J
           and then Val (K) in -1.0e71 .. 1.0e71
           and then (for all I in Col'First .. K-1 => Col (I)<Col (K)));
         pragma Loop_Invariant (Static => (for all I in 0 .. Integer (J)-1 => (if A (I)/=0.0 then
           Nonzeros (A,I)<N and then Col (Col'First+Nonzeros (A,I))=I and then Val (Val'First+Nonzeros (A,I))=A (I)*Gear)));
         pragma Loop_Invariant (for all K in Col'First+Integer (N) .. Col'Last => Col (K)=Col'Loop_Entry (K) and then Val (K)=Val'Loop_Entry (K));
         Rank_Bounds (A,J+1);
         if A (J)/=0.0 then
            Col (Col'First+N) := J;
            Val (Val'First+N) := Scale_Moment (A (J),Gear);
            N := N+1;
         end if;
      end loop;
   end Compress_Into;
   procedure Scale_Tendon (Source : Row; Gear : Input; Result : in out Row) is
   begin
      Result.N := Source.N;
      for K in 0 .. Integer (Source.N)-1 loop
         Result.Col (K) := Source.Col (K);
         Result.Val (K) := Source.Val (K)*Gear;
         pragma Loop_Invariant (Result.N=Source.N and then (for all J in 0 .. K => Result.Col (J)=Source.Col (J)));
         pragma Loop_Invariant (for all J in 0 .. K => Result.Val (J)=Source.Val (J)*Gear);
         pragma Loop_Invariant (for all J in K+1 .. Result.Col'Last => Result.Val (J)=Result.Val'Loop_Entry (J));
      end loop;
   end Scale_Tendon;
   function Add (S : Sum_Value; V : Real; N : Count) return Sum_Value is
   begin return S+V; end Add;
   function Sparse_Product (Moment, Speed : Real) return Sparse_Term is
      M : constant Moment_Value := Moment;
      V : constant Input := Speed;
   begin return M*V; end Sparse_Product;
   function Lane_Add (S : Sum_Value; V : Real; N : Count) return Sum_Value is
   begin return S+V; end Lane_Add;
   function Combine (S0, S1, S2, S3 : Sum_Value; Groups : Count) return Sum_Value is
      subtype Lane_Value is Real range -1.0e88 .. 1.0e88;
      subtype Pair_Sum is Real range -3.0e88 .. 3.0e88;
      A0 : constant Lane_Value := S0; A1 : constant Lane_Value := S1;
      A2 : constant Lane_Value := S2; A3 : constant Lane_Value := S3;
      P0 : constant Pair_Sum := A0+A2;
      P1 : constant Pair_Sum := A1+A3;
   begin return P0+P1; end Combine;
   procedure Unfold_Lanes (Col : Columns; Val : Values; V : Real_Array; G : Count) is
   begin null; end Unfold_Lanes;
   procedure Unfold_Tail (Col : Columns; Val : Values; V : Real_Array; Base : Sum_Value; First, N : Count) is
   begin null; end Unfold_Tail;
   function Velocity (Col : Columns; Val : Values; Qvel : Real_Array) return Sum_Value is
      S0, S1, S2, S3 : Sum_Value := 0.0;
      G : constant Count := Col'Length/4;
      First : constant Count := 4*G;
      Base, S : Sum_Value;
   begin
      for I in 0 .. Integer (G)-1 loop
         pragma Loop_Invariant (Static => S0=Lane_Model (Col,Val,Qvel,0,I) and then S1=Lane_Model (Col,Val,Qvel,1,I)
           and then S2=Lane_Model (Col,Val,Qvel,2,I) and then S3=Lane_Model (Col,Val,Qvel,3,I));
         pragma Loop_Invariant (abs S0<=Real (I)*Lane_Step and then abs S1<=Real (I)*Lane_Step
           and then abs S2<=Real (I)*Lane_Step and then abs S3<=Real (I)*Lane_Step);
         Unfold_Lanes (Col,Val,Qvel,I);
         S0 := Lane_Add (S0,Sparse_Product (Val (Val'First+4*I),Qvel (Col (Col'First+4*I))),I);
         S1 := Lane_Add (S1,Sparse_Product (Val (Val'First+4*I+1),Qvel (Col (Col'First+4*I+1))),I);
         S2 := Lane_Add (S2,Sparse_Product (Val (Val'First+4*I+2),Qvel (Col (Col'First+4*I+2))),I);
         S3 := Lane_Add (S3,Sparse_Product (Val (Val'First+4*I+3),Qvel (Col (Col'First+4*I+3))),I);
      end loop;
      Base := Combine (S0,S1,S2,S3,G); S := Base;
      for K in First .. Integer (Col'Length)-1 loop
         pragma Loop_Invariant (Static => S=Tail_Model (Col,Val,Qvel,Base,First,K-First));
         pragma Loop_Invariant (abs S<=Real (K)*Step_Bound);
         Unfold_Tail (Col,Val,Qvel,Base,First,K-First);
         S := Add (S,Sparse_Product (Val (Val'First+K),Qvel (Col (Col'First+K))),K);
      end loop;
      return S;
   end Velocity;
   procedure Project (Col : Columns; Val : Values; Force : Input; Generalized : in out Real_Array) is
   begin
      if Force=0.0 then return; end if;
      for K in Col'Range loop
         pragma Assert (for all I in Col'First .. K-1 => Col (I)<Col (K));
         pragma Assert (Generalized (Col (K))=Generalized'Loop_Entry (Col (K)));
         Generalized (Col (K)) := Add_Force (Generalized (Col (K)),Val (K),Force);
         pragma Loop_Invariant (for all J in Generalized'Range =>
           (if (for all I in Col'First .. K => Col (I)/=J) then Generalized (J)=Generalized'Loop_Entry (J)));
         pragma Loop_Invariant (for all J in Generalized'Range => Generalized'Loop_Entry (J) in -1.0e90 .. 1.0e90);
         pragma Loop_Invariant (for all I in Col'First .. K =>
           Generalized (Col (I))=Add_Force (Generalized'Loop_Entry (Col (I)),Val (I),Force));
         pragma Loop_Invariant (for all J in Generalized'Range => Generalized (J) in -1.0e91 .. 1.0e91);
      end loop;
   end Project;
   function Velocity (R : Row; Qvel : Real_Array) return Sum_Value is
   begin return Velocity (R.Col (0 .. Integer (R.N)-1),R.Val (0 .. Integer (R.N)-1),Qvel); end Velocity;
   procedure Project (R : Row; Force : Input; Generalized : in out Real_Array) is
   begin Project (R.Col (0 .. Integer (R.N)-1),R.Val (0 .. Integer (R.N)-1),Force,Generalized); end Project;
end MJ.Transmissions;
