with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;
with MJ.Collision_Poses;
with MJ.Rigid_Math; use MJ.Rigid_Math;
package body MJ.SDF_Collisions with SPARK_Mode is
   function Halton (Index : Natural; Base : Positive) return Real is
      I : Natural := Index;
      Fraction : Real := 1.0;
      R : Real := 0.0;
   begin
      while I > 0 loop
         pragma Loop_Variant (Decreases => I);
         Fraction := Fraction / Real (Base);
         R := R + Fraction * Real (I mod Base); I := I / Base;
      end loop;
      return R;
   end Halton;

   function Relative_Pose (A, B : Pose) return Pose is
     (MJ.Collision_Poses.Relative (A,B));

   procedure Query (F : Field; T : Octree; X : Vec; Need_Gradient : Boolean;
                    Value : out Real; Gradient : out Vec; Result : out Status) is
   begin
      Value := 0.0; Gradient := Zero; Result := Invalid_Input;
      if not Fields_Admitted and then not Valid (F, T) then return; end if;
      if (for some Q of X => Q not in -1.0e10 .. 1.0e10) then Result := Numeric_Limit; return; end if;
      if F.Kind = Custom then Custom_Query (F.Key, X, Need_Gradient, Value, Gradient, Result);
      elsif Fields_Admitted then MJ.SDF_Fields.Evaluate_Admitted (F, T, X, Need_Gradient, Value, Gradient, Result);
      else MJ.SDF_Fields.Evaluate (F, T, X, Need_Gradient, Value, Gradient, Result); end if;
      if Result = Success and then (Value not in -1.0e100 .. 1.0e100
        or else (for some Q of Gradient => Q not in -1.0e60 .. 1.0e60)) then
         Result := Numeric_Limit; Value := 0.0; Gradient := Zero;
      end if;
   end Query;

   procedure Evaluate (P : Problem; T : Octree; X : Vec; Need_Gradient : Boolean;
                       Value : out Real; Gradient : out Vec; Result : out Status) is
      Y, G1, G2 : Vec;
      A, B, Unused : Real;
      Sign : Real;
   begin
      Value := 0.0; Gradient := Zero;
      Query (P.A, T, X, False, A, G1, Result);
      if Result /= Success then return; end if;
      if P.Kind = Single then
         Value := A;
         if Need_Gradient then Query (P.A, T, X, True, Unused, Gradient, Result); end if;
         return;
      end if;
      if not Valid_Pose (P.Relative) then Result := Invalid_Input; return; end if;
      Y := Add (Transform (P.Relative.Rotation, X), P.Relative.Position);
      Query (P.B, T, Y, False, B, G2, Result);
      if Result /= Success then return; end if;
      Value := Combine_Value (A, B, Objective'Pos (P.Kind));
      if not Need_Gradient then return; end if;
      if P.Kind = Intersection then
         if A > B then Query (P.A, T, X, True, Unused, Gradient, Result);
         else
            Query (P.B, T, Y, True, Unused, G2, Result);
            if Result = Success then Gradient := Local (P.Relative.Rotation, G2); end if;
         end if;
         return;
      end if;
      Query (P.A, T, X, True, Unused, G1, Result); if Result /= Success then return; end if;
      Query (P.B, T, Y, True, Unused, G2, Result); if Result /= Success then return; end if;
      if P.Kind = Midsurface then
         G1 := Unit (G1); G2 := Unit (Local (P.Relative.Rotation, G2));
         Gradient := Unit (Sub (G1, G2));
      else
         G2 := Local (P.Relative.Rotation, G2);
         Gradient := Add (G1, G2);
         Sign := (if Real'Max (A, B) > 0.0 then 1.0 else -1.0);
         Gradient := Add (Gradient, Scale ((if A > B then G1 else G2), Sign));
      end if;
   end Evaluate;

   procedure Descent (P : Problem; T : Octree; Iterations : Natural;
                      X : in out Vec; Depth : out Real; Result : out Status) is
      G, X0, Unused_G : Vec;
      D0, Unused, Alpha, Wolfe : Real;
   begin
      Depth := Max_Val; Result := Success;
      for Step in 1 .. Iterations loop
         Evaluate (P, T, X, True, Unused, G, Result);
         if Result /= Success then Depth := Max_Val; return; end if;
         if (for some Q of G => Q not in -Max_Val .. Max_Val) then Result := Numeric_Limit; Depth := Max_Val; return; end if;
         X0 := X; Evaluate (P, T, X0, False, D0, Unused_G, Result);
         if Result /= Success then return; end if;
         Alpha := 2.0; Wolfe := -0.1 * Alpha * Dot (G, G);
         loop
            Alpha := Alpha * 0.5; Wolfe := Wolfe * 0.5;
            X := Add (X0, Scale (G, -Alpha));
            Evaluate (P, T, X, False, Depth, Unused_G, Result);
            if Result /= Success then Depth := Max_Val; return; end if;
            exit when Alpha <= 1.0e-4 or else Depth - D0 <= Wolfe;
         end loop;
         if D0 < Depth then X := X0; Depth := D0; return; end if;
      end loop;
   end Descent;

   procedure Add_Contact (P : Problem; T : Octree; X : Vec; Depth : Real; PB : Pose;
                          Flip : Boolean; Points : in out Vertex_Array;
                          M : in out Manifold; Added : out Boolean; Result : out Status) is
      G, N : Vec;
      D, Len, Scl : Real;
   begin
      Added := False; Result := Success;
      if Depth > 0.0 or M.Length = Max_Manifold then return; end if;
      for I in 0 .. M.Length - 1 loop
         if Norm (Sub (X, Points (I))) < Min_Val then return; end if;
      end loop;
      Evaluate (P, T, X, True, D, G, Result);
      if Result = Numeric_Limit then Result := Success; return; end if;
      if Result /= Success then return; end if;
      Len := Norm (G); if Len < Min_Val then return; end if;
      N := Scale (G, 1.0/Len); if not Flip then N := Scale (N, -1.0); end if;
      N := MJ.Collision_Poses.Rotate (MJ.Collision_Poses.From_Matrix (PB.Rotation), N);
      Scl := (if Flip then -0.5*Depth else 0.5*Depth);
      M.Items (M.Length) := (Normal => N, Distance => Depth, Tangent => Zero,
         Position => Add (Add (MJ.Collision_Poses.Rotate (MJ.Collision_Poses.From_Matrix (PB.Rotation), X), PB.Position), Scale (N, Scl)));
      Points (M.Length) := X; M.Length := M.Length + 1; Added := True;
   end Add_Contact;

   procedure Generate_Admitted (A, B : Field; T : Octree; PA, PB : Pose;
                       O : Search_Options; M : in out Manifold; Result : out Status) is
      P : Problem := (A => B, B => A, Relative => Relative_Pose (PB, PA), Kind => Collision);
      Map : constant Pose := Relative_Pose (PA, PB);
      Back : constant Pose := Relative_Pose (PB, PA);
      Self_Map : constant Pose := Relative_Pose (PA, PA);
      Lo, Hi : Vec := Zero;
      V, X, Unused : Vec;
      D : Real;
      Points : Vertex_Array (0 .. Max_Manifold - 1) := [others => Zero];
      Added : Boolean;
      Min2 : Vec := [others => Real'Last];
      Max2 : Vec := [others => -Real'Last];
   begin
      M.Length := 0; Result := Success;
      if not Valid_Pose (Map) or not Valid_Pose (Back) then Result := Numeric_Limit; return; end if;
      for J in 0 .. 7 loop
         for K in Axis loop
            V (K) := B.Bounds.Center (K) + (if (J/(2**K)) mod 2 = 1 then B.Bounds.Half (K) else -B.Bounds.Half (K));
         end loop;
         V := Add (Transform (Back.Rotation, V), Back.Position);
         for K in Axis loop Min2 (K) := Real'Min (Min2 (K), V (K)); Max2 (K) := Real'Max (Max2 (K), V (K)); end loop;
      end loop;
      for K in Axis loop
         Lo (K) := Real'Max (A.Bounds.Center (K) - A.Bounds.Half (K), Min2 (K));
         Hi (K) := Real'Min (A.Bounds.Center (K) + A.Bounds.Half (K), Max2 (K));
         if Hi (K) < Lo (K) then return; end if;
      end loop;
      for J in 0 .. O.Starts - 1 loop
         X := [Lo (0)+(Hi (0)-Lo (0))*Halton (J, 2),
               Lo (1)+(Hi (1)-Lo (1))*Halton (J, 3),
               Lo (2)+(Hi (2)-Lo (2))*Halton (J, 5)];
         X := Add (Transform (Self_Map.Rotation,X),Self_Map.Position);
         X := Add (Transform (Map.Rotation, X), Map.Position);
         P.Kind := Collision; Descent (P, T, O.Iterations, X, D, Result);
         if Result = Invalid_Input then M.Length := 0; return; end if;
         P.Kind := Intersection; Descent (P, T, 1, X, D, Result);
         if Result = Numeric_Limit then Result := Success;
         elsif Result /= Success then M.Length := 0; return;
         else
            P.Kind := Midsurface; Add_Contact (P, T, X, D, PB, False, Points, M, Added, Result);
            if Result /= Success then M.Length := 0; return; end if;
         end if;
         exit when M.Length = Max_Manifold;
      end loop;
   end Generate_Admitted;

   procedure Generate (A, B : Field; T : Octree; PA, PB : Pose;
                       O : Search_Options; M : in out Manifold; Result : out Status) is
   begin
      Generate_Admitted (A, B, T, PA, PB, O, M, Result);
   end Generate;

   procedure Frank_Wolfe (P : Problem; T : Octree; V : Vertex_Array; Steps : Natural;
                          X : in out Vec; D : out Real; Result : out Status) is
      G, Best_Point, Unused : Vec;
      Best, Value : Real;
   begin
      D := Max_Val; Result := Success;
      for Step in 0 .. Steps - 1 loop
         Evaluate (P, T, X, True, Value, G, Result); if Result /= Success then return; end if;
         Best := Max_Val; Best_Point := Zero;
         for Corner of V loop
            Value := Dot (Corner, G);
            if Value < Best then Best := Value; Best_Point := Corner; end if;
         end loop;
         if Best = Max_Val then Result := Numeric_Limit; D := Max_Val; return; end if;
         X := Add (X, Scale (Sub (Best_Point, X), 2.0/Real (Step + 2)));
      end loop;
      Evaluate (P, T, X, False, D, Unused, Result);
   end Frank_Wolfe;

   procedure Triangle_Hit (P : Problem; T : Octree; V : Vertex_Array;
                           Hit : out Boolean; Result : out Status) is
      Edges1 : constant Vec := Sub (V (1), V (0));
      Edges2 : constant Vec := Sub (V (2), V (0));
      Normal : constant Vec := Unit (Cross (Edges1, Edges2));
      Center : Vec := Add (Add (Scale (V (0), 1.0/3.0), Scale (V (1), 1.0/3.0)), Scale (V (2), 1.0/3.0));
      A, B, C : Vec;
      CA, CB, CC : Vec;
      D, H, L1, L2, L3, S, Area, Radius, Denom : Real;
      Unused : Vec;
   begin
      Hit := False; Evaluate (P, T, Center, False, D, Unused, Result); if Result /= Success then return; end if;
      H := -D/10.0;
      if abs H < 0.1 then
         L1 := Norm (Sub (V (0), V (1))); L2 := Norm (Sub (V (1), V (2))); L3 := Norm (Sub (V (2), V (0)));
         S := ((L1+L2)+L3)/2.0; Area := ((S*(S-L1))*(S-L2))*(S-L3);
         if Area < 0.0 then Result := Numeric_Limit; return; end if;
         Radius := ((L1*L2)*L3)/(4.0*Real'Max (Sqrt (Area), Min_Val));
         Hit := D < Radius; return;
      end if;
      Center := Add (Center, Scale (Normal, -H));
      A := Sub (V (0), Center); B := Sub (V (1), Center); C := Sub (V (2), Center);
      CA := Cross (B, C); CB := Cross (C, A); CC := Cross (A, B);
      Denom := 2.0*Dot (A, CA);
      if abs Denom < Min_Val then Hit := D < Norm (Edges1); return; end if;
      A := Scale (Add (Add (Scale (CA, Dot (A, A)), Scale (CB, Dot (B, B))), Scale (CC, Dot (C, C))), 1.0/Denom);
      Radius := Norm (A); Center := Add (A, Center);
      Evaluate (P, T, Center, False, D, Unused, Result); Hit := Result = Success and then D < Radius;
   end Triangle_Hit;

   function Fits (Faces : Triangle_Array; Tree : MJ.BVH.Tree) return Boolean is
      Seen : array (Natural range 0 .. MJ.BVH.Max_Leaves-1) of Boolean := [others=>False];
      Lo,Hi : Vec;
      B : MJ.BVH.Box;
      Item : Integer;
   begin
      if Faces'First/=0 or Faces'Length>MJ.BVH.Max_Leaves then return False; end if;
      for F of Faces loop
         if (for some V of F.Corners => (for some Q of V => Q not in Coordinate)) then return False; end if;
      end loop;
      for I in 0 .. Tree.Length-1 loop
         Item:=Tree.Nodes (I).Item;
         if Item>=0 then
            if Item not in Faces'Range then return False; end if;
            Lo:=Faces (Item).Corners (0); Hi:=Lo;
            for J in 1 .. 2 loop
               for K in Axis loop
                  Lo (K):=Real'Min (Lo (K),Faces (Item).Corners (J)(K));
                  Hi (K):=Real'Max (Hi (K),Faces (Item).Corners (J)(K));
               end loop;
            end loop;
            for K in Axis loop B.Center (K):=0.5*(Hi (K)+Lo (K)); B.Half (K):=0.5*(Hi (K)-Lo (K)); end loop;
            if not MJ.BVH.Contains (Tree.Nodes (I).Bounds,B) then return False; end if;
            Seen (Item):=True;
         end if;
      end loop;
      return (for all I in Faces'Range => Seen (I));
   end Fits;

   procedure Triangles (S : Field; T : Octree; Faces : Triangle_Array;
                        Tree : MJ.BVH.Tree; PA, PB : Pose;
                        Path : Triangle_Path; O : Search_Options;
                        M : in out Manifold; IDs : out Id_Array; Result : out Status) is
      P : constant Problem := (A => S, B => S, Relative => (others => <>), Kind => Single);
      Map : constant Pose := Relative_Pose (PA, PB);
      type Stack_Array is array (Natural range 0 .. MJ.BVH.Max_Nodes - 1) of Natural with Relaxed_Initialization;
      Stack : Stack_Array;
      Top, Node : Natural;
      Global_Points : Vertex_Array (0 .. Max_Manifold - 1) := [others => Zero];
      Candidates : Vertex_Array (0 .. Max_Manifold - 1) := [others => Zero];
      Depths : array (Natural range 0 .. Max_Manifold - 1) of Real := [others=>Max_Val];
      Candidate_IDs : array (Natural range 0 .. Max_Manifold - 1) of Natural := [others=>0];
      N : Natural := 0;
      Hit, Added : Boolean;
      X, Unused : Vec;
      D : Real;
      procedure Process (Index : Natural) is
         V : Vertex_Array (0 .. 2);
         Local_Points : Vertex_Array (0 .. Max_Manifold - 1) := [others => Zero];
         Local_Depths : array (Natural range 0 .. Max_Manifold - 1) of Real := [others=>Max_Val];
         Points : Vertex_Array (0 .. Max_Manifold - 1) := [others => Zero];
         Temp : Manifold;
         L, Best : Natural := 0;
         U, W, B0 : Real;
      begin
         if Index not in Faces'Range then Result := Invalid_Input; return; end if;
         for K in 0 .. 2 loop V (K) := Add (Transform (Map.Rotation, Faces (Index).Corners (K)), Map.Position); end loop;
         Triangle_Hit (P, T, V, Hit, Result);
         if Result = Numeric_Limit then Result := Success; return; end if;
         if Result /= Success or not Hit then return; end if;
         for J in 1 .. Natural'Max (1, O.Starts) loop
            U := Halton (J, 2); W := Halton (J, 3);
            if U + W > 1.0 then U := 1.0-U; W := 1.0-W; end if;
            B0 := (1.0-U)-W;
            for K in Axis loop X (K) := (B0*V (0)(K)+U*V (1)(K))+W*V (2)(K); end loop;
            Frank_Wolfe (P, T, V, O.Iterations, X, D, Result);
            if Result = Numeric_Limit then Result := Success;
            elsif Result /= Success then return;
            elsif D < 0.0 then
               if Path = Tree_Mesh then
                  if N = Max_Manifold then exit; end if;
                  Candidates (N) := X; Depths (N) := D; Candidate_IDs (N) := Faces (Index).Id; N := N+1;
               else
                  Local_Points (L) := X; Local_Depths (L) := D; L := L+1;
                  exit when L = Max_Manifold;
               end if;
            end if;
         end loop;
         if Path = Tree_Flex and L > 0 then
            for J in 1 .. L-1 loop if Local_Depths (J) < Local_Depths (Best) then Best := J; end if; end loop;
            if N < Max_Manifold then
               Candidates (N) := Local_Points (Best); Depths (N) := Local_Depths (Best);
               Candidate_IDs (N) := Faces (Index).Id; N := N+1;
            end if;
         elsif Path = Linear_Flex then
            Temp.Length := 0;
            for J in 0 .. L-1 loop
               Add_Contact (P, T, Local_Points (J), Local_Depths (J), PB, True, Points, Temp, Added, Result);
               if Result /= Success then return; end if;
               if Added then
                  if M.Length = IDs'Length then Result := Capacity_Limit; return; end if;
                  M.Items (M.Length) := Temp.Items (Temp.Length-1); IDs (IDs'First+M.Length) := Faces (Index).Id;
                  M.Length := M.Length+1;
                  exit when M.Length = Max_Manifold;
               end if;
            end loop;
         end if;
      end Process;
   begin
      M.Length := 0; IDs := [others => 0]; Result := Success;
      if not Valid_Pose (Map) or else (for some F of Faces =>
        (for some V of F.Corners => (for some Q of V => Q not in -1.0e10 .. 1.0e10))) then
         Result := Invalid_Input; return;
      end if;
      if Path = Linear_Flex then
         for I in Faces'Range loop
            Process (I); if Result /= Success then M.Length := 0; return; end if;
            exit when M.Length = Max_Manifold;
         end loop;
         return;
      end if;
      if Tree.Length = 0 then return; end if;
      Stack (0) := 0; Top := 1;
      while Top > 0 loop
         pragma Loop_Invariant (for all I in 0 .. Top-1 => Stack (I)'Initialized);
         Top := Top-1; Node := Stack (Top);
         X := Add (Transform (Map.Rotation, Tree.Nodes (Node).Bounds.Center), Map.Position);
         Evaluate (P, T, X, False, D, Unused, Result);
         if Result /= Success then M.Length := 0; return; end if;
         if D < Norm (Tree.Nodes (Node).Bounds.Half) then
            if Tree.Nodes (Node).Item >= 0 then Process (Tree.Nodes (Node).Item);
            else
               Stack (Top) := Tree.Nodes (Node).Left; Stack (Top+1) := Tree.Nodes (Node).Right; Top := Top+2;
            end if;
            if Result /= Success then M.Length := 0; return; end if;
         end if;
      end loop;
      for I in 0 .. N-1 loop
         if M.Length = IDs'Length then Result := Capacity_Limit; M.Length := 0; return; end if;
         Add_Contact (P, T, Candidates (I), Depths (I), PB, Path = Tree_Flex, Global_Points, M, Added, Result);
         if Result /= Success then M.Length := 0; return; end if;
         if Added then IDs (IDs'First+M.Length-1) := Candidate_IDs (I); end if;
      end loop;
   end Triangles;
end MJ.SDF_Collisions;
