with MJ.Types; use MJ.Types;

--  A generic boundary keeps the state-update proof independent of Model/Data
--  representation. The engine instantiates the real activation/status types.
generic
   type Activation_Array is array (Natural range <>) of Tier0_Real;
   type Solver_Status is (<>);
   Converged, Iteration_Limit, Stalled, Line_Search_Limit : Solver_Status;
package MJ.Step_Publication with SPARK_Mode is
   function Has_Iterate (Outcome : Solver_Status) return Boolean
     with Global => null;
   pragma Postcondition
     (Static => Has_Iterate'Result =
       (Outcome in Converged | Iteration_Limit | Stalled | Line_Search_Limit));
   pragma Inline_Always (Has_Iterate);

   --  Admit numerical values before this call. Matching array bounds make
   --  every assignment safe, so all owned state components publish together.
   procedure Publish
     (Qpos, Qvel : out Real_Array; Activation : out Activation_Array;
      Clock : out Nonneg_Tier0;
      Next_Qpos, Next_Qvel : Real_Array; Next_Activation : Activation_Array;
      Next_Time : Nonneg_Tier0)
     with Global => null,
       Pre => Qpos'First = Next_Qpos'First and then Qpos'Last = Next_Qpos'Last
         and then Qvel'First = Next_Qvel'First and then Qvel'Last = Next_Qvel'Last
         and then Activation'First = Next_Activation'First
         and then Activation'Last = Next_Activation'Last;
   pragma Postcondition
     (Static => Qpos = Next_Qpos and then Qvel = Next_Qvel
       and then Activation = Next_Activation and then Clock = Next_Time);
   pragma Inline_Always (Publish);
end MJ.Step_Publication;
