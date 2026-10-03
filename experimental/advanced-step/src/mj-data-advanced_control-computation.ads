private package MJ.Data.Advanced_Control.Computation with SPARK_Mode is
   procedure Compute_Core (D : Simulation; E : Input_Storage; Work : in out Evaluation_Storage;
                           Result : out Status) with Global => null;
   procedure Compute (D : Simulation; E : in out Controller; Result : out Status)
     with Global => null, Post => (Static => E.Source.No = E.Source.No'Old and then E.Source.Na = E.Source.Na'Old
       and then E.Source.Nv = E.Source.Nv'Old and then E.Source.Nu = E.Source.Nu'Old
       and then E.Source.Initialized = E.Source.Initialized'Old
       and then E.Source.Control = E.Source.Control'Old and then E.Source.Act = E.Source.Act'Old);
end MJ.Data.Advanced_Control.Computation;
