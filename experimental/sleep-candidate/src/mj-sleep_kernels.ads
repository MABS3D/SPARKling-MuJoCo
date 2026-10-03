--  Copyright 2025 DeepMind Technologies Limited.
--  Apache-2.0; see LICENSE. Modified: Ada/SPARK translation and contracts.
with MJ.Types; use MJ.Types;
package MJ.Sleep_Kernels with SPARK_Mode is
   subtype Counter is Integer range -(1 + Min_Awake) .. -1;
   Fully_Awake : constant Counter := -(1 + Min_Awake);
   type Object_State is (Static_Body, Asleep, Awake);
   for Object_State use (Static_Body => -1, Asleep => 0, Awake => 1);
   type Samples is array (Integer range <>) of Tier0_Real;
   type Weights is array (Integer range <>) of Nonneg_Tier0;
   function Small (X : Tier0_Real; W, Tol : Nonneg_Tier0) return Boolean is
     (W * abs X < Tol);
   function Under_Tolerance (X : Samples; W : Weights; Tol : Nonneg_Tier0)
     return Boolean with Global => null,
     Pre => X'First in 0 .. 4096 and then X'Last in -1 .. 4095 and then X'First = W'First and then X'Last = W'Last and then Tol > 0.0,
     Post => Under_Tolerance'Result =
       (for all I in X'Range => Small (X (I), W (I), Tol));
   function Advance (C : Counter; Eligible : Boolean) return Counter is
     (if not Eligible then Fully_Awake elsif C < -1 then C + 1 else -1) with
     Post => (if not Eligible then Advance'Result = Fully_Awake
              elsif C < -1 then Advance'Result = C + 1 else Advance'Result = -1);
   function Wake_Value (C, Requested : Counter) return Counter is
     (Integer'Min (C, Requested)) with
     Post => Wake_Value'Result <= C and then Wake_Value'Result <= Requested
       and then (Wake_Value'Result = C or Wake_Value'Result = Requested);
   function Tree_State (Value : Integer) return Object_State is
     (if Value < 0 then Awake else Asleep);
   function Body_State (Tree : Integer; Tree_Awake, Mocap, Static_Awake : Boolean)
     return Object_State is
     (if Tree >= 0 then (if Tree_Awake then Awake else Asleep)
      elsif Mocap or Static_Awake then Awake else Static_Body);
   function Neither_Awake (A, B : Object_State) return Object_State is
     (if A = Awake or B = Awake then Awake else Asleep);
   function Tendon_State (Count : Natural; A, B : Boolean) return Object_State is
     (if Count = 0 then Static_Body elsif Count = 1 then (if A then Awake else Asleep)
      elsif Count = 2 then (if A or B then Awake else Asleep) else Awake);
   function Sensor_State (A, B : Object_State; Unknown_A, Unknown_B, Always : Boolean)
     return Object_State is
     (if Always or (Unknown_A and Unknown_B) then Awake
      elsif Unknown_A then (if B = Asleep then Asleep else Awake)
      elsif Unknown_B then (if A = Asleep then Asleep else Awake)
      else Neither_Awake (A, B));
end MJ.Sleep_Kernels;
