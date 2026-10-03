procedure MJ.Data.Constrained.Endpoint_Checks is
   E : MJ.Data.Constrained.Engine;
   Result : Status;
   procedure Rejected (Id, Body0, Body1 : Natural; Geom0, Geom1 : Integer) is
      Before : constant Contact_Endpoint_Array := E.Endpoints;
      Old_Weights : constant Weighted_Contact_Array := E.Contact_Weights;
   begin
      Set_Contact_Endpoints (E, Id, Body0, Body1, Geom0, Geom1, Result);
      if Result /= Invalid_Index or else E.Endpoints /= Before or else E.Contact_Weights /= Old_Weights then
         raise Program_Error with "endpoint rejection/atomicity";
      end if;
   end Rejected;
   procedure Weighted_Rejected (A, B : Weighted_Side; G0, G1 : Integer) is
      Before : constant Contact_Endpoint_Array := E.Endpoints;
      Old_Weights : constant Weighted_Contact_Array := E.Contact_Weights;
   begin
      Set_Weighted_Contact_Endpoints (E,0,A,B,G0,G1,Result);
      if Result /= Invalid_Index or else E.Endpoints /= Before or else E.Contact_Weights /= Old_Weights then
         raise Program_Error with "weighted endpoint rejection/atomicity";
      end if;
   end Weighted_Rejected;
begin
   E.D.Nb := 3; E.Ng := 2; E.T.Ncontact := 1;
   E.Geoms (0).Body_Id := 0; E.Geoms (1).Body_Id := 1;
   Set_Contact_Endpoints (E, 0, 0, 2, 0, -1, Result);
   if Result /= Success or else E.Endpoints (0) /= Contact_Endpoints'(0, 2, 0, -1) then
      raise Program_Error with "real flex body endpoint";
   end if;
   Rejected (1, 0, 2, 0, -1);
   Rejected (0, 0, 3, 0, -1);
   Rejected (0, 1, 2, 0, -1);
   Rejected (0, 0, 2, 0, 2);
   Rejected (0, 0, 2, 0, -2);
   declare
      A : constant Weighted_Side := (Count => 1,Items => [1 => (0,1.0),others => <>]);
      B : constant Weighted_Side := (Count => 2,Items => [1 => (1,0.25),2 => (2,0.75),others => <>]);
      Invalid : Weighted_Side;
   begin
      Set_Weighted_Contact_Endpoints (E,0,A,B,0,-1,Result);
      if Result /= Success or else E.Contact_Weights (0) /= Weighted_Contact'(True,A,B) then
         raise Program_Error with "weighted endpoint copy";
      end if;
      Invalid := B; Invalid.Count := 0; Weighted_Rejected (A,Invalid,0,-1);
      Invalid.Count := 5; Weighted_Rejected (A,Invalid,0,-1);
      Invalid := B; Invalid.Items (2).Weight := 0.0; Weighted_Rejected (A,Invalid,0,-1);
      Invalid.Items (2).Weight := -0.1; Weighted_Rejected (A,Invalid,0,-1);
      Invalid.Items (2).Weight := 2.1; Weighted_Rejected (A,Invalid,0,-1);
      Weighted_Rejected (A,B,0,1);
      Invalid := B; Invalid.Count := 1; Weighted_Rejected (A,Invalid,0,1);
      Invalid := B; Invalid.Items (2).Body_Id := 3; Weighted_Rejected (A,Invalid,0,-1);
      Set_Contact_Endpoints (E,0,0,2,0,-1,Result);
      if Result /= Success or else E.Contact_Weights (0).Active
        or else E.Contact_Weights (0).Side0 /= A or else E.Contact_Weights (0).Side1 /= B then
         raise Program_Error with "weighted to singleton publication";
      end if;
   end;
end MJ.Data.Constrained.Endpoint_Checks;
