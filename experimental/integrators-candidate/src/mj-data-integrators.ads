with MJ.External_Forces;
package MJ.Data.Integrators with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   type Method is (Euler, RK4, Implicit_Velocity, Implicit_Fast, Discrete);
   type Selection is record
      Kind : Method := Euler;
      Use_Couplings : Boolean := True;
      Iterations : Natural := 100;
      Tolerance : Nonneg_Tier0 := 1.0e-8;
   end record;
   -- Exclusive initialization borrow; restores the source model on every exit.
   procedure Create (M : in out MJ.Models.Model; D : in out Simulation;
                     Selected : out Selection; Result : out Status;
                     Solver_Policy : Inertia_Policy := Compatible)
     with Global => null, Pre => Valid_State (D);
   -- Optional operators are row-major nv*nv. They are consumed for this call,
   -- never retained. Discrete_Addition is the complete effective-metric
   -- addition; Discrete_Shift is the corresponding smooth-force shift.
   -- An empty operator requests the native supported force producer.
   procedure Step (D : in out Simulation; Selected : Selection; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads;
      Velocity_Jacobian : Real_Array := [1 .. 0 => 0.0];
      Discrete_Addition : Real_Array := [1 .. 0 => 0.0];
      Discrete_Shift : Real_Array := [1 .. 0 => 0.0])
     with Global => null, Pre => Valid_State (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old
       and then Is_Ready (D) = Is_Ready (D)'Old
       and then Shape (D) = Shape (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then (if Result /= Success then
         Complete_State_Values (D) = Complete_State_Values (D)'Old)
       and then (if Result = Success then
         Time (D) = Time (D)'Old + Step_Size (D)'Old);
end MJ.Data.Integrators;
