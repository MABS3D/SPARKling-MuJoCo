with MJ.Types; use MJ.Types;
package MJ.Adhesion with SPARK_Mode is
   -- Body transmission of MuJoCo 3.14.0. Rows are the assembled constraint
   -- Jacobian; Gap_J is the normal projection of jacDifPair for excluded=1.
   -- Flex contacts and exclusions 2/3 do not participate.
   type Cone is (Pyramidal, Elliptic);
   subtype Contact_Count is Natural range 0 .. 1024;
   subtype Row_Count is Natural range 0 .. 10240;
   type Contact is record
      Rigid_Geoms : Boolean := True;
      Body1, Body2 : Natural := 0;
      Exclude : Natural range 0 .. 3 := 0;
      Dim : Positive range 1 .. 6 := 1;
      Address : Natural := 0;
   end record;
   type Contact_Array is array (Natural range <>) of Contact;
   subtype Weight is Real range 0.0 .. 1.0;
   type Weight_Array is array (Natural range <>) of Weight;
   type Jacobian is array (Natural range <>, Natural range <>) of Tier0_Real;
   subtype Sum_Value is Real range -1.0e25 .. 1.0e25;
   subtype Component is Real range -1.0e26 .. 1.0e26;
   type Moment_Array is array (Natural range <>) of Component;
   type Force_Array is array (Natural range <>) of Tier3_Real;
   Step_Bound : constant Real := 2.0 ** 60;
   function Relevant (C : Contact; Body_Id : Natural) return Boolean is
     (C.Rigid_Geoms and then (C.Body1 = Body_Id or else C.Body2 = Body_Id)
      and then C.Exclude <= 1) with Global => null;
   function Width (C : Contact; Kind : Cone) return Positive is
     (if C.Dim = 1 or else Kind = Elliptic then 1 else 2*(C.Dim-1))
     with Global => null;
   function Row_Weight (C : Contact; Kind : Cone) return Weight is
     (if C.Dim = 1 or else Kind = Elliptic then 1.0 else 0.5 / Real (C.Dim-1))
     with Global => null;
   function Covers (C : Contact; Kind : Cone; Row : Natural) return Boolean is
     (Row >= C.Address and then Row-C.Address < Width (C, Kind)) with Global => null;
   function Valid_Contacts (Cs : Contact_Array; Kind : Cone; Rows : Row_Count)
      return Boolean is
     (Cs'First = 0 and then Cs'Length <= 1024 and then
       (for all C of Cs => (if C.Rigid_Geoms and then C.Exclude = 0 then
         C.Address < Rows and then Width (C, Kind) <= Rows-C.Address)))
      with Global => null;
   function Selected_Weight (Cs : Contact_Array; Body_Id : Natural; Kind : Cone;
      Row, Count : Natural) return Weight is
     (if Count = 0 then 0.0
      elsif Relevant (Cs (Count-1), Body_Id) and then Cs (Count-1).Exclude = 0
        and then Covers (Cs (Count-1), Kind, Row) then Row_Weight (Cs (Count-1), Kind)
      else Selected_Weight (Cs, Body_Id, Kind, Row, Count-1))
      with Ghost => Static, Global => null,
      Pre => Cs'First = 0 and then Cs'Length <= 1024 and then Count <= Cs'Length,
      Subprogram_Variant => (Decreases => Count);
   function Relevant_Count (Cs : Contact_Array; Body_Id, Count : Natural) return Contact_Count is
     (if Count = 0 then 0 else Relevant_Count (Cs, Body_Id, Count-1)
       + (if Relevant (Cs (Count-1), Body_Id) then 1 else 0))
      with Ghost => Static, Global => null,
      Pre => Cs'First = 0 and then Cs'Length <= 1024 and then Count <= Cs'Length,
      Post => Relevant_Count'Result <= Count,
      Subprogram_Variant => (Decreases => Count);
   function Expected_Weights (Cs : Contact_Array; Body_Id : Natural; Kind : Cone;
      Rows : Row_Count) return Weight_Array is
     ([for R in 0 .. Integer(Rows)-1 => Selected_Weight(Cs,Body_Id,Kind,R,Cs'Length)])
      with Ghost => Static, Global => null,
      Pre => Cs'First=0 and then Cs'Length<=1024,
      Post => Expected_Weights'Result'First=0 and then Expected_Weights'Result'Length=Rows
        and then (for all R in Expected_Weights'Result'Range =>
          Expected_Weights'Result(R) = Selected_Weight(Cs,Body_Id,Kind,R,Cs'Length)),
      Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   procedure Select_Rows (Cs : Contact_Array; Body_Id : Natural; Kind : Cone;
      W : out Weight_Array; Count : out Contact_Count) with Global => null,
      Pre => W'First = 0 and then W'Length <= 10240
        and then Valid_Contacts (Cs, Kind, W'Length),
      Post => (Static => Count = Relevant_Count (Cs, Body_Id, Cs'Length)
        and then (for all R in W'Range => W (R) = Selected_Weight (Cs, Body_Id, Kind, R, Cs'Length)));
   function Add (Acc : Sum_Value; Term : Tier0_Real; Count : Natural) return Sum_Value
      with Global => null, Pre => Count < 10240 and then abs Acc <= Real (Count)*Step_Bound,
      Post => Add'Result = Acc + Term
        and then abs Add'Result <= Real (Count+1)*Step_Bound;
   function Active_Sum (J : Jacobian; W : Weight_Array; Col, Count : Natural)
      return Sum_Value is
     (if Count = 0 then 0.0 else
       Add (Active_Sum (J, W, Col, Count-1), J (Count-1, Col)*W (Count-1), Count-1))
      with Ghost => Static, Global => null,
      Pre => J'First (1) = 0 and then W'First = 0 and then J'Length (1) = W'Length
        and then W'Length <= 10240 and then Col in J'Range (2) and then Count <= W'Length,
      Post => abs Active_Sum'Result <= Real (Count)*Step_Bound,
      Subprogram_Variant => (Decreases => Count);
   function Gap_Sum (Cs : Contact_Array; G : Jacobian; Body_Id, Col, Count : Natural)
      return Sum_Value is
     (if Count = 0 then 0.0
      elsif Relevant (Cs (Count-1), Body_Id) and then Cs (Count-1).Exclude = 1 then
        Add (Gap_Sum (Cs, G, Body_Id, Col, Count-1), G (Count-1, Col), Count-1)
      else Gap_Sum (Cs, G, Body_Id, Col, Count-1))
      with Ghost => Static, Global => null,
      Pre => Cs'First = 0 and then Cs'Length <= 1024 and then G'First (1) = 0
        and then G'Length (1) = Cs'Length and then Col in G'Range (2) and then Count <= Cs'Length,
      Post => abs Gap_Sum'Result <= Real (Count)*Step_Bound,
      Subprogram_Variant => (Decreases => Count);
   procedure Unfold_Active (J : Jacobian; W : Weight_Array; Col, Count : Natural) with
     Ghost => Static, Global => null,
     Pre => J'First (1) = 0 and then W'First = 0 and then J'Length (1) = W'Length
       and then W'Length <= 10240 and then Col in J'Range (2) and then Count < W'Length,
     Post => Active_Sum (J,W,Col,Count+1) = Add (Active_Sum (J,W,Col,Count),J(Count,Col)*W(Count),Count);
   procedure Unfold_Gap (Cs : Contact_Array; G : Jacobian; Body_Id, Col, Count : Natural) with
     Ghost => Static, Global => null,
     Pre => Cs'First = 0 and then Cs'Length <= 1024 and then G'First (1) = 0
       and then G'Length (1) = Cs'Length and then Col in G'Range (2) and then Count < Cs'Length,
     Post => Gap_Sum (Cs,G,Body_Id,Col,Count+1) =
       (if Relevant (Cs(Count),Body_Id) and then Cs(Count).Exclude = 1 then
         Add (Gap_Sum (Cs,G,Body_Id,Col,Count),G(Count,Col),Count)
        else Gap_Sum (Cs,G,Body_Id,Col,Count));
   function Active_Column (J : Jacobian; W : Weight_Array; Col : Natural) return Sum_Value with
     Inline_Always, Global => null,
     Pre => J'First (1) = 0 and then W'First = 0 and then J'Length (1) = W'Length
       and then W'Length <= 10240 and then Col in J'Range (2),
     Post => (Static => Active_Column'Result = Active_Sum (J,W,Col,W'Length));
   function Gap_Column (Cs : Contact_Array; G : Jacobian; Body_Id, Col : Natural) return Sum_Value with
     Inline_Always, Global => null,
     Pre => Cs'First = 0 and then Cs'Length <= 1024 and then G'First (1) = 0
       and then G'Length (1) = Cs'Length and then Col in G'Range (2),
     Post => (Static => Gap_Column'Result = Gap_Sum (Cs,G,Body_Id,Col,Cs'Length));
   function Normalized (Active, Gap : Sum_Value; Count : Contact_Count) return Component is
     (if Count = 0 then 0.0 else (Active + Gap) * (-1.0 / Real (Count)))
      with Ghost => Static, Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Normalize (Active, Gap : Sum_Value; Count : Contact_Count) return Component with
      Global => null, Post => (Static => Normalize'Result = Normalized (Active,Gap,Count));
   procedure Equal_Normalized (A,G,A2,G2 : Sum_Value; Count : Contact_Count) with
      Ghost => Static, Global => null, Pre => A = A2 and then G = G2,
      Post => Normalized(A,G,Count) = Normalized(A2,G2,Count);
   procedure Equal_Active (J : Jacobian; W,W2 : Weight_Array; Col,Count : Natural) with
      Ghost => Static, Global => null,
      Pre => J'First(1)=0 and then W'First=0 and then W2'First=0
        and then W'Length=J'Length(1) and then W2'Length=W'Length and then W'Length<=10240
        and then Col in J'Range(2) and then Count<=W'Length and then W=W2,
      Post => Active_Sum(J,W,Col,Count) = Active_Sum(J,W2,Col,Count),
      Subprogram_Variant => (Decreases => Count);
   function Column_For (Cs : Contact_Array; J, Gap_J : Jacobian; W : Weight_Array;
      Body_Id, Col : Natural; Count : Contact_Count) return Component with Global => null,
      Pre => Cs'First = 0 and then Cs'Length <= 1024
        and then J'First (1) = 0 and then W'First = 0 and then J'Length (1) = W'Length
        and then W'Length <= 10240 and then Col in J'Range (2)
        and then Gap_J'First (1) = 0 and then Gap_J'Length (1) = Cs'Length and then Col in Gap_J'Range (2),
      Post => (Static => Column_For'Result = Normalized
        (Active_Sum (J,W,Col,W'Length),Gap_Sum (Cs,Gap_J,Body_Id,Col,Cs'Length),Count));
   procedure Project (Cs : Contact_Array; Body_Id : Natural; Kind : Cone;
      J, Gap_J : Jacobian; Moment : out Moment_Array) with Global => null, Relaxed_Initialization => Moment,
      Pre => J'First (1) = 0 and then J'Length (1) <= 10240
        and then Valid_Contacts (Cs, Kind, J'Length (1))
        and then Gap_J'First (1) = 0 and then Gap_J'Length (1) = Cs'Length
        and then J'First (2) = Gap_J'First (2) and then J'Last (2) = Gap_J'Last (2)
        and then Moment'First = J'First (2) and then Moment'Last = J'Last (2),
      Post => (Static => Moment'Initialized and then (for all K in Moment'Range =>
        Moment (K) = Normalized
          (Active_Sum (J, Expected_Weights(Cs,Body_Id,Kind,J'Length(1)), K, J'Length (1)),
           Gap_Sum (Cs, Gap_J, Body_Id, K, Cs'Length), Relevant_Count (Cs, Body_Id, Cs'Length))));
   procedure Apply_Force (Moment : Moment_Array; Force : Tier0_Real; Generalized : out Force_Array)
      with Global => null, Relaxed_Initialization => Generalized, Pre => Generalized'First = Moment'First and then Generalized'Last = Moment'Last,
      Post => (Static => Generalized'Initialized and then (for all K in Moment'Range => Generalized (K) = Force * Moment (K)));
end MJ.Adhesion;
