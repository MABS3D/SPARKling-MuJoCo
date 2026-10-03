package body MJ.Adhesion with SPARK_Mode is
   procedure Select_Rows (Cs : Contact_Array; Body_Id : Natural; Kind : Cone;
      W : out Weight_Array; Count : out Contact_Count) is
   begin
      W := (others => 0.0); Count := 0;
      for I in Cs'Range loop
         if Relevant (Cs (I), Body_Id) then
            Count := Count + 1;
            if Cs (I).Exclude = 0 then
               for K in 0 .. Width (Cs (I), Kind)-1 loop
                  W (Cs (I).Address+K) := Row_Weight (Cs (I), Kind);
                  pragma Loop_Invariant (Static => (for all R in W'Range => W (R) =
                    (if R >= Cs (I).Address and then R-Cs (I).Address <= K then Row_Weight (Cs (I), Kind)
                     else Selected_Weight (Cs, Body_Id, Kind, R, I))));
               end loop;
            end if;
         end if;
         pragma Loop_Invariant (Static => Count = Relevant_Count (Cs, Body_Id, I+1));
         pragma Loop_Invariant (Static => (for all R in W'Range => W (R) = Selected_Weight (Cs, Body_Id, Kind, R, I+1)));
      end loop;
   end Select_Rows;
   function Add (Acc : Sum_Value; Term : Tier0_Real; Count : Natural) return Sum_Value is
   begin
      return Acc + Term;
   end Add;
   procedure Unfold_Active (J : Jacobian; W : Weight_Array; Col, Count : Natural) is
   begin null; end Unfold_Active;
   procedure Unfold_Gap (Cs : Contact_Array; G : Jacobian; Body_Id, Col, Count : Natural) is
   begin null; end Unfold_Gap;
   function Active_Column (J : Jacobian; W : Weight_Array; Col : Natural) return Sum_Value is
      A : Sum_Value := 0.0;
   begin
      for R in W'Range loop
         Unfold_Active (J,W,Col,R);
         pragma Assert (Static => A = Active_Sum (J,W,Col,R));
         pragma Assert (Static => Active_Sum (J,W,Col,R+1) = Add (A,J(R,Col)*W(R),R));
         A := Add (A,J(R,Col)*W(R),R);
         pragma Loop_Invariant (Static => A = Active_Sum (J,W,Col,R+1));
         pragma Loop_Invariant (abs A <= Real(R+1)*Step_Bound);
      end loop;
      return A;
   end Active_Column;
   function Gap_Column (Cs : Contact_Array; G : Jacobian; Body_Id, Col : Natural) return Sum_Value is
      A : Sum_Value := 0.0;
   begin
      for I in Cs'Range loop
         Unfold_Gap (Cs,G,Body_Id,Col,I);
         if Relevant (Cs(I),Body_Id) and then Cs(I).Exclude = 1 then
            A := Add (A,G(I,Col),I);
         end if;
         pragma Loop_Invariant (Static => A = Gap_Sum (Cs,G,Body_Id,Col,I+1));
         pragma Loop_Invariant (abs A <= Real(I+1)*Step_Bound);
      end loop;
      return A;
   end Gap_Column;
   function Normalize (Active, Gap : Sum_Value; Count : Contact_Count) return Component is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Normalized);
   begin
      return (if Count = 0 then 0.0 else (Active+Gap)*(-1.0/Real(Count)));
   end Normalize;
   procedure Equal_Normalized (A,G,A2,G2 : Sum_Value; Count : Contact_Count) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Normalized);
   begin null; end Equal_Normalized;
   procedure Equal_Active (J : Jacobian; W,W2 : Weight_Array; Col,Count : Natural) is
   begin
      if Count>0 then
         Equal_Active(J,W,W2,Col,Count-1);
         Unfold_Active(J,W,Col,Count-1);
         Unfold_Active(J,W2,Col,Count-1);
         pragma Assert (J(Count-1,Col)*W(Count-1) = J(Count-1,Col)*W2(Count-1));
      end if;
   end Equal_Active;
   function Column_For (Cs : Contact_Array; J, Gap_J : Jacobian; W : Weight_Array;
      Body_Id, Col : Natural; Count : Contact_Count) return Component is
      A : constant Sum_Value := Active_Column (J,W,Col);
      G : constant Sum_Value := Gap_Column (Cs,Gap_J,Body_Id,Col);
   begin
      pragma Assert_And_Cut (Static => Cs'First = 0 and then Cs'Length <= 1024
        and then J'First (1) = 0 and then W'First = 0 and then J'Length (1) = W'Length
        and then W'Length <= 10240 and then Col in J'Range (2)
        and then Gap_J'First (1) = 0 and then Gap_J'Length (1) = Cs'Length and then Col in Gap_J'Range (2)
        and then A = Active_Sum (J,W,Col,W'Length)
        and then G = Gap_Sum (Cs,Gap_J,Body_Id,Col,Cs'Length));
      Equal_Normalized(A,G,Active_Sum(J,W,Col,W'Length),Gap_Sum(Cs,Gap_J,Body_Id,Col,Cs'Length),Count);
      return Normalize (A,G,Count);
   end Column_For;
   procedure Project (Cs : Contact_Array; Body_Id : Natural; Kind : Cone;
      J, Gap_J : Jacobian; Moment : out Moment_Array) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Active_Sum);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Gap_Sum);
      W : Weight_Array (J'Range (1));
      Expected : constant Weight_Array := Expected_Weights(Cs,Body_Id,Kind,J'Length(1)) with Ghost => Static;
      N : Contact_Count;
   begin
      Select_Rows (Cs, Body_Id, Kind, W, N);
      pragma Assert (Static => W = Expected);
      for K in Moment'Range loop
         Moment (K) := Column_For (Cs,J,Gap_J,W,Body_Id,K,N);
         Equal_Active(J,W,Expected,K,W'Length);
         Equal_Normalized(Active_Sum(J,W,K,W'Length),Gap_Sum(Cs,Gap_J,Body_Id,K,Cs'Length),
           Active_Sum(J,Expected,K,W'Length),Gap_Sum(Cs,Gap_J,Body_Id,K,Cs'Length),N);
         pragma Loop_Invariant (Static => (for all L in Moment'First .. K => Moment (L)'Initialized));
         pragma Loop_Invariant (Static => (for all L in Moment'First .. K => Moment (L)'Initialized
           and then Moment (L) = Normalized (Active_Sum (J,Expected,L,W'Length),
             Gap_Sum (Cs,Gap_J,Body_Id,L,Cs'Length),N)));
      end loop;
   end Project;
   procedure Apply_Force (Moment : Moment_Array; Force : Tier0_Real; Generalized : out Force_Array) is
   begin
      for K in Moment'Range loop
         Generalized (K) := Force * Moment (K);
         pragma Loop_Invariant (Static => (for all L in Moment'First .. K => Generalized (L)'Initialized));
         pragma Loop_Invariant (Static => (for all L in Moment'First .. K => Generalized (L) = Force * Moment (L)));
      end loop;
   end Apply_Force;
end MJ.Adhesion;
