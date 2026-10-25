with MJ.Spatial_Kernels;
-- Shared CRB composite pass: descending body order, rounded parent additions,
-- world-parent skip. Bounds and the exact ordered model are proof properties.
private package MJ.Data.Composite_Assembly with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   package SK renames MJ.Spatial_Kernels;
   type Composite_Array is array (Natural range <>) of SK.Inertia;
   type Composite_State (Last : Natural) is record
      Values : Composite_Array (0 .. Last);
      Ok : Boolean;
   end record with Ghost => Static;
   function Composite_Layout (Bodies : Body_Parameter_Array; Values : Composite_Array) return Boolean is
     (Bodies'First = 0 and then Bodies'Length in 1 .. Max_Bodies
       and then Values'First = 0 and then Values'Last = Bodies'Last
       and then (for all B in 1 .. Bodies'Last => Bodies (B).Parent < B));
   function Model_Step (Previous : Composite_State; B, P : Natural) return Composite_State is
     (if not Previous.Ok or else P = 0 then Previous
      elsif SK.Bounded (SK.Add (Previous.Values (P), Previous.Values (B)), 1.0e40)
      then (Previous with delta Values =>
        (Previous.Values with delta P => SK.Add (Previous.Values (P), Previous.Values (B))))
      else (Previous with delta Ok => False))
     with Ghost => Static, Global => null,
       Pre => B <= Previous.Last and then P < B
         and then (for all X of Previous.Values => SK.Bounded (X, 1.0e40)),
       Post => Model_Step'Result.Last = Previous.Last
         and then (for all X of Model_Step'Result.Values => SK.Bounded (X, 1.0e40));
   function Accumulation_Model
     (Bodies : Body_Parameter_Array; Initial : Composite_Array; Steps : Natural) return Composite_State is
     (if Steps = 0 then (Last => Initial'Last, Values => Initial, Ok => True)
      else Model_Step (Accumulation_Model (Bodies, Initial, Steps - 1),
        Initial'Last - Steps + 1, Bodies (Initial'Last - Steps + 1).Parent))
     with Ghost => Static, Global => null,
       Pre => Composite_Layout (Bodies, Initial) and then Steps <= Initial'Last
         and then (for all X of Initial => SK.Bounded (X, 1.0e40)),
       Post => Accumulation_Model'Result.Last = Initial'Last
         and then (for all X of Accumulation_Model'Result.Values => SK.Bounded (X, 1.0e40)),
       Subprogram_Variant => (Decreases => Steps);

   procedure Accumulate_Composite (Bodies : Body_Parameter_Array; Composite : in out Composite_Array)
     with Global => null,
       Pre => Composite_Layout (Bodies, Composite)
         and then (for all X of Composite => SK.Bounded (X, 1.0e36)),
       Post => (Static => (for all X of Composite => SK.Bounded (X, 1.0e40))
         and then Accumulation_Model (Bodies, Composite'Old, Composite'Last).Ok
         and then Composite = Accumulation_Model (Bodies, Composite'Old, Composite'Last).Values);
   pragma Inline_Always (Accumulate_Composite);

   procedure Load_Composite (Source : Real_Array; Composite : out Composite_Array)
     with Global => null, Relaxed_Initialization => Composite,
       Pre => Composite'First = 0 and then Composite'Length in 1 .. Max_Bodies
         and then Source'First = 0 and then Source'Last = 10 * Composite'Length - 1
         and then (for all X of Source => X in -1.0e36 .. 1.0e36),
       Post => Composite'Initialized and then (for all X of Composite => SK.Bounded (X, 1.0e36))
         and then (for all B in Composite'Range =>
           (for all K in SK.Inertia'Range => Composite (B) (K) = Source (10 * B + K)));
   pragma Inline_Always (Load_Composite);
end MJ.Data.Composite_Assembly;
