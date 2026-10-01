--  Native EPA feature recovery and clipping from MuJoCo 3.14.0.
with MJ.Rigid_Math; use MJ.Rigid_Math;
with Interfaces;
package body MJ.Contact_Features with SPARK_Mode is
   Max_Degree : constant := 64;
   Max_Polygon : constant := 2*Max_Facet_Vertices;
   type Points is array (Natural range 0 .. Max_Polygon-1) of Vec with Relaxed_Initialization;
   type Polygon_Buffers is array (Boolean) of Points with Relaxed_Initialization;
   type Normal_List is array (Natural range 0 .. Max_Degree-1) of Vec with Relaxed_Initialization;
   type Id_List is array (Natural range 0 .. Max_Degree-1) of Natural with Relaxed_Initialization;
   type Feature is record
      Dim : Natural range 1 .. 3 := 1;
      V : Feature_Points;
      I : Feature_Indices;
      N, Ends : Normal_List;
      Id : Id_List;
      Count : Natural range 0 .. Max_Degree := 0;
   end record;
   procedure Expand (A, B : Object; PA, PB : Pose; V : Vertex_Array; Facets : Facet_Array;
                     I1, I2 : Feature_Indices; P1, P2 : Feature_Points;
                     M : in out Manifold; Result : out Status;
                     Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup) is
      use type Interfaces.Unsigned_8;
      F1, F2 : Feature;
      Face1, Face2 : Points;
      Polygons : Polygon_Buffers;
      Active : Boolean := False;
      NFace1, NFace2, NP, NC : Natural := 0;
      I, J : Natural := 0;
      Edge1, Edge2, Found, Failed : Boolean := False;
      Dir : constant Vec := M.Items (0).Normal;
      Normal, Witness_Dir, PN, P, Q, PQ, Diff, First, Second : Vec;
      PD, Denominator, T, Dist, Max_Dist : Real;
      Inside1, Inside2 : Boolean;
      Keep : array (Natural range 0 .. 3) of Natural := [0, 1, 2, 3];
      NKeep, Best1, Best2 : Natural;
      procedure Append_Normal (F : in out Feature; N : Vec; Id : Natural) is
      begin
         if F.Count = Max_Degree then Failed := True; return; end if;
         F.N (F.Count) := N; F.Id (F.Count) := Id; F.Count := F.Count+1;
      end Append_Normal;
      procedure Identify (F : in out Feature) is
      begin
         if F.I (0) = F.I (1) then
            if F.I (0) = F.I (2) then F.Dim := 1;
            else F.Dim := 2; F.I (1) := F.I (2); F.V (1) := F.V (2); end if;
         elsif F.I (2) = F.I (0) or F.I (2) = F.I (1) then F.Dim := 2;
         else F.Dim := 3; end if;
      end Identify;
      function Has (Poly : Facet; Id : Integer) return Boolean is
      begin
         for K in 0 .. Poly.Length-1 loop if Integer (Poly.Indices (K)) = Id then return True; end if; end loop;
         return False;
      end Has;
      procedure Normals (S : Object; P : Pose; D : Vec; F : in out Feature) is
         Match : Boolean;
         Sign : Real;
         N, Local_N : Vec;
         Common, Face_Id : Natural;
         procedure Try_Face (K : Natural) is
         begin
            Match := True;
            for L in 0 .. F.Dim-1 loop
               if not Has (Facets (K), F.I (L)) then Match := False; exit; end if;
            end loop;
            if Match then Append_Normal (F, Transform (P.Rotation, Facets (K).Normal), K); end if;
         end Try_Face;
      begin
         F.Count := 0;
         if S.Kind = Hull then
            if S.Facet_Count = 0 then return; end if;
            if (S.First_Facet < Facets'First or S.First_Facet > Facets'Last)
              or else S.Facet_Count > Facets'Last-S.First_Facet+1 then Failed := True; return; end if;
            if MJ.Contact_Incidence.Covers (Incidence, S, Facets) and then F.I (0) >= 0
              and then MJ.Contact_Incidence.Has_Vertex (Incidence, Natural (F.I (0))) then
               for E in 0 .. MJ.Contact_Incidence.Count (Incidence, Natural (F.I (0)))-1 loop
                  declare K : constant Natural := MJ.Contact_Incidence.Item (Incidence, Natural (F.I (0)), E).Face; begin
                     if K in S.First_Facet .. S.First_Facet+(S.Facet_Count-1) then Try_Face (K); end if;
                  end;
                  exit when Failed or (F.Dim = 3 and F.Count = 1) or (F.Dim = 2 and F.Count = 2);
               end loop;
            else
               for K in S.First_Facet .. S.First_Facet+(S.Facet_Count-1) loop
                  Try_Face (K);
                  exit when Failed or (F.Dim = 3 and F.Count = 1) or (F.Dim = 2 and F.Count = 2);
               end loop;
            end if;
         elsif S.Rigid.Kind = Cylinder then
            if F.Dim = 1 then Append_Normal (F, Scale (Column (P.Rotation, 2), (if F.I (0) = 0 then 1.0 else -1.0)), Natural (F.I (0))); end if;
         elsif S.Rigid.Kind = Box then
            Common := 0;
            for K in Axis loop
               Match := True;
               for L in 1 .. F.Dim-1 loop
                  if ((F.I (0)/(2**K)) mod 2) /= ((F.I (L)/(2**K)) mod 2) then Match := False; exit; end if;
               end loop;
               if Match then
                  Sign := (if (F.I (0)/(2**K)) mod 2 = 1 then 1.0 else -1.0);
                  Face_Id := 2*K+(if Sign > 0.0 then 0 else 1); Common := Common+1;
                  Append_Normal (F, Scale (Column (P.Rotation, K), Sign), Face_Id);
               end if;
            end loop;
            if (F.Dim = 3 and Common /= 1) or (F.Dim = 2 and Common /= 2) then
               F.Count := 0; Local_N := Unit (Local (P.Rotation, D));
               for K in 0 .. 5 loop
                  N := Zero; N (K/2) := (if K mod 2 = 0 then 1.0 else -1.0);
                  if Dot (Local_N, N) > 0.996 then Append_Normal (F, Transform (P.Rotation, N), K); exit; end if;
               end loop;
            end if;
         end if;
      end Normals;
      procedure Edges (S : Object; P : Pose; F : in out Feature) is
         Local_Point, Endpoint : Vec;
         Prev : Natural;
         procedure Append (E : Vec) is
         begin
            if F.Count = Max_Degree then Failed := True; return; end if;
            F.Ends (F.Count) := E; F.N (F.Count) := Unit (Sub (E, F.V (0))); F.Count := F.Count+1;
         end Append;
      begin
         F.Count := 0;
         if S.Kind = Primitive and S.Rigid.Kind = Cylinder then
            Endpoint := Add (F.V (0), Scale (Column (P.Rotation, 2), (if F.I (0) = 0 then -2.0 else 2.0)*S.Rigid.Size (1)));
            Append (Endpoint); return;
         end if;
         if F.Dim = 2 then Endpoint := F.V (1); Append (Endpoint); return; end if;
         if F.Dim /= 1 then return; end if;
         if S.Kind = Hull then
            if MJ.Contact_Incidence.Covers (Incidence, S, Facets) and then F.I (0) >= 0
              and then MJ.Contact_Incidence.Has_Vertex (Incidence, Natural (F.I (0))) then
               for E in 0 .. MJ.Contact_Incidence.Count (Incidence, Natural (F.I (0)))-1 loop
                  declare
                     C : constant MJ.Contact_Incidence.Corner := MJ.Contact_Incidence.Item (Incidence, Natural (F.I (0)), E);
                     K : constant Natural := C.Face;
                  begin
                     if K in S.First_Facet .. S.First_Facet+(S.Facet_Count-1) then
                        Prev := (C.Position+Facets (K).Length-1) mod Facets (K).Length;
                        if Facets (K).Indices (Prev) not in V'Range then Failed := True; return; end if;
                        Append (Add (P.Position, Transform (P.Rotation, V (Facets (K).Indices (Prev)))));
                     end if;
                  end;
                  exit when Failed;
               end loop;
               return;
            end if;
            for K in S.First_Facet .. S.First_Facet+S.Facet_Count-1 loop
               for L in 0 .. Facets (K).Length-1 loop
                  if Integer (Facets (K).Indices (L)) = F.I (0) then
                     Prev := (L+Facets (K).Length-1) mod Facets (K).Length;
                     if Facets (K).Indices (Prev) not in V'Range then Failed := True; return; end if;
                     Append (Add (P.Position, Transform (P.Rotation, V (Facets (K).Indices (Prev))))); exit;
                  end if;
               end loop;
               exit when Failed;
            end loop;
         elsif S.Rigid.Kind = Box then
            for K in Axis loop Local_Point (K) := (if (F.I (0)/(2**K)) mod 2 = 1 then S.Rigid.Size (K) else -S.Rigid.Size (K)); end loop;
            for K in Axis loop
               Endpoint := Local_Point; Endpoint (K) := -Endpoint (K); Append (Add (P.Position, Transform (P.Rotation, Endpoint)));
            end loop;
         end if;
      end Edges;
      procedure Recover (S : Object; P : Pose; Id : Natural; Face_Points : in out Points; Count : out Natural) is
         type Signs is array (Natural range 0 .. 3, Axis) of Integer;
         Table : Signs;
         Local_Point : Vec;
         Sign : Real;
         Cos_16 : constant array (Natural range 0 .. 15) of Real :=
           [1.0, 0.923879532511287, 0.707106781186548, 0.382683432365090,
            0.0, -0.382683432365090, -0.707106781186547, -0.923879532511287,
            -1.0, -0.923879532511287, -0.707106781186548, -0.382683432365090,
            0.0, 0.382683432365090, 0.707106781186547, 0.923879532511287];
         Sin_16 : constant array (Natural range 0 .. 15) of Real :=
           [0.0, 0.382683432365090, 0.707106781186547, 0.923879532511287,
            1.0, 0.923879532511287, 0.707106781186548, 0.382683432365090,
            0.0, -0.382683432365090, -0.707106781186547, -0.923879532511287,
            -1.0, -0.923879532511287, -0.707106781186548, -0.382683432365090];
      begin
         Count := 0;
         if S.Kind = Hull then
            if Id not in Facets'Range then Failed := True; return; end if;
            Count := Facets (Id).Length;
            for K in 0 .. Count-1 loop
               if Facets (Id).Indices (Count-1-K) not in V'Range then Failed := True; return; end if;
               Face_Points (K) := Add (P.Position, Transform (P.Rotation, V (Facets (Id).Indices (Count-1-K))));
            end loop;
         elsif S.Rigid.Kind = Cylinder then
            Count := 16; Sign := (if Id = 0 then 1.0 else -1.0);
            for K in 0 .. 15 loop
               Local_Point := [Cos_16 (K)*S.Rigid.Size (0), -Sin_16 (K)*S.Rigid.Size (0)*Sign, Sign*S.Rigid.Size (1)];
               Face_Points (K) := Add (P.Position, Transform (P.Rotation, Local_Point));
            end loop;
         elsif S.Rigid.Kind = Box then
            Count := 4;
            case Id is
               when 0 => Table := [[1,1,1],[1,1,-1],[1,-1,-1],[1,-1,1]];
               when 1 => Table := [[-1,1,-1],[-1,1,1],[-1,-1,1],[-1,-1,-1]];
               when 2 => Table := [[-1,1,-1],[1,1,-1],[1,1,1],[-1,1,1]];
               when 3 => Table := [[-1,-1,1],[1,-1,1],[1,-1,-1],[-1,-1,-1]];
               when 4 => Table := [[-1,1,1],[1,1,1],[1,-1,1],[-1,-1,1]];
               when 5 => Table := [[1,1,-1],[-1,1,-1],[-1,-1,-1],[1,-1,-1]];
               when others => Failed := True; Count := 0; return;
            end case;
            for K in 0 .. 3 loop
               for L in Axis loop Local_Point (L) := Real (Table (K, L))*S.Rigid.Size (L); end loop;
               Face_Points (K) := Add (P.Position, Transform (P.Rotation, Local_Point));
            end loop;
         end if;
      end Recover;
      procedure Push (Point : Vec) is
      begin
         if NC = Max_Polygon then Failed := True; return; end if;
         Polygons (not Active) (NC) := Point; NC := NC+1;
      end Push;
      function Area (A, B, C, D : Natural) return Real is
        (0.5*Norm (Cross (Sub (Polygons (Active) (A), Polygons (Active) (C)), Sub (Polygons (Active) (B), Polygons (Active) (D)))));
      procedure Hull4 is
         B, C, D, Next : Natural;
         Area_Now, Area_Next : Real;
      begin
         B := 1; C := 2; D := 3; Area_Now := Area (0, B, C, D);
         for A in 0 .. NP-1 loop
            for Step_D in 0 .. NP-1 loop
               Next := (D+1) mod NP; Area_Next := Area (A, B, C, Next); exit when Area_Next <= Area_Now;
               D := Next; Area_Now := Area_Next; Keep := [A, B, C, D];
               for Step_C in 0 .. NP-1 loop
                  Next := (C+1) mod NP; Area_Next := Area (A, B, Next, D); exit when Area_Next <= Area_Now;
                  C := Next; Area_Now := Area_Next; Keep := [A, B, C, D];
               end loop;
               for Step_B in 0 .. NP-1 loop
                  Next := (B+1) mod NP; Area_Next := Area (A, Next, C, D); exit when Area_Next <= Area_Now;
                  B := Next; Area_Now := Area_Next; Keep := [A, B, C, D];
               end loop;
            end loop;
            if B = A then B := (B+1) mod NP; if C = B then C := (C+1) mod NP; if D = C then D := (D+1) mod NP; end if; end if; end if;
         end loop;
      end Hull4;
      procedure Emit (K : Natural) is
      begin
         Dist := Dot (Sub (Polygons (Active) (K), Face1 (0)), Normal);
         First := Add (Polygons (Active) (K), Scale (Witness_Dir, -abs Dist)); Second := Polygons (Active) (K);
         if Edge1 then Diff := First; First := Second; Second := Diff; end if;
         M.Items (M.Length) := (Position => Scale (Add (First, Second), 0.5), Normal => Unit (Sub (First, Second)), Tangent => Zero, Distance => Dist);
         M.Length := M.Length+1;
      end Emit;
   begin
      Result := Success;
      if (A.Kind = Primitive and A.Rigid.Kind not in Box | Cylinder)
        or (B.Kind = Primitive and B.Rigid.Kind not in Box | Cylinder)
        or (A.Kind = Hull and A.Facet_Count = 0) or (B.Kind = Hull and B.Facet_Count = 0) then return; end if;
      F1.I := I1; F2.I := I2; F1.V := P1; F2.V := P2; Identify (F1); Identify (F2);
      Normals (A, PA, Dir, F1); Normals (B, PB, Scale (Dir, -1.0), F2);
      if Failed then M.Length := 0; Result := Capacity_Limit; return; end if;
      Found := False;
      for K in 0 .. F1.Count-1 loop
         for L in 0 .. F2.Count-1 loop if Dot (F1.N (K), F2.N (L)) < -0.996 then I := K; J := L; Found := True; exit; end if; end loop;
         exit when Found;
      end loop;
      if not Found then
         if F1.Dim < 3 and F1.Dim <= F2.Dim then
            Edges (A, PA, F1);
            for L in 0 .. F2.Count-1 loop
               if Dot (F2.N (L), Scale (Dir, -1.0)) > Min_Val then
                  for K in 0 .. F1.Count-1 loop if abs Dot (F1.N (K), F2.N (L)) < 0.0888 then I := K; J := L; Found := True; Edge1 := True; exit; end if; end loop;
               end if;
               exit when Found;
            end loop;
         elsif F2.Dim < 3 then
            Edges (B, PB, F2);
            for L in 0 .. F1.Count-1 loop
               if Dot (F1.N (L), Dir) > Min_Val then
                  for K in 0 .. F2.Count-1 loop if abs Dot (F2.N (K), F1.N (L)) < 0.0888 then I := K; J := L; Found := True; Edge2 := True; exit; end if; end loop;
               end if;
               exit when Found;
            end loop;
         end if;
      end if;
      if Failed then M.Length := 0; Result := Capacity_Limit; return; end if;
      if not Found then return; end if;
      if Edge1 then Face1 (0) := F1.V (0); Face1 (1) := F1.Ends (I); NFace1 := 2;
      else Recover (A, PA, F1.Id ((if Edge2 then J else I)), Face1, NFace1); end if;
      if Edge2 then Face2 (0) := F2.V (0); Face2 (1) := F2.Ends (I); NFace2 := 2;
      else Recover (B, PB, F2.Id (J), Face2, NFace2); end if;
      if Failed then M.Length := 0; Result := Capacity_Limit; return; end if;
      if Edge1 then
         declare Swap : Points; Count : constant Natural := NFace1; begin
            for K in 0 .. NFace1-1 loop Swap (K) := Face1 (K); end loop;
            for K in 0 .. NFace2-1 loop Face1 (K) := Face2 (K); end loop;
            for K in 0 .. Count-1 loop Face2 (K) := Swap (K); end loop;
            NFace1 := NFace2; NFace2 := Count;
         end;
         Normal := F2.N (J); Witness_Dir := Scale (Normal, -1.0);
      elsif Edge2 then Normal := F1.N (J); Witness_Dir := Scale (Normal, -1.0);
      else Normal := F1.N (I); Witness_Dir := F2.N (J); end if;
      if NFace1 < 3 then return; end if;
      NP := NFace2; for K in 0 .. NP-1 loop Polygons (Active) (K) := Face2 (K); end loop;
      for E in 0 .. NFace1-1 loop
         --  Preserve C's (v1+n)-v1 rounding when constructing the side plane.
         PN := Unit (Cross (Sub (Face1 ((E+1) mod NFace1), Face1 (E)), Sub (Add (Face1 (E), Normal), Face1 (E)))); PD := Dot (PN, Face1 (E)); NC := 0;
         for K in 0 .. NP-1 loop
            P := Polygons (Active) (K); Q := Polygons (Active) ((K+1) mod NP); PQ := Sub (Q, P);
            Inside1 := Dot (Sub (P, Face1 (E)), PN) > -Min_Val; Inside2 := Dot (Sub (Q, Face1 (E)), PN) > -Min_Val;
            if Inside1 and Inside2 then Push (Q);
            elsif Inside1 or Inside2 then
               Denominator := Dot (PN, PQ);
               if Denominator /= 0.0 then T := (PD-Dot (PN, P))/Denominator; if T in 0.0 .. 1.0 then Push (Add (P, Scale (PQ, T))); end if; end if;
               if Inside2 then Push (Q); end if;
            end if;
            exit when Failed;
         end loop;
         if Failed then M.Length := 0; Result := Capacity_Limit; return; end if;
         --  Like C's pointer swap, alternate the active buffer instead of
         --  copying the polygon after every clipping plane.
         Active := not Active; NP := NC;
      end loop;
      NC := 0;
      for K in 0 .. NP-1 loop if Dot (Sub (Polygons (Active) (K), Face1 (0)), Normal) <= 0.0 then Polygons (Active) (NC) := Polygons (Active) (K); NC := NC+1; end if; end loop;
      --  Native edge-face recovery flips the original witnesses even when
      --  clipping produces no polygon.  Keep the valid EPA fallback normal.
      NP := NC; if NP = 0 then return; end if;
      if NP > 4 then Hull4; NKeep := 4;
      elsif NFace2 = 2 and NP > 2 then
         Max_Dist := 0.0; Best1 := 0; Best2 := 1;
         for K in 0 .. NP-1 loop for L in K+1 .. NP-1 loop Diff := Sub (Polygons (Active) (L), Polygons (Active) (K)); Dist := Dot (Diff, Diff); if Dist > Max_Dist then Max_Dist := Dist; Best1 := K; Best2 := L; end if; end loop; end loop;
         Keep (0) := Best1; Keep (1) := Best2; NKeep := 2;
      else NKeep := NP; for K in 0 .. NP-1 loop Keep (K) := K; end loop; end if;
      M.Length := 0; for K in 0 .. NKeep-1 loop Emit (Keep (K)); end loop;
   end Expand;
end MJ.Contact_Features;
