package body MJ.Spatial_Tendons with SPARK_Mode is
   function Valid_Path (Route : Route_Array; Sites : Site_Array;
                        Geometries : Geometry_Array) return Boolean is
      Branch_Sites : Natural := 0;
   begin
      if Route'First /= 0 or else Route'Length < 2 or else Route'Length > 4096
        or else Route (Route'Last).Kind /= Site_Node
      then
         return False;
      end if;
      for K in Route'Range loop
         case Route (K).Kind is
            when Site_Node =>
               if Route (K).Object_Id not in Sites'Range then
                  return False;
               end if;
               Branch_Sites := Branch_Sites + 1;
            when Geometry_Node =>
               if K = 0 or else K = Route'Last
                 or else Route (K - 1).Kind /= Site_Node
                 or else Route (K + 1).Kind /= Site_Node
                 or else Route (K).Object_Id not in Geometries'Range
                 or else (Route (K).Side_Id /= -1
                   and then Route (K).Side_Id not in Sites'Range)
               then
                  return False;
               end if;
            when Pulley_Node =>
               if (K /= 0 and then Branch_Sites < 2)
                 or else K = Route'Last or else Route (K + 1).Kind /= Site_Node
                 or else Route (K).Divisor not in 1.0e-10 .. 1.0e10
               then
                  return False;
               end if;
               Branch_Sites := 0;
         end case;
         pragma Loop_Invariant (Branch_Sites <= K + 1);
         pragma Loop_Invariant (for all I in 0 .. K => Path_Node_Valid (Route, Sites, Geometries, I));
      end loop;
      return Branch_Sites >= 2;
   end Valid_Path;

   function Point_Column (Linear, Angular, Point, Origin : Vector) return Vector is
      D1 : constant Real range -2.0e30 .. 2.0e30 := Point (1) - Origin (1);
      D2 : constant Real range -2.0e30 .. 2.0e30 := Point (2) - Origin (2);
      D3 : constant Real range -2.0e30 .. 2.0e30 := Point (3) - Origin (3);
      X : constant Real range -5.0e40 .. 5.0e40 := Angular (2) * D3 - Angular (3) * D2;
      Y : constant Real range -5.0e40 .. 5.0e40 := Angular (3) * D1 - Angular (1) * D3;
      Z : constant Real range -5.0e40 .. 5.0e40 := Angular (1) * D2 - Angular (2) * D1;
   begin
      return (Linear (1) + X, Linear (2) + Y, Linear (3) + Z);
   end Point_Column;

   function Flat_Column (Flat : Real_Array; Body_Index, Dof, Dofs : Natural)
     return Vector is
   begin
      return (Flat (3 * (Body_Index * Dofs + Dof)),
              Flat (3 * (Body_Index * Dofs + Dof) + 1),
              Flat (3 * (Body_Index * Dofs + Dof) + 2));
   end Flat_Column;

   procedure Evaluate_Internal
     (Route : Route_Array; Sites : Site_Array; Geometries : Geometry_Array;
      Origins : Vector_Array; Linear, Angular : Body_Jacobian;
      Flat_Linear, Flat_Angular : Real_Array; Flat : Boolean;
      Status : out Evaluation_Status; Length : out Real; J : out Real_Array;
      Points : out Point_Array; Count : out Natural) with
     Pre => Valid_Path (Route, Sites, Geometries) and then J'First = 0 and then J'Length <= 4096
       and then (if Flat then Valid_Flat_Kinematics
         (Sites, Geometries, Origins, Flat_Linear, Flat_Angular, J'Length)
         else Valid_Kinematics (Sites, Geometries, Origins, Linear, Angular, J'Length))
       and then Points'First = 0 and then Points'Length >= 3 * Route'Length
       and then Points'Length <= 12288,
     Post => Count <= Points'Length
       and then (if Status = Success then Length in 0.0 .. 1.0e100
                   and then (for all K in J'Range => J (K) in -1.0e100 .. 1.0e100)
                 else Length = 0.0 and then Count = 0
                   and then (for all K in J'Range => J (K) = 0.0)
                   and then (for all K in Points'Range =>
                     Points (K) = (Position => Zero, Object_Id => -1)))
   is
      Row : Real_Array (J'Range) := (others => 0.0);
      Path : Point_Array (Points'Range) := (others => (others => <>));
      N, I : Natural := 0;
      L : Real := 0.0;
      Divisor : Real := 1.0;
      A, B : Site;
      G : Geometry;
      W : Wrap_Result;
      Side : Vector;
      Last_Node : Natural;
      Geom_Id : Integer;
      P : array (Positive range 1 .. 4) of Vector := (others => Zero);
      Bodies : array (Positive range 1 .. 4) of Natural := (others => 0);
      Legs : Positive range 1 .. 3;
      Direction, C0, C1 : Vector;
      Increment, First_Length, Last_Length : Real;
      procedure Emit (Position : Vector; Object_Id : Integer) with
        Pre => N < Path'Length,
        Post => N = N'Old + 1 and then Path (N'Old) = (Position, Object_Id)
          and then (for all K in Path'Range =>
            (if K /= N'Old then Path (K) = Path'Old (K)))
      is
      begin
         Path (N) := (Position, Object_Id);
         N := N + 1;
      end Emit;
   begin
      Status := Numeric_Limit;
      Length := 0.0;
      Count := 0;
      J := (others => 0.0);
      Points := (others => (others => <>));
      while I < Route'Last loop
         pragma Loop_Variant (Increases => I);
         pragma Loop_Invariant (I <= Route'Last);
         pragma Loop_Invariant (Route (I).Kind /= Geometry_Node);
         pragma Loop_Invariant (Divisor in 1.0e-10 .. 1.0e10);
         pragma Loop_Invariant (N <= 3 * I + 1 and then N <= Path'Length);
         pragma Loop_Invariant (L in 0.0 .. 1.0e100);
         pragma Loop_Invariant (for all K in Row'Range => Row (K) in -1.0e100 .. 1.0e100);
         if Route (I).Kind = Pulley_Node or else Route (I + 1).Kind = Pulley_Node then
            if Route (I).Kind = Pulley_Node then
               Divisor := Route (I).Divisor;
               Emit (Zero, -2);
            end if;
            I := I + 1;
         else
            A := Sites (Route (I).Object_Id);
            Last_Node := I + 1;
            Geom_Id := -1;
            W := (others => <>);
            if Route (I + 1).Kind = Geometry_Node then
               Last_Node := I + 2;
               Geom_Id := Route (I + 1).Object_Id;
               G := Geometries (Geom_Id);
               Side := Zero;
               if Route (I + 1).Side_Id >= 0 then
                  Side := Sites (Route (I + 1).Side_Id).Position;
               end if;
               W := Wrap (A.Position, Sites (Route (Last_Node).Object_Id).Position,
                          G.Position, G.Orientation, G.Radius, G.Kind,
                          Route (I + 1).Side_Id >= 0, Side);
               if W.Status = MJ.Tendon_Geometry.Numeric_Limit then
                  return;
               end if;
            end if;
            B := Sites (Route (Last_Node).Object_Id);
            P (1) := A.Position;
            Bodies (1) := A.Body_Id;
            if W.Status = Wrapped then
               --  Explicit finite output envelope before downstream products.
               if not Bounded (W.First, 1.0e30) or else not Bounded (W.Last, 1.0e30) then
                  return;
               end if;
               P (2) := W.First;
               P (3) := W.Last;
               P (4) := B.Position;
               Bodies (2) := G.Body_Id;
               Bodies (3) := G.Body_Id;
               Bodies (4) := B.Body_Id;
               Legs := 3;
               First_Length := Norm (Sub (P (1), P (2)));
               Last_Length := Norm (Sub (P (3), P (4)));
               --  The runtime sqrt contract has no quantitative upper bound.
               --  Establish it before sums/division; publish nothing on failure.
               if First_Length > 1.0e100 or else Last_Length > 1.0e100 then return; end if;
               Increment := ((First_Length + W.Arc_Length) + Last_Length) / Divisor;
            else
               P (2) := B.Position;
               Bodies (2) := B.Body_Id;
               Legs := 1;
               First_Length := Norm (Sub (P (1), P (2)));
               if First_Length > 1.0e100 then return; end if;
               Increment := First_Length / Divisor;
            end if;
            L := L + Increment;
            if L not in 0.0 .. 1.0e100 then
               return;
            end if;
            for Leg in 1 .. Legs loop
               pragma Loop_Invariant (for all K in Row'Range => Row (K) in -1.0e100 .. 1.0e100);
               if Bodies (Leg) /= Bodies (Leg + 1) then
                  Direction := Unit (Sub (P (Leg + 1), P (Leg)));
                  for K in Row'Range loop
                     pragma Loop_Invariant (for all Q in Row'Range => Row (Q) in -1.0e100 .. 1.0e100);
                     C0 := Point_Column
                       ((if Flat then Flat_Column (Flat_Linear, Bodies (Leg), K, J'Length)
                         else Linear (Bodies (Leg), K)),
                        (if Flat then Flat_Column (Flat_Angular, Bodies (Leg), K, J'Length)
                         else Angular (Bodies (Leg), K)),
                                         P (Leg), Origins (Bodies (Leg)));
                     C1 := Point_Column
                       ((if Flat then Flat_Column (Flat_Linear, Bodies (Leg + 1), K, J'Length)
                         else Linear (Bodies (Leg + 1), K)),
                        (if Flat then Flat_Column (Flat_Angular, Bodies (Leg + 1), K, J'Length)
                         else Angular (Bodies (Leg + 1), K)),
                                         P (Leg + 1), Origins (Bodies (Leg + 1)));
                     Row (K) := Row (K) + (1.0 / Divisor) * Dot (Sub (C1, C0), Direction);
                     if Row (K) not in -1.0e100 .. 1.0e100 then
                        return;
                     end if;
                  end loop;
               end if;
            end loop;
            Emit (A.Position, -1);
            if W.Status = Wrapped then
               Emit (W.First, Geom_Id);
               Emit (W.Last, Geom_Id);
            end if;
            I := Last_Node;
            if I = Route'Last or else Route (I + 1).Kind = Pulley_Node then
               Emit (B.Position, -1);
            end if;
         end if;
      end loop;
      Status := Success;
      Length := L;
      J := Row;
      Points := Path;
      Count := N;
   end Evaluate_Internal;

   procedure Evaluate
     (Route : Route_Array; Sites : Site_Array; Geometries : Geometry_Array;
      Origins : Vector_Array; Linear, Angular : Body_Jacobian;
      Status : out Evaluation_Status; Length : out Real; J : out Real_Array;
      Points : out Point_Array; Count : out Natural) is
      Empty : constant Real_Array (1 .. 0) := (others => 0.0);
   begin
      Evaluate_Internal (Route, Sites, Geometries, Origins, Linear, Angular,
                         Empty, Empty, False, Status, Length, J, Points, Count);
   end Evaluate;

   procedure Evaluate_Flat
     (Route : Route_Array; Sites : Site_Array; Geometries : Geometry_Array;
      Origins : Vector_Array; Linear, Angular : Real_Array;
      Status : out Evaluation_Status; Length : out Real; J : out Real_Array;
      Points : out Point_Array; Count : out Natural) is
      Empty : constant Body_Jacobian (1 .. 0, 1 .. 0) := (others => (others => Zero));
   begin
      Evaluate_Internal (Route, Sites, Geometries, Origins, Empty, Empty,
                         Linear, Angular, True, Status, Length, J, Points, Count);
   end Evaluate_Flat;

   function Project_Component (Previous, Moment, Force : Real) return Real is
     (Previous + Moment * Force);

   function Velocity_Prefix (J, Qvel : Real_Array; Count : Natural) return Real is
     (if Count = 0 then 0.0 else
       Velocity_Add (Velocity_Prefix (J, Qvel, Count - 1),
                     J (Count - 1), Qvel (Count - 1), Count - 1));

   function Velocity (J, Qvel : Real_Array) return Real is
      V : Real := 0.0;
   begin
      for K in J'Range loop
         V := V + J (K) * Qvel (K);
         pragma Loop_Invariant (Static => V = Velocity_Prefix (J, Qvel, K + 1));
         pragma Loop_Invariant (V in -Real (K + 1) * Velocity_Step_Bound .. Real (K + 1) * Velocity_Step_Bound);
      end loop;
      return V;
   end Velocity;

   procedure Project_Force (J : Real_Array; Force : Real; Qforce : in out Real_Array) is
   begin
      for K in J'Range loop
         Qforce (K) := Project_Component (Qforce (K), J (K), Force);
         pragma Loop_Invariant
           (for all I in J'Range => Qforce (I) =
             (if I <= K then Project_Component (Qforce'Loop_Entry (I), J (I), Force)
              else Qforce'Loop_Entry (I)));
      end loop;
   end Project_Force;
end MJ.Spatial_Tendons;
