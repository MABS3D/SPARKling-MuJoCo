with MJ.Rigid_Math; use MJ.Rigid_Math;
with MJ.Rigid_Support;
with MJ.Primitive_Contacts;
with MJ.Contact_Perturbations;
with MJ.Convex_Assets;
package body MJ.Advanced_Contacts with SPARK_Mode is
   procedure Plane_Hull (B : Object; PA, PB : Pose; V : Vertex_Array; F : Facet_Array;
                         Margin : Real; M : in out Manifold; Result : out Status; Graphs : Graph_Array := Empty_Graph) is
      N : constant Vec := Column (PA.Rotation, 2);
      Local_N : constant Vec := Local (PB.Rotation, N);
      Point, Search_Direction : Vec;
      Vertex_Index : Natural;
      Id : Integer; Cache : Integer := -1;
      Best : Integer := -1;
      Best_Dot : Real := 1.0;
      D, Value, Area_Now, Area_Next : Real;
      Anchor, BIdx, CIdx, DIdx, Next, Count : Natural;
      Keep : array (Natural range 0 .. 3) of Natural;
      function Area (A, B, C, D : Natural; Poly : Facet) return Real is
        (0.5*Norm (Cross (Sub (V (Poly.Indices (A)), V (Poly.Indices (C))), Sub (V (Poly.Indices (B)), V (Poly.Indices (D))))));
      procedure Emit (P : Vec; Dist : Real) is
      begin
         M.Items (M.Length) := (Position => Add (P, Scale (N, -0.5*Dist)), Distance => Dist, Normal => N, Tangent => Zero);
         M.Length := M.Length+1;
      end Emit;
   begin
      M.Length := 0; Result := Success;
      --  C uses a straight vertex search for small hulls.  There is no
      --  incoming cache here, so avoid the graph/cache wrapper in that case.
      if B.Kind = Hull and B.Length < 10 then
         Search_Direction := Local (PB.Rotation, Scale (N, -1.0));
         Vertex_Index := MJ.Convex_Assets.Best_Vertex (V, B.First, B.Length, Search_Direction, B.First);
         Id := Integer (Vertex_Index);
         Point := Add (PB.Position, Transform (PB.Rotation, V (Vertex_Index)));
         if B.Skin > 0.0 then Point := Add (Point, Scale (Scale (N, -1.0), B.Skin)); end if;
      else
         MJ.Convex_Contacts.Support_Cached (B, PB, V, Scale (N, -1.0), Graphs, Cache, Point, Id);
      end if;
      D := Dot (N, Sub (Point, PA.Position)); if D > Margin then return; end if; Emit (Point, D);
      if B.Facet_Count = 0 or B.Skin > 0.0 then return; end if;
      if B.First_Facet < F'First or else B.First_Facet > F'Last or else B.Facet_Count > F'Last-B.First_Facet+1 then
         M.Length := 0; Result := Capacity_Limit; return;
      end if;
      for K in B.First_Facet .. B.First_Facet+B.Facet_Count-1 loop
         for L in 0 .. F (K).Length-1 loop
            if Integer (F (K).Indices (L)) = Id then
               Value := Dot (F (K).Normal, Local_N);
               if Value < Best_Dot then Best_Dot := Value; Best := K; end if; exit;
            end if;
         end loop;
      end loop;
      if Best < 0 then return; end if;
      --  C keeps a view of the compiled polygon.  A read-only rename avoids
      --  copying the entire fixed-capacity facet for its active few vertices.
      declare
         Poly_Index : constant Natural := Natural (Best);
         Poly : Facet renames F (Poly_Index);
      begin
         if Poly.Length < 3 then M.Length := 0; Result := Numeric_Limit; return; end if;
         for K in 0 .. Poly.Length-1 loop if Poly.Indices (K) not in V'Range then M.Length := 0; Result := Capacity_Limit; return; end if; end loop;
         Anchor := 0;
         for K in 0 .. Poly.Length-1 loop if Integer (Poly.Indices (K)) = Id then Anchor := K; exit; end if; end loop;
         BIdx := (Anchor+1) mod Poly.Length; CIdx := (Anchor+2) mod Poly.Length; DIdx := (Anchor+3) mod Poly.Length;
         Keep := [Anchor, BIdx, CIdx, DIdx]; Count := Natural'Min (4, Poly.Length);
         if Poly.Length > 4 then
            Area_Now := Area (Anchor, BIdx, CIdx, DIdx, Poly);
            for Step in 0 .. Poly.Length-1 loop
               Next := (DIdx+1) mod Poly.Length; Area_Next := Area (Anchor, BIdx, CIdx, Next, Poly); exit when Area_Next <= Area_Now;
               DIdx := Next; Area_Now := Area_Next; Keep := [Anchor, BIdx, CIdx, DIdx];
               for Step_C in 0 .. Poly.Length-1 loop
                  Next := (CIdx+1) mod Poly.Length; Area_Next := Area (Anchor, BIdx, Next, DIdx, Poly); exit when Area_Next <= Area_Now;
                  CIdx := Next; Area_Now := Area_Next; Keep := [Anchor, BIdx, CIdx, DIdx];
               end loop;
               for Step_B in 0 .. Poly.Length-1 loop
                  Next := (BIdx+1) mod Poly.Length; Area_Next := Area (Anchor, Next, CIdx, DIdx, Poly); exit when Area_Next <= Area_Now;
                  BIdx := Next; Area_Now := Area_Next; Keep := [Anchor, BIdx, CIdx, DIdx];
               end loop;
            end loop;
         end if;
         for K in 1 .. Count-1 loop
            Point := Add (PB.Position, Transform (PB.Rotation, V (Poly.Indices (Keep (K)))));
            D := Dot (N, Sub (Point, PA.Position));
            if D <= Margin and Dot (N, Sub (Point, PB.Position)) <= 0.0 then Emit (Point, D); end if;
         end loop;
      end;
   end Plane_Hull;

   procedure Generate (A, B : Object; PA, PB : Pose; V : Vertex_Array; F : Facet_Array;
                       Margin : Real; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                       M : in out Manifold; Result : out Status; Graphs : Graph_Array := Empty_Graph;
                       Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup) is
      function Radius (S : Object) return Real is
         R : Real := 0.0;
      begin
         if S.Kind = Primitive then return MJ.Rigid_Support.Radius (S.Rigid); end if;
         --  Compiled mesh geom_size contains its local AABB half-extents,
         --  whose diagonal is MuJoCo's geom_rbound used for distinctness.
         if S.Kind = Hull and S.Skin = 0.0 then return Norm (S.Rigid.Size); end if;
         if S.Kind = Prism then for X of S.Prism_Vertices loop R := Real'Max (R, Norm (X)); end loop;
         else for K in S.First .. S.First+S.Length-1 loop R := Real'Max (R, Norm (V (K))); end loop; end if;
         return R+S.Skin;
      end Radius;
      function Curved (S : Object) return Boolean is (S.Kind /= Primitive or else S.Rigid.Kind not in Sphere | Ellipsoid);
   begin
      if A.Kind = Hull and B.Kind = Primitive then
         --  C orders primitive before mesh.  Re-enter once with that order;
         --  the public variant decreases from one to zero on this call.
         Generate (B, A, PB, PA, V, F, Margin, O, W, M, Result, Graphs, Incidence);
         Reverse_Manifold (M); return;
      end if;
      if A.Kind = Primitive and B.Kind = Primitive then
         MJ.Primitive_Contacts.Generate (A.Rigid, B.Rigid, PA, PB, Margin, O, W, M, Result);
      elsif A.Kind = Primitive and A.Rigid.Kind = Plane then Plane_Hull (B, PA, PB, V, F, Margin, M, Result, Graphs);
      elsif B.Kind = Primitive and B.Rigid.Kind = Plane then Plane_Hull (A, PB, PA, V, F, Margin, M, Result, Graphs); Reverse_Manifold (M);
      else
         MJ.Convex_Contacts.Generate (A, B, PA, PB, V, Margin, O, W, M, Result, F, Multiple => True,
                                     Graphs => Graphs, Incidence => Incidence);
         if Result = Success and M.Length = 1 and Curved (A) and Curved (B)
           and (Margin > 0.0 or (A.Kind = Primitive and A.Rigid.Kind = Capsule) or (B.Kind = Primitive and B.Rigid.Kind = Capsule)) then
            MJ.Contact_Perturbations.Expand (A, B, PA, PB, V, Margin, Radius (A), Radius (B), O, W, M, Result, Graphs);
         end if;
      end if;
   end Generate;
end MJ.Advanced_Contacts;
