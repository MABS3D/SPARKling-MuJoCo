with MJ.Types; use MJ.Types;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;
with MJ.Elastic_Network; use MJ.Elastic_Network;
with MJ.Flex_Contact_Kernels; use MJ.Flex_Contact_Kernels;

--  Literal ordered filterFlexContacts, MuJoCo 3.14.0. In particular the
--  selected/distance caches are NOT permuted with contacts, and the final
--  iteration does NOT swap the chosen contact into the retained prefix.
package MJ.Flex_Contact_Filter with SPARK_Mode is
   Max_Contacts : constant := 50;
   subtype Rank is Contact_Rank;
   type Rank_Array is array (Vertex range <>) of Rank;
   subtype Coordinate is Real range -1.0e11 .. 1.0e11;
   type Point is array (Axis) of Coordinate;
   subtype Squared_Distance is Real range 0.0 .. 2.0e23;
   subtype Cached_Distance is Real range 0.0 .. 1.0e10;
   type Contact is record
      Id : Vertex := 1;
      Separation : Distance_Value := 0.0;
      Position : Point := [others => 0.0];
   end record;
   type Contact_Array is array (Vertex range <>) of Contact;
   type Flags is array (Vertex range <>) of Boolean;
   type Distances is array (Vertex range <>) of Cached_Distance;
   type State (Capacity : Vertex) is record
      Items : Contact_Array (1 .. Capacity);
      Used : Count := 0;
      Marked : Flags (1 .. Capacity);
      Minima : Distances (1 .. Capacity);
      Best : Count := 0;
      Kept : Rank := 0;
   end record with Dynamic_Predicate => State.Used <= State.Capacity;
   function Within (S : State; Last : Vertex) return Boolean is
     (for all X of S.Items => X.Id <= Last) with Global => null;
   function Contact_Point (C : Configuration; X : Input_Vector) return Point is
     (declare Offset : constant Real := (-Distance (C, X) * 0.5) - C.Radius;
      begin [X (0) + C.Normal (0) * Offset,
             X (1) + C.Normal (1) * Offset,
             X (2) + C.Normal (2) * Offset])
     with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Distance2 (A, B : Point) return Squared_Distance is
     (declare DX : constant Real := A (0) - B (0);
              DY : constant Real := A (1) - B (1);
              DZ : constant Real := A (2) - B (2);
      begin (DX * DX + DY * DY) + DZ * DZ)
     with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Updated (S : State; I : Vertex) return Cached_Distance is
     (if I > S.Used or else S.Marked (I) or else I = S.Best then S.Minima (I)
      else Real'Min (S.Minima (I), Distance2 (S.Items (I).Position, S.Items (S.Best).Position)))
     with Global => null, Pre => S.Best in 1 .. S.Used and then I <= S.Capacity,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   package Model with Ghost => Static is
      function Empty (Capacity : Vertex) return State is
        ((Capacity => Capacity, Items => [others => <>], Used => 0, Marked => [others => False], Minima => [others => 1.0e10], Best => 0, Kept => 0)) with Global => null;
      function Append (S : State; C : Configuration; P : Particle; V : Vertex) return State is
        (S with delta Used => S.Used + 1,
          Items => (S.Items with delta S.Used + 1 =>
            (V, Distance (C, P.Position), Contact_Point (C, P.Position))))
        with Global => null, Pre => S.Used < S.Capacity;
      function Contacts (C : Configuration; P : Particle_Array; N : Count) return State is
        (if N = 0 then Empty (P'Length)
         else (declare S : constant State := Contacts (C, P, N - 1);
           begin (if not Included (C, P (N).Position) then S
             else Append (S, C, P (N), N))))
        with Global => null, Pre => P'First = 1 and then P'Length > 0 and then N <= P'Length,
        Subprogram_Variant => (Decreases => N),
        Post => Contacts'Result.Capacity = P'Length and then Contacts'Result.Used <= N and then Within (Contacts'Result, P'Last)
          and then Contacts'Result.Best = 0 and then Contacts'Result.Kept = 0
          and then Contacts'Result.Marked = Flags'[1 .. P'Length => False]
          and then Contacts'Result.Minima = Distances'[1 .. P'Length => 1.0e10],
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Deepest (S : State; N : Vertex) return Vertex is
        (if N = 1 then 1
         else (declare B : constant Vertex := Deepest (S, N - 1);
           begin (if -S.Items (N).Separation > -S.Items (B).Separation then N else B)))
        with Global => null, Pre => N <= S.Used,
        Subprogram_Variant => (Decreases => N), Post => Deepest'Result <= N,
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Next_Best (S : State; N : Count) return Count is
        (if N = 0 then 0
         else (declare B : constant Count := Next_Best (S, N - 1);
           begin (if S.Marked (N) or else N = S.Best then B
             elsif B = 0 or else Updated (S, N) > Updated (S, B) then N else B)))
        with Global => null, Pre => S.Best in 1 .. S.Used and then N <= S.Used,
        Subprogram_Variant => (Decreases => N), Post => Next_Best'Result <= N,
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Transition (S : State) return State is
        (if S.Best = 0 then S
         else (declare B : constant Count := Next_Best (S, S.Used);
                        Swap : constant Boolean := S.Kept < Max_Contacts - 1;
           begin (Capacity => S.Capacity, Items => (if Swap then (S.Items with delta
                     S.Kept + 1 => S.Items (S.Best), S.Best => S.Items (S.Kept + 1)) else S.Items),
             Used => S.Used, Kept => S.Kept + 1,
             Marked => (S.Marked with delta S.Best => True),
             Minima => [for I in 1 .. S.Capacity => Updated (S, I)],
             Best => (if Swap and then B = S.Kept + 1 then S.Best else B))))
        with Global => null,
        Pre => S.Used > Max_Contacts and then S.Best <= S.Used and then S.Kept < Max_Contacts,
        Post => Transition'Result.Capacity = S.Capacity and then Transition'Result.Used = S.Used and then Transition'Result.Best <= S.Used
          and then Transition'Result.Kept <= S.Kept + 1
          and then (for all L in Vertex => (if Within (S, L) then Within (Transition'Result, L))),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Run (S : State; N : Rank) return State is
        (if N = 0 then S else Transition (Run (S, N - 1)))
        with Global => null,
        Pre => S.Used > Max_Contacts and then S.Best <= S.Used and then S.Kept = 0,
        Subprogram_Variant => (Decreases => N),
        Post => Run'Result.Capacity = S.Capacity and then Run'Result.Used = S.Used and then Run'Result.Best <= S.Used
          and then Run'Result.Kept <= N
          and then (for all L in Vertex => (if Within (S, L) then Within (Run'Result, L))),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Filtered (S : State) return State is
        (if S.Used <= Max_Contacts then (S with delta Kept => S.Used)
         else Run ((S with delta Best => Deepest (S, S.Used)), Max_Contacts))
        with Global => null, Pre => S.Kept = 0,
        Post => Filtered'Result.Capacity = S.Capacity and then Filtered'Result.Kept <= S.Capacity
          and then (for all L in Vertex => (if Within (S, L) then Within (Filtered'Result, L))),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Ranks (S : State; N : Rank) return Rank_Array is
        (if N = 0 then [1 .. S.Capacity => 0]
         else (Ranks (S, N - 1) with delta S.Items (N).Id => N))
        with Global => null, Pre => Within (S, S.Capacity) and then N <= S.Capacity,
        Post => Ranks'Result'First = 1 and then Ranks'Result'Length = S.Capacity,
        Subprogram_Variant => (Decreases => N),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Selection (C : Configuration; P : Particle_Array) return Rank_Array is
        (declare S : constant State := Filtered (Contacts (C, P, P'Length));
         begin Ranks (S, S.Kept))
        with Global => null, Pre => P'First = 1 and then P'Length > 0,
        Post => Selection'Result'First = 1 and then Selection'Result'Length = P'Length,
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;
   procedure Collect (C : Configuration; P : Particle_Array; S : out State)
     with Global => null, Pre => P'First = 1 and then P'Length > 0 and then S.Capacity = P'Length,
     Post => (Static => S = Model.Contacts (C, P, P'Length));
   function Deepest (S : State) return Vertex with Global => null,
     Pre => S.Used > 0,
     Post => Deepest'Result <= S.Used;
   pragma Postcondition (Static => Deepest'Result = Model.Deepest (S, S.Used));
   procedure Scan (S : in out State; Next : out Count) with Global => null,
     Pre => S.Best in 1 .. S.Used,
     Post => (Static => S.Items = S'Old.Items and then S.Used = S'Old.Used
       and then S.Best = S'Old.Best and then S.Kept = S'Old.Kept
       and then S.Marked = (S'Old.Marked with delta S.Best => True)
       and then Next <= S.Used);
   pragma Postcondition (Static => Next = Model.Next_Best (S'Old, S.Used));
   pragma Postcondition (Static => (for all I in 1 .. S.Capacity => S.Minima (I) = Updated (S'Old, I)));
   procedure Advance (S : in out State) with Global => null,
     Pre => S.Used > Max_Contacts and then S.Best <= S.Used and then S.Kept < Max_Contacts,
     Post => (Static => S = Model.Transition (S'Old));
   pragma Postcondition (Static => (for all L in Vertex =>
     (if Within (S'Old, L) then Within (S, L))));
   procedure Reduce (S : in out State) with Global => null,
     Pre => S.Kept = 0,
     Post => (Static => S = Model.Filtered (S'Old));
   pragma Postcondition (Static => (for all L in Vertex =>
     (if Within (S'Old, L) then Within (S, L))));
   procedure Select_Contacts (C : Configuration; P : Particle_Array; R : out Rank_Array)
     with Global => null, Pre => P'First = 1 and then P'Length > 0
       and then R'First = 1 and then R'Length = P'Length,
     Post => (Static => R = Model.Selection (C, P));
end MJ.Flex_Contact_Filter;
