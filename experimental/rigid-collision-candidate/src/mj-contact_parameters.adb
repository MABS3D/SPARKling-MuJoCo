package body MJ.Contact_Parameters with SPARK_Mode is
   function Weight (A, B : Real) return Real is
   begin
      if A >= Min_Val and B >= Min_Val then return A/(A+B);
      elsif A < Min_Val and B < Min_Val then return 0.5;
      elsif A < Min_Val then return 0.0; else return 1.0; end if;
   end Weight;

   function Mix_Value (A, B, W : Real) return Real is
     (W*A+(1.0-W)*B);

   function Mix_Reference (A, B : Reference; W : Real) return Reference is
   begin
      if A (0) > 0.0 and B (0) > 0.0 then
         return [Mix_Value (A (0), B (0), W), Mix_Value (A (1), B (1), W)];
      else
         return [Real'Min (A (0), B (0)), Real'Min (A (1), B (1))];
      end if;
   end Mix_Reference;

   function Combine (A, B : Material) return Parameters is
      P : Parameters;
      W : Real;
      Fri : Surface_Friction;
   begin
      if A.Priority > B.Priority then
         P.Dim := A.Dim; P.Ref := A.Ref; P.Imp := A.Imp;
         Fri := A.Fri; P.Adhesion := A.Adhesion;
      elsif B.Priority > A.Priority then
         P.Dim := B.Dim; P.Ref := B.Ref; P.Imp := B.Imp;
         Fri := B.Fri; P.Adhesion := B.Adhesion;
      else
         W := Weight (A.Mix, B.Mix); P.Dim := Dimension'Max (A.Dim, B.Dim);
         P.Adhesion := A.Adhesion+B.Adhesion;
         P.Ref := Mix_Reference (A.Ref, B.Ref, W);
         P.Imp := [Mix_Value (A.Imp (0), B.Imp (0), W), Mix_Value (A.Imp (1), B.Imp (1), W),
                   Mix_Value (A.Imp (2), B.Imp (2), W), Mix_Value (A.Imp (3), B.Imp (3), W),
                   Mix_Value (A.Imp (4), B.Imp (4), W)];
         Fri := [Real'Max (A.Fri (0), B.Fri (0)), Real'Max (A.Fri (1), B.Fri (1)), Real'Max (A.Fri (2), B.Fri (2))];
      end if;
      P.Fri := [Fri (0), Fri (0), Fri (1), Fri (2), Fri (2)];
      P.Ref_Friction := [0.0, 0.0]; P.Include_Margin := 0.0; P.Detection_Margin := 0.0;
      return P;
   end Combine;

   procedure Configure (P : in out Parameters; Margin, Gap : Real; O : Override_Parameters) is
      Old_Fri : constant Friction := P.Fri;
   begin
      P.Include_Margin := (if O.Enabled then O.Margin else Margin);
      P.Detection_Margin := P.Include_Margin+Gap;
      if O.Enabled then P.Ref := O.Ref; P.Ref_Friction := O.Ref; P.Imp := O.Imp; end if;
      for I in Friction'Range loop
         P.Fri (I) := Real'Max (1.0e-5, (if O.Enabled then O.Fri (I) else Old_Fri (I)));
         pragma Loop_Invariant (for all J in 0 .. I => P.Fri (J) =
           Real'Max (1.0e-5, (if O.Enabled then O.Fri (J) else Old_Fri (J))));
      end loop;
   end Configure;
end MJ.Contact_Parameters;
