with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;

package MJ.Contact_Parameters with SPARK_Mode is
   subtype Dimension is Positive range 1 .. 6
     with Static_Predicate => Dimension in 1 | 3 | 4 | 6;
   type Reference is array (Natural range 0 .. 1) of Real;
   type Impedance is array (Natural range 0 .. 4) of Real;
   type Friction is array (Natural range 0 .. 4) of Real;
   type Surface_Friction is array (Natural range 0 .. 2) of Real;
   type Material is record
      Priority : Integer := 0;
      Dim : Dimension := 3;
      Mix : Real := 1.0;
      Ref : Reference := [0.02, 1.0];
      Imp : Impedance := [0.9, 0.95, 0.001, 0.5, 2.0];
      Fri : Surface_Friction := [1.0, 0.005, 0.0001];
      Adhesion : Real := 0.0;
   end record;
   type Parameters is record
      Dim : Dimension;
      Ref : Reference;
      Ref_Friction : Reference;
      Imp : Impedance;
      Fri : Friction;
      Adhesion : Real;
      Include_Margin : Real;
      Detection_Margin : Real;
   end record;
   Default_Parameters : constant Parameters :=
     (Dim => 3, Ref => [0.02, 1.0], Ref_Friction => [0.0, 0.0],
      Imp => [0.9, 0.95, 0.001, 0.5, 2.0], Fri => [1.0, 1.0, 0.005, 0.0001, 0.0001],
      Adhesion => 0.0, Include_Margin => 0.0, Detection_Margin => 0.0);
   type Override_Parameters is record
      Enabled : Boolean := False;
      Margin : Real := 0.0;
      Ref : Reference := [0.02, 1.0];
      Imp : Impedance := [0.9, 0.95, 0.001, 0.5, 2.0];
      Fri : Friction := [1.0, 1.0, 0.005, 0.0001, 0.0001];
   end record;
   function Valid (A : Material) return Boolean is
     (A.Mix in 0.0 .. 1.0e10 and A.Adhesion in 0.0 .. 1.0e10
      and (for all X of A.Ref => X in -1.0e10 .. 1.0e10)
      and (for all X of A.Imp => X in -1.0e10 .. 1.0e10)
      and (for all X of A.Fri => X in 0.0 .. 1.0e10));
   function Weight (A, B : Real) return Real with Global => null,
     Pre => A in 0.0 .. 1.0e10 and B in 0.0 .. 1.0e10,
     Post => Weight'Result in 0.0 .. 1.0 and then
       Weight'Result = (if A >= Min_Val and B >= Min_Val then A/(A+B)
          elsif A < Min_Val and B < Min_Val then 0.5
          elsif A < Min_Val then 0.0 else 1.0);
   function Mix_Value (A, B, W : Real) return Real with Inline, Global => null,
     Pre => A in -1.0e10 .. 1.0e10 and B in -1.0e10 .. 1.0e10 and W in 0.0 .. 1.0,
     Post => Mix_Value'Result in -3.0e10 .. 3.0e10
       and then Mix_Value'Result = W*A+(1.0-W)*B;
   --  Preserve MuJoCo's two solref modes without distributing the condition
   --  through the larger material contract.  Each component is binary64.
   function Mix_Reference (A, B : Reference; W : Real) return Reference
     with Inline, Global => null,
       Pre => (for all X of A => X in -1.0e10 .. 1.0e10)
         and (for all X of B => X in -1.0e10 .. 1.0e10) and W in 0.0 .. 1.0,
       Post => (for all I in Reference'Range => Mix_Reference'Result (I) =
         (if A (0) > 0.0 and B (0) > 0.0 then Mix_Value (A (I), B (I), W)
          else Real'Min (A (I), B (I))));
   function Combine (A, B : Material) return Parameters with Global => null,
     Pre => Valid (A) and Valid (B),
     Post => Combine'Result.Dim =
       (if A.Priority > B.Priority then A.Dim elsif B.Priority > A.Priority then B.Dim
        else Dimension'Max (A.Dim, B.Dim))
       and then Combine'Result.Adhesion =
       (if A.Priority > B.Priority then A.Adhesion elsif B.Priority > A.Priority then B.Adhesion else A.Adhesion+B.Adhesion)
       and then Combine'Result.Ref =
         (if A.Priority > B.Priority then A.Ref elsif B.Priority > A.Priority then B.Ref
          else Mix_Reference (A.Ref, B.Ref, Weight (A.Mix, B.Mix)))
       and then (for all I in Impedance'Range => Combine'Result.Imp (I) =
         (if A.Priority > B.Priority then A.Imp (I) elsif B.Priority > A.Priority then B.Imp (I)
          else Mix_Value (A.Imp (I), B.Imp (I), Weight (A.Mix, B.Mix))))
       and then (for all I in Friction'Range => Combine'Result.Fri (I) =
         (if A.Priority > B.Priority then A.Fri ((if I < 2 then 0 elsif I = 2 then 1 else 2))
          elsif B.Priority > A.Priority then B.Fri ((if I < 2 then 0 elsif I = 2 then 1 else 2))
          else Real'Max (A.Fri ((if I < 2 then 0 elsif I = 2 then 1 else 2)),
                          B.Fri ((if I < 2 then 0 elsif I = 2 then 1 else 2)))))
       and then Combine'Result.Ref_Friction (0) = 0.0
       and then Combine'Result.Ref_Friction (1) = 0.0
       and then Combine'Result.Include_Margin = 0.0 and then Combine'Result.Detection_Margin = 0.0;
   procedure Configure (P : in out Parameters; Margin, Gap : Real; O : Override_Parameters)
     with Global => null,
       Pre => Margin in 0.0 .. 2.0e10 and Gap in 0.0 .. 2.0e10
         and O.Margin in 0.0 .. 1.0e10
         and (for all X of P.Fri => X in 0.0 .. 1.0e10)
         and (for all X of O.Fri => X in 0.0 .. 1.0e10),
       Post => P.Include_Margin = (if O.Enabled then O.Margin else Margin)
         and P.Detection_Margin = P.Include_Margin+Gap
         and P.Dim = P.Dim'Old and P.Adhesion = P.Adhesion'Old
         and P.Ref = (if O.Enabled then O.Ref else P.Ref'Old)
         and P.Ref_Friction = (if O.Enabled then O.Ref else P.Ref_Friction'Old)
         and P.Imp = (if O.Enabled then O.Imp else P.Imp'Old)
         and (for all I in Friction'Range => P.Fri (I) =
           Real'Max (1.0e-5, (if O.Enabled then O.Fri (I) else P.Fri'Old (I))));
end MJ.Contact_Parameters;
