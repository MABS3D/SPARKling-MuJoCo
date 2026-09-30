with MJ.Types; use MJ.Types;
with MJ.Actuator_Math; use MJ.Actuator_Math;
package MJ.Transmissions with SPARK_Mode is
   Max_Dof : constant := 4096;
   subtype Dof is Natural range 0 .. Max_Dof-1;
   subtype Count is Natural range 0 .. Max_Dof;
   type Columns is array (Natural range <>) of Dof;
   type Values is array (Natural range <>) of Scalar;
   subtype Row_Last is Integer range -1 .. Max_Dof-1;
   type Row (Last : Row_Last) is limited record
      N : Count := 0;
      Col : Columns (0 .. Last) := (others => 0);
      Val : Values (0 .. Last) := (others => 0.0);
   end record;
   type Dense_Row is array (Natural range <>) of Real;
   type Mask is array (Natural range <>) of Boolean;
   function Valid (R : Row; NV : Count) return Boolean is
     (R.N <= R.Col'Length and then R.N <= NV and then (for all K in 0 .. Integer (R.N)-1 => R.Col (K) < NV
       and then R.Val (K) in -1.0e71 .. 1.0e71
       and then (for all J in 0 .. K-1 => R.Col (J)<R.Col (K))))
     with Annotate => (GNATprove, Inline_For_Proof);
   -- Active CSR slices may start at any offset in a caller-owned workspace.
   function Valid (Col : Columns; Val : Values; NV : Count) return Boolean is
     (Col'First=Val'First and then Col'Last=Val'Last and then Col'First<=3*Max_Dof
       and then Col'Length<=NV and then Col'Last<3*Max_Dof
       and then (for all K in Col'Range => Col (K)<NV and then Val (K) in -1.0e71 .. 1.0e71
         and then (for all J in Col'First .. K-1 => Col (J)<Col (K))))
     with Annotate => (GNATprove, Inline_For_Proof);
   function Scalar_Length (Position, Gear : Input) return Scalar is (Position*Gear);
   function Dot (A, B : Vector) return Real with
     Pre => Bounded (A, 1.0e60) and then Bounded (B, 1.0e11),
     Post => Dot'Result = (A (0)*B (0)+A (1)*B (1))+A (2)*B (2)
       and then Dot'Result in -1.0e72 .. 1.0e72;
   -- Site Jacobian column is ordered x,y,z; wrench is already in world frame.
   function Site_Column (JP, JR, Force, Torque : Vector) return Scalar with
     Pre => Bounded (JP, 1.0e10) and then Bounded (JR, 1.0e10)
       and then Bounded (Force, 1.0e11) and then Bounded (Torque, 1.0e11),
     Post => Site_Column'Result = Dot (JP, Force)+Dot (JR, Torque);
   function Reference_Column (JP, JR, JP_Ref, JR_Ref, Force, Torque : Vector;
                              Common : Boolean; Translate, Rotate : Boolean) return Scalar with
     Pre => Bounded (JP, 1.0e10) and then Bounded (JR, 1.0e10)
       and then Bounded (JP_Ref, 1.0e10) and then Bounded (JR_Ref, 1.0e10)
       and then Bounded (Force, 1.0e11) and then Bounded (Torque, 1.0e11);
   pragma Postcondition (Static => Reference_Column'Result =
     (if Common then 0.0 else
       (if Translate then Dot ((JP (0)-JP_Ref (0),JP (1)-JP_Ref (1),JP (2)-JP_Ref (2)),Force) else 0.0)
       +(if Rotate then Dot ((JR (0)-JR_Ref (0),JR (1)-JR_Ref (1),JR (2)-JR_Ref (2)),Torque) else 0.0)));
   function Slider_Column (DA, DV, JA, JV : Vector) return Scalar with
     Pre => Bounded (DA, 1.0e60) and then Bounded (DV, 1.0e60)
       and then Bounded (JA, 1.0e10) and then Bounded (JV, 1.0e10),
     Post => Slider_Column'Result = ((0.0+(DA (0)*JA (0)+DV (0)*JV (0)))
       +(DA (1)*JA (1)+DV (1)*JV (1)))+(DA (2)*JA (2)+DV (2)*JV (2));
   -- Include each relevant active and gap contact once in Counter.
   function Adhesion_Column (Active, Gap : Real; Counter : Count) return Scalar with
     Pre => Active in -1.0e60 .. 1.0e60 and then Gap in -1.0e60 .. 1.0e60,
     Post => Adhesion_Column'Result = (if Counter=0 then 0.0 else (Active+Gap)*(-1.0/Real (Counter)));
   function Pyramidal_Weight (Dimension : Positive) return Real with
     Pre => Dimension in 2 .. 6,
     Post => Pyramidal_Weight'Result = 0.5/Real (Dimension-1);
   function Nonzeros (A : Dense_Row; N : Count) return Count is
     (if N=0 then 0 else Nonzeros (A,N-1)+(if A (N-1)/=0.0 then 1 else 0)) with
     Ghost => Static, Pre => A'First=0 and then A'Length<=Max_Dof and then N<=A'Length,
     Post => Nonzeros'Result<=N, Subprogram_Variant => (Decreases => N);
   procedure Rank_Bounds (A : Dense_Row; N : Count) with Ghost => Static,
     Pre => A'First=0 and then A'Length<=Max_Dof and then N<=A'Length,
     Post => (for all I in 0 .. Integer (N)-1 =>
       (if A (I)/=0.0 then Nonzeros (A,I)<Nonzeros (A,N))),
     Subprogram_Variant => (Decreases => N);
   procedure Compress (A : Dense_Row; Gear : Input; R : in out Row) with
     Pre => A'First=0 and then A'Length<=Max_Dof and then R.Col'Length>=A'Length
       and then (for all X of A => X in -1.0e60 .. 1.0e60),
     Post => Valid (R,A'Length);
   pragma Postcondition (Static => R.N=Nonzeros (A,A'Length)
     and then (for all J in A'Range => (if A (J)/=0.0 then
       R.Col (Nonzeros (A,J))=J and then R.Val (Nonzeros (A,J))=A (J)*Gear)));
   procedure Scale_Tendon (Source : Row; Gear : Input; Result : in out Row) with
     Pre => Valid (Source,Max_Dof) and then Result.Col'Length>=Source.N and then (for all K in 0 .. Integer (Source.N)-1 => Source.Val (K) in -1.0e60 .. 1.0e60),
     Post => Result.N=Source.N and then (for all K in 0 .. Integer (Source.N)-1 => Result.Col (K)=Source.Col (K))
       and then (for all K in 0 .. Integer (Source.N)-1 => Result.Val (K)=Source.Val (K)*Gear)
       and then Valid (Result,Max_Dof);
   procedure Compress_Into (A : Dense_Row; Gear : Input; Col : in out Columns; Val : in out Values; N : out Count) with
     Pre => A'First=0 and then A'Length<=Max_Dof and then Col'Length>=A'Length and then Col'First=Val'First and then Col'Last=Val'Last and then Col'First<=3*Max_Dof and then Col'Last<3*Max_Dof
       and then (for all X of A => X in -1.0e60 .. 1.0e60),
     Post => N<=A'Length and then Valid (Col (Col'First .. Col'First+Integer (N)-1),Val (Val'First .. Val'First+Integer (N)-1),A'Length);
   pragma Postcondition (Static => N=Nonzeros (A,A'Length)
     and then (for all J in A'Range => (if A (J)/=0.0 then
       Col (Col'First+Nonzeros (A,J))=J and then Val (Val'First+Nonzeros (A,J))=A (J)*Gear))
     and then (for all K in Col'First+Integer (N) .. Col'Last => Col (K)=Col'Old (K) and then Val (K)=Val'Old (K)));
   Step_Bound : constant Real := 2.0**280;
   subtype Sparse_Term is Real range -2.0e81 .. 2.0e81;
   function Sparse_Product (Moment, Speed : Real) return Sparse_Term with
     Pre => Moment in -1.0e71 .. 1.0e71 and then Speed in Input,
     Post => Sparse_Product'Result=Moment*Speed;
   subtype Sum_Value is Real range -1.0e90 .. 1.0e90;
   function Add (S : Sum_Value; V : Real; N : Count) return Sum_Value with
     Pre => N<Max_Dof and then abs S<=Real (N)*Step_Bound and then V in -1.0e82 .. 1.0e82,
     Post => Add'Result=S+V and then abs Add'Result<=Real (N+1)*Step_Bound;
   Lane_Step : constant Real := 2.0**275;
   function Lane_Add (S : Sum_Value; V : Real; N : Count) return Sum_Value with
     Pre => N<Max_Dof/4 and then abs S<=Real (N)*Lane_Step and then V in -1.0e82 .. 1.0e82,
     Post => Lane_Add'Result=S+V and then abs Lane_Add'Result<=Real (N+1)*Lane_Step;
   function Combine (S0, S1, S2, S3 : Sum_Value; Groups : Count) return Sum_Value with
     Pre => Groups<=Max_Dof/4 and then abs S0<=Real (Groups)*Lane_Step
       and then abs S1<=Real (Groups)*Lane_Step and then abs S2<=Real (Groups)*Lane_Step
       and then abs S3<=Real (Groups)*Lane_Step,
     Post => Combine'Result=(S0+S2)+(S1+S3)
       and then abs Combine'Result<=Real (4*Groups)*Step_Bound;
   function Lane_Model (Col : Columns; Val : Values; V : Real_Array; Lane : Natural; Groups : Count) return Sum_Value is
     (if Groups=0 then 0.0 else Lane_Add (Lane_Model (Col,Val,V,Lane,Groups-1),
       Sparse_Product (Val (Val'First+4*(Groups-1)+Lane),V (Col (Col'First+4*(Groups-1)+Lane))),Groups-1)) with
     Ghost => Static, Pre => V'First=0 and then V'Length<=Max_Dof and then Valid (Col,Val,V'Length)
       and then (for all X of V => X in Input) and then Lane<4 and then Groups<=Col'Length/4,
     Post => abs Lane_Model'Result<=Real (Groups)*Lane_Step,
     Subprogram_Variant => (Decreases => Groups);
   function Tail_Model (Col : Columns; Val : Values; V : Real_Array; Base : Sum_Value; First, N : Count) return Sum_Value is
     (if N=0 then Base else Add (Tail_Model (Col,Val,V,Base,First,N-1),
       Sparse_Product (Val (Val'First+First+N-1),V (Col (Col'First+First+N-1))),First+N-1)) with
     Ghost => Static, Pre => V'First=0 and then V'Length<=Max_Dof and then Valid (Col,Val,V'Length)
       and then (for all X of V => X in Input) and then First+N<=Col'Length
       and then N<=3 and then abs Base<=Real (First)*Step_Bound,
     Post => abs Tail_Model'Result<=Real (First+N)*Step_Bound,
     Subprogram_Variant => (Decreases => N);
   function Speed_Model (Col : Columns; Val : Values; V : Real_Array) return Sum_Value is
     (declare G : constant Count := Col'Length/4;
              Base : constant Sum_Value := Combine (Lane_Model (Col,Val,V,0,G),Lane_Model (Col,Val,V,1,G),
                Lane_Model (Col,Val,V,2,G),Lane_Model (Col,Val,V,3,G),G);
      begin Tail_Model (Col,Val,V,Base,4*G,Col'Length mod 4)) with
     Ghost => Static, Pre => V'First=0 and then V'Length<=Max_Dof and then Valid (Col,Val,V'Length)
       and then (for all X of V => X in Input);
   procedure Unfold_Lanes (Col : Columns; Val : Values; V : Real_Array; G : Count) with Ghost => Static,
     Pre => V'First=0 and then V'Length<=Max_Dof and then Valid (Col,Val,V'Length)
       and then (for all X of V => X in Input) and then G<Col'Length/4,
     Post => (for all L in 0 .. 3 => Lane_Model (Col,Val,V,L,G+1)=
       Lane_Add (Lane_Model (Col,Val,V,L,G),Sparse_Product (Val (Val'First+4*G+L),V (Col (Col'First+4*G+L))),G));
   procedure Unfold_Tail (Col : Columns; Val : Values; V : Real_Array; Base : Sum_Value; First, N : Count) with Ghost => Static,
     Pre => V'First=0 and then V'Length<=Max_Dof and then Valid (Col,Val,V'Length)
       and then (for all X of V => X in Input) and then First+N<Col'Length
       and then N<3 and then abs Base<=Real (First)*Step_Bound,
     Post => Tail_Model (Col,Val,V,Base,First,N+1)=Add (Tail_Model (Col,Val,V,Base,First,N),
       Sparse_Product (Val (Val'First+First+N),V (Col (Col'First+First+N))),First+N);
   function Velocity (Col : Columns; Val : Values; Qvel : Real_Array) return Sum_Value with
     Pre => Qvel'First=0 and then Qvel'Length<=Max_Dof and then Valid (Col,Val,Qvel'Length)
       and then (for all X of Qvel => X in Input);
   pragma Postcondition (Static => Velocity'Result=Speed_Model (Col,Val,Qvel));
   -- Caller iterates actuator output rows in C order; this updates only present columns.
   procedure Project (Col : Columns; Val : Values; Force : Input; Generalized : in out Real_Array) with
     Pre => Generalized'First=0 and then Generalized'Length<=Max_Dof
       and then Valid (Col,Val,Generalized'Length)
       and then (for all X of Generalized => X in -1.0e90 .. 1.0e90),
     Post => (for all J in Generalized'Range =>
       (if (for all K in Col'Range => Col (K)/=J) then Generalized (J)=Generalized'Old (J)))
       and then (for all K in Col'Range =>
         Generalized (Col (K))=Generalized'Old (Col (K))+Val (K)*Force);
   function Velocity (R : Row; Qvel : Real_Array) return Sum_Value with
     Pre => Qvel'First=0 and then Qvel'Length<=Max_Dof and then Valid (R,Qvel'Length)
       and then (for all X of Qvel => X in Input);
   pragma Postcondition (Static => Velocity'Result=Speed_Model
     (R.Col (0 .. Integer (R.N)-1),R.Val (0 .. Integer (R.N)-1),Qvel));
   procedure Project (R : Row; Force : Input; Generalized : in out Real_Array) with
     Pre => Generalized'First=0 and then Generalized'Length<=Max_Dof and then Valid (R,Generalized'Length)
       and then (for all X of Generalized => X in -1.0e90 .. 1.0e90),
     Post => (for all J in Generalized'Range =>
       (if (for all K in 0 .. Integer (R.N)-1 => R.Col (K)/=J) then Generalized (J)=Generalized'Old (J)))
       and then (for all K in 0 .. Integer (R.N)-1 =>
         Generalized (R.Col (K))=Generalized'Old (R.Col (K))+R.Val (K)*Force);
end MJ.Transmissions;
