with MJ.Types; use MJ.Types;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;

--  Standalone contact-free Cartesian flex-edge network. The rigid-body
--  MJ.Data loader still rejects flex; this API does not silently enable it.
package MJ.Elastic_Network with SPARK_Mode is
   Max_Count : constant := 4_096;
   subtype Count is Natural range 0 .. Max_Count;
   subtype Vertex is Positive range 1 .. Max_Count;
   type Particle_Array is array (Vertex range <>) of Particle;
   type Edge is record
      A, B : Vertex;
      Rest, Stiffness, Damping : Nonneg_Tier0;
   end record;
   type Edge_Array is array (Vertex range <>) of Edge;
   type Force_Array is array (Vertex range <>) of Edge_Force;
   type Input_Array is array (Vertex range <>) of Input_Vector;
   type Status is (Success, Numeric_Limit);
   function Valid (P : Particle_Array; E : Edge_Array) return Boolean is
     (P'First = 1 and then P'Length in 1 .. Max_Count
      and then E'First = 1 and then E'Length <= Max_Count
      and then (for all X of E => X.A in P'Range and then X.B in P'Range and then X.A /= X.B))
     with Global => null;
   function Budget (N : Count) return Real is
     (Real (3 * N + 2) * (2.0 ** 250)) with Ghost => Static, Global => null;
   procedure Bound_Add (A, B : Real; N : Count)
     with Ghost => Static, Global => null,
     Pre => N < Max_Count and then A in -(Real (3 * N + 2) * (2.0 ** 250)) .. (Real (3 * N + 2) * (2.0 ** 250))
       and then B in -1.0e74 .. 1.0e74,
     Post => A + B in -(Real (3 * N + 5) * (2.0 ** 250)) .. (Real (3 * N + 5) * (2.0 ** 250));
   function Load (P : Particle_Array; E : Edge) return Edge_Force
     with Ghost => Static, Global => null,
     Pre => E.A in P'Range and then E.B in P'Range,
     Post => Bounded (Load'Result.Spring, 1.0e74)
       and then Bounded (Load'Result.Damper, 1.0e74)
       and then Load'Result = Force (Measure (P (E.A), P (E.B)), E.Rest, E.Stiffness, E.Damping);
   function Component (P : Particle_Array; E : Edge; V : Vertex;
                       K : Axis; Damper : Boolean) return Real is
     (if P (V).Pinned or else (V /= E.A and then V /= E.B) then 0.0
      elsif V = E.A then
        (if Damper then -Load (P, E).Damper (K) else -Load (P, E).Spring (K))
      else (if Damper then Load (P, E).Damper (K) else Load (P, E).Spring (K)))
     with Ghost => Static, Global => null,
     Pre => E.A in P'Range and then E.B in P'Range and then V in P'Range,
     Post => Component'Result in -1.0e74 .. 1.0e74;
   function Model_Add (A, B : Real; N : Count) return Accumulated_Value
     with Ghost => Static, Global => null,
     Pre => N < Max_Count and then A in -Budget (N) .. Budget (N)
       and then B in -1.0e74 .. 1.0e74,
     Post => Model_Add'Result = A + B
       and then Model_Add'Result in -Budget (N + 1) .. Budget (N + 1);
   function Prefix (P : Particle_Array; E : Edge_Array; N : Count;
                    V : Vertex; K : Axis; Damper : Boolean) return Accumulated_Value is
     (if N = 0 then 0.0 else Model_Add (Prefix (P, E, N - 1, V, K, Damper),
        Component (P, E (N), V, K, Damper), N - 1))
     with Ghost => Static, Global => null,
     Pre => Valid (P, E) and then N <= E'Length and then V in P'Range,
     Subprogram_Variant => (Decreases => N),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body"),
     Post => Prefix'Result in -Budget (N) .. Budget (N)
       and then (if N = 0 then Prefix'Result = 0.0);
   procedure Forces (P : Particle_Array; E : Edge_Array; F : out Force_Array; Result : out Status)
     with Global => null,
     Pre => Valid (P, E) and then F'First = 1 and then F'Length = P'Length;
   pragma Postcondition (Static => (for all V in P'Range =>
     Bounded (F (V).Spring, 1.0e80) and then Bounded (F (V).Damper, 1.0e80)));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     F (V).Spring (0) = Prefix (P, E, E'Length, V, 0, False))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     F (V).Spring (1) = Prefix (P, E, E'Length, V, 1, False))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     F (V).Spring (2) = Prefix (P, E, E'Length, V, 2, False))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     F (V).Damper (0) = Prefix (P, E, E'Length, V, 0, True))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     F (V).Damper (1) = Prefix (P, E, E'Length, V, 1, True))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     F (V).Damper (2) = Prefix (P, E, E'Length, V, 2, True))));
   procedure Step (P : in out Particle_Array; E : Edge_Array;
                   Applied : Input_Array; Gravity : Input_Vector;
                   Dt : Time_Step; Result : out Status)
     with Global => null,
     Pre => Valid (P, E) and then Applied'First = 1 and then Applied'Length = P'Length;
   pragma Postcondition (Static => Valid (P, E));
   pragma Postcondition (Static => (if Result /= Success then P = P'Old));
   pragma Postcondition (Static => (for all V in P'Range =>
     P (V).Mass = P'Old (V).Mass and then P (V).Pinned = P'Old (V).Pinned
     and then (if P'Old (V).Pinned then P (V) = P'Old (V))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     (if not P'Old (V).Pinned then P (V).Velocity (0) = Advance_Velocity
       (P'Old (V).Velocity (0), P'Old (V).Mass,
        Prefix (P'Old, E, E'Length, V, 0, False), Prefix (P'Old, E, E'Length, V, 0, True),
        Applied (V) (0), Gravity (0), Dt)))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     P (V).Position (0) = (if P'Old (V).Pinned then P'Old (V).Position (0)
       else P'Old (V).Position (0) + Dt * P (V).Velocity (0)))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     (if not P'Old (V).Pinned then P (V).Velocity (1) = Advance_Velocity
       (P'Old (V).Velocity (1), P'Old (V).Mass,
        Prefix (P'Old, E, E'Length, V, 1, False), Prefix (P'Old, E, E'Length, V, 1, True),
        Applied (V) (1), Gravity (1), Dt)))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     P (V).Position (1) = (if P'Old (V).Pinned then P'Old (V).Position (1)
       else P'Old (V).Position (1) + Dt * P (V).Velocity (1)))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     (if not P'Old (V).Pinned then P (V).Velocity (2) = Advance_Velocity
       (P'Old (V).Velocity (2), P'Old (V).Mass,
        Prefix (P'Old, E, E'Length, V, 2, False), Prefix (P'Old, E, E'Length, V, 2, True),
        Applied (V) (2), Gravity (2), Dt)))));
   pragma Postcondition (Static => (if Result = Success then (for all V in P'Range =>
     P (V).Position (2) = (if P'Old (V).Pinned then P'Old (V).Position (2)
       else P'Old (V).Position (2) + Dt * P (V).Velocity (2)))));
end MJ.Elastic_Network;
