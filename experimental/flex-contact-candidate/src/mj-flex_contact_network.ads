with MJ.Elastic_Network; use MJ.Elastic_Network;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;
with MJ.Flex_Contact_Kernels; use MJ.Flex_Contact_Kernels;

with MJ.Flex_Contact_Filter;

package MJ.Flex_Contact_Network with SPARK_Mode is
   --  Plane-flex pairs use the pinned C filter, retaining up to 50 contacts.
   Max_Contacts : constant := MJ.Flex_Contact_Filter.Max_Contacts;
   type Status is (Success, Numeric_Limit);
   type Evaluation_Array is array (Vertex range <>) of Evaluation;
   function Model_Force (P : Particle_Array; E : Edge_Array; V : Vertex) return Edge_Force is
     ((Spring => [Prefix (P, E, E'Length, V, 0, False),
                  Prefix (P, E, E'Length, V, 1, False), Prefix (P, E, E'Length, V, 2, False)],
       Damper => [Prefix (P, E, E'Length, V, 0, True),
                  Prefix (P, E, E'Length, V, 1, True), Prefix (P, E, E'Length, V, 2, True)]))
     with Ghost => Static, Global => null, Pre => Valid (P, E) and then V in P'Range,
     Post => Bounded (Model_Force'Result.Spring, 1.0e80)
       and then Bounded (Model_Force'Result.Damper, 1.0e80);
   procedure Evaluate (C : Configuration; P : Particle_Array; E : Edge_Array;
     Applied : Input_Array; Gravity : Input_Vector; H : Time_Step;
     Info : out Evaluation_Array; Result : out Status)
     with Global => null,
     Pre => Valid (C) and then Valid (P, E)
       and then Applied'First = 1 and then Applied'Length = P'Length
       and then Info'First = 1 and then Info'Length = P'Length,
     Post => (Static => (if Result = Success then (for all V in P'Range =>
       Info (V).Accepted
       and then Info (V).Retained_Rank = MJ.Flex_Contact_Filter.Model.Selection (C, P) (V)
       and then Matches (C, P (V), Model_Force (P, E, V),
         Applied (V), Gravity, H, Info (V).Retained_Rank, Info (V)))));
   --  Info describes the pre-step contacts and accelerations. On failure the
   --  state is unchanged; Info is initialized but may be only partly computed.
   procedure Step (C : Configuration; P : in out Particle_Array; E : Edge_Array;
     Applied : Input_Array; Gravity : Input_Vector; H : Time_Step;
     Info : out Evaluation_Array; Result : out Status)
     with Global => null,
     Pre => Valid (C) and then Valid (P, E)
       and then Applied'First = 1 and then Applied'Length = P'Length
       and then Info'First = 1 and then Info'Length = P'Length;
   pragma Postcondition (Static => Valid (P, E));
   pragma Postcondition (Static => (if Result /= Success then P = P'Old));
   pragma Postcondition (Static => (for all V in P'Range =>
     P (V).Mass = P'Old (V).Mass and then P (V).Pinned = P'Old (V).Pinned
     and then (if P'Old (V).Pinned then P (V) = P'Old (V))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     Info (V).Accepted
     and then Info (V).Retained_Rank = MJ.Flex_Contact_Filter.Model.Selection (C, P'Old) (V)
     and then Matches (C, P'Old (V), Model_Force (P'Old, E, V),
       Applied (V), Gravity, H, Info (V).Retained_Rank, Info (V)))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     (if not P'Old (V).Pinned then (for all K in Axis =>
       P (V).Velocity (K) = Velocity_After (P'Old (V).Velocity (K), Info (V).Acceleration (K), H)
       and then P (V).Position (K) = P'Old (V).Position (K) + H * P (V).Velocity (K))))));
end MJ.Flex_Contact_Network;
