with MJ.Types; use MJ.Types;
with MJ.Actuator_Math; use MJ.Actuator_Math;
package MJ.Transmissions with SPARK_Mode is
   Max_Dof : constant := 4096;
   subtype Dof is Natural range 0 .. Max_Dof-1;
   subtype Count is Natural range 0 .. Max_Dof;
   type Columns is array (Dof) of Dof;
   type Values is array (Dof) of Scalar;
   type Row is record
      N : Count := 0;
      Col : Columns := (others => 0);
      Val : Values := (others => 0.0);
   end record;
   type Dense_Row is array (Natural range <>) of Real;
   type Mask is array (Natural range <>) of Boolean;
   function Valid (R : Row; NV : Count) return Boolean is
     (R.N <= NV and then (for all K in 0 .. Integer (R.N)-1 => R.Col (K) < NV
       and then R.Val (K) in -1.0e71 .. 1.0e71
       and then (for all J in 0 .. K-1 => R.Col (J)<R.Col (K))))
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
   procedure Compress (A : Dense_Row; Gear : Input; R : out Row) with
     Pre => A'First=0 and then A'Length<=Max_Dof
       and then (for all X of A => X in -1.0e60 .. 1.0e60),
     Post => Valid (R,A'Length);
   pragma Postcondition (Static => R.N=Nonzeros (A,A'Length)
     and then (for all J in A'Range => (if A (J)/=0.0 then
       R.Col (Nonzeros (A,J))=J and then R.Val (Nonzeros (A,J))=A (J)*Gear)));
   procedure Scale_Tendon (Source : Row; Gear : Input; Result : out Row) with
     Pre => Valid (Source,Max_Dof) and then (for all K in 0 .. Integer (Source.N)-1 => Source.Val (K) in -1.0e60 .. 1.0e60),
     Post => Result.N=Source.N and then Result.Col=Source.Col
       and then (for all K in 0 .. Integer (Source.N)-1 => Result.Val (K)=Source.Val (K)*Gear)
       and then Valid (Result,Max_Dof);
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
   function Lane_Model (R : Row; V : Real_Array; Lane : Natural; Groups : Count) return Sum_Value is
     (if Groups=0 then 0.0 else Lane_Add (Lane_Model (R,V,Lane,Groups-1),
       Sparse_Product (R.Val (4*(Groups-1)+Lane),V (R.Col (4*(Groups-1)+Lane))),Groups-1)) with
     Ghost => Static, Pre => V'First=0 and then V'Length<=Max_Dof and then Valid (R,V'Length)
       and then (for all X of V => X in Input) and then Lane<4 and then Groups<=R.N/4,
     Post => abs Lane_Model'Result<=Real (Groups)*Lane_Step,
     Subprogram_Variant => (Decreases => Groups);
   function Tail_Model (R : Row; V : Real_Array; Base : Sum_Value; First, N : Count) return Sum_Value is
     (if N=0 then Base else Add (Tail_Model (R,V,Base,First,N-1),
       Sparse_Product (R.Val (First+N-1),V (R.Col (First+N-1))),First+N-1)) with
     Ghost => Static, Pre => V'First=0 and then V'Length<=Max_Dof and then Valid (R,V'Length)
       and then (for all X of V => X in Input) and then First+N<=R.N
       and then N<=3 and then abs Base<=Real (First)*Step_Bound,
     Post => abs Tail_Model'Result<=Real (First+N)*Step_Bound,
     Subprogram_Variant => (Decreases => N);
   function Speed_Model (R : Row; V : Real_Array) return Sum_Value is
     (declare G : constant Count := R.N/4;
              Base : constant Sum_Value := Combine (Lane_Model (R,V,0,G),Lane_Model (R,V,1,G),
                Lane_Model (R,V,2,G),Lane_Model (R,V,3,G),G);
      begin Tail_Model (R,V,Base,4*G,R.N mod 4)) with
     Ghost => Static, Pre => V'First=0 and then V'Length<=Max_Dof and then Valid (R,V'Length)
       and then (for all X of V => X in Input);
   procedure Unfold_Lanes (R : Row; V : Real_Array; G : Count) with Ghost => Static,
     Pre => V'First=0 and then V'Length<=Max_Dof and then Valid (R,V'Length)
       and then (for all X of V => X in Input) and then G<R.N/4,
     Post => (for all L in 0 .. 3 => Lane_Model (R,V,L,G+1)=
       Lane_Add (Lane_Model (R,V,L,G),Sparse_Product (R.Val (4*G+L),V (R.Col (4*G+L))),G));
   procedure Unfold_Tail (R : Row; V : Real_Array; Base : Sum_Value; First, N : Count) with Ghost => Static,
     Pre => V'First=0 and then V'Length<=Max_Dof and then Valid (R,V'Length)
       and then (for all X of V => X in Input) and then First+N<R.N
       and then N<3 and then abs Base<=Real (First)*Step_Bound,
     Post => Tail_Model (R,V,Base,First,N+1)=Add (Tail_Model (R,V,Base,First,N),
       Sparse_Product (R.Val (First+N),V (R.Col (First+N))),First+N);
   function Velocity (R : Row; Qvel : Real_Array) return Sum_Value with
     Pre => Qvel'First=0 and then Qvel'Length<=Max_Dof and then Valid (R,Qvel'Length)
       and then (for all X of Qvel => X in Input);
   pragma Postcondition (Static => Velocity'Result=Speed_Model (R,Qvel));
   -- Caller iterates actuator output rows in C order; this updates only present columns.
   procedure Project (R : Row; Force : Input; Generalized : in out Real_Array) with
     Pre => Generalized'First=0 and then Generalized'Length<=Max_Dof
       and then Valid (R,Generalized'Length)
       and then (for all X of Generalized => X in -1.0e90 .. 1.0e90),
     Post => (for all J in Generalized'Range =>
       (if (for all K in 0 .. Integer (R.N)-1 => R.Col (K)/=J) then Generalized (J)=Generalized'Old (J)))
       and then (for all K in 0 .. Integer (R.N)-1 =>
         Generalized (R.Col (K))=Generalized'Old (R.Col (K))+R.Val (K)*Force);
end MJ.Transmissions;
