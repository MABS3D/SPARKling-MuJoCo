package body MJ.Contact_Materials with SPARK_Mode is
   type Friction_Map is array (Friction_Index) of Surface_Friction_Index;
   Map : constant Friction_Map := [0, 0, 1, 2, 2];

   function Friction_Component
     (A, B : Surface; K : Friction_Index) return Wide_Value is
     (if A.Priority > B.Priority then A.Friction (Map (K))
      elsif A.Priority < B.Priority then B.Friction (Map (K))
      else Maximum (A.Friction (Map (K)), B.Friction (Map (K))));

   function Mix (A, B : Surface) return Parameters is
      W : constant Weight_Value := Weight (A.Solmix, B.Solmix);
   begin
      return (Condim => Mixed_Dimension (A, B),
        Solref => [for K in Ref_Index => Reference_Component (A, B, W, K)],
        Solref_Friction => [others => 0.0],
        Solimp => [for K in Imp_Index => Impedance_Component (A, B, W, K)],
        Friction => [for K in Friction_Index => Friction_Component (A, B, K)],
        Adhesion => Mixed_Adhesion (A, B));
   end Mix;

   --  Independent field-wise specification: no call to Prepare or Mix.
   function Expected
     (A, B : Surface; Pair : Explicit_Pair; Override : Override_Options;
      Distance : Wide_Value; Self_Flex : Boolean) return Prepared_Contact
   is
     (declare Adhesion : constant Real :=
        (if Pair.Enabled then Pair.Adhesion else Mixed_Adhesion (A, B));
      Margin : constant Wide_Value :=
        (if Self_Flex then 0.0 elsif Override.Enabled then Override.Margin
         elsif Pair.Enabled then Pair.Margin else A.Margin + B.Margin);
      begin
        (Include_Margin => Margin,
         Detection_Gap => (if Pair.Enabled then Pair.Gap else A.Gap + B.Gap),
         Excluded => Distance >= Margin and then Adhesion = 0.0,
         Values =>
           (Condim => (if Adhesion > 0.0 and then Distance >= Margin then 1
             elsif Pair.Enabled then Pair.Condim else Mixed_Dimension (A, B)),
            Adhesion => Adhesion,
            Solref => [for K in Ref_Index =>
              (if Override.Enabled then Override.Solref (K)
               elsif Pair.Enabled then Pair.Solref (K) else
                 Reference_Component (A, B, Weight (A.Solmix, B.Solmix), K))],
            Solref_Friction => [for K in Ref_Index =>
              (if Override.Enabled then Override.Solref (K)
               elsif Pair.Enabled and then
                 (Pair.Solref_Friction (0) /= 0.0 or else Pair.Solref_Friction (1) /= 0.0)
               then Pair.Solref_Friction (K) else 0.0)],
            Solimp => [for K in Imp_Index =>
              (if Override.Enabled then Override.Solimp (K)
               elsif Pair.Enabled then Pair.Solimp (K) else
                 Impedance_Component (A, B, Weight (A.Solmix, B.Solmix), K))],
            Friction => [for K in Friction_Index => Maximum (Min_Mu,
              (if Override.Enabled then Override.Friction (K)
               elsif Pair.Enabled then Pair.Friction (K)
               else Friction_Component (A, B, K)))])));

   function Prepare
     (A, B : Surface; Pair : Explicit_Pair; Override : Override_Options;
      Distance : Wide_Value; Self_Flex : Boolean := False)
     return Prepared_Contact
   is
      Adhesion : constant Real :=
        (if Pair.Enabled then Pair.Adhesion else Mixed_Adhesion (A, B));
      Margin : constant Wide_Value :=
        (if Self_Flex then 0.0 elsif Override.Enabled then Override.Margin
         elsif Pair.Enabled then Pair.Margin else A.Margin + B.Margin);
   begin
      --  Select the parameter block once, as in C. Build directly into the
      --  return object and only calculate a mixing weight in the mixed branch.
      return R : Prepared_Contact do
         R.Include_Margin := Margin;
         R.Detection_Gap := (if Pair.Enabled then Pair.Gap else A.Gap + B.Gap);
         R.Excluded := Distance >= Margin and then Adhesion = 0.0;
         R.Values.Adhesion := Adhesion;
         R.Values.Condim :=
           (if Adhesion > 0.0 and then Distance >= Margin then 1
            elsif Pair.Enabled then Pair.Condim else Mixed_Dimension (A, B));
         if Override.Enabled then
            R.Values.Solref := [for K in Ref_Index => Override.Solref (K)];
            R.Values.Solref_Friction := [for K in Ref_Index => Override.Solref (K)];
            R.Values.Solimp := [for K in Imp_Index => Override.Solimp (K)];
            R.Values.Friction := [for K in Friction_Index =>
              Maximum (Min_Mu, Override.Friction (K))];
         elsif Pair.Enabled then
            R.Values.Solref := [for K in Ref_Index => Pair.Solref (K)];
            if Pair.Solref_Friction (0) /= 0.0 or else Pair.Solref_Friction (1) /= 0.0 then
               R.Values.Solref_Friction := [for K in Ref_Index => Pair.Solref_Friction (K)];
            end if;
            R.Values.Solimp := [for K in Imp_Index => Pair.Solimp (K)];
            R.Values.Friction := [for K in Friction_Index =>
              Maximum (Min_Mu, Pair.Friction (K))];
         elsif A.Priority > B.Priority then
            R.Values.Solref := [for K in Ref_Index => A.Solref (K)];
            R.Values.Solimp := [for K in Imp_Index => A.Solimp (K)];
            declare
               F0 : constant Wide_Value := Maximum (Min_Mu, A.Friction (0));
               F1 : constant Wide_Value := Maximum (Min_Mu, A.Friction (1));
               F2 : constant Wide_Value := Maximum (Min_Mu, A.Friction (2));
            begin
               R.Values.Friction := [F0, F0, F1, F2, F2];
            end;
         elsif A.Priority < B.Priority then
            R.Values.Solref := [for K in Ref_Index => B.Solref (K)];
            R.Values.Solimp := [for K in Imp_Index => B.Solimp (K)];
            declare
               F0 : constant Wide_Value := Maximum (Min_Mu, B.Friction (0));
               F1 : constant Wide_Value := Maximum (Min_Mu, B.Friction (1));
               F2 : constant Wide_Value := Maximum (Min_Mu, B.Friction (2));
            begin
               R.Values.Friction := [F0, F0, F1, F2, F2];
            end;
         else
            declare
               W : constant Weight_Value := Weight (A.Solmix, B.Solmix);
               F0 : constant Wide_Value := Maximum
                 (Min_Mu, Maximum (A.Friction (0), B.Friction (0)));
               F1 : constant Wide_Value := Maximum
                 (Min_Mu, Maximum (A.Friction (1), B.Friction (1)));
               F2 : constant Wide_Value := Maximum
                 (Min_Mu, Maximum (A.Friction (2), B.Friction (2)));
            begin
               if A.Solref (0) > 0.0 and then B.Solref (0) > 0.0 then
                  R.Values.Solref := [for K in Ref_Index =>
                    Blend (A.Solref (K), B.Solref (K), W)];
               else
                  R.Values.Solref := [for K in Ref_Index =>
                    Minimum (A.Solref (K), B.Solref (K))];
               end if;
               R.Values.Solimp := [for K in Imp_Index =>
                 Blend (A.Solimp (K), B.Solimp (K), W)];
               R.Values.Friction := [F0, F0, F1, F2, F2];
            end;
         end if;
      end return;
   end Prepare;
end MJ.Contact_Materials;
