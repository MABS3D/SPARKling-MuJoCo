private package MJ.Data.Advanced_Control.Computation with SPARK_Mode is
   procedure Compute (D : Simulation; E : in out Controller; Result : out Status)
     with Global => null, Post => (Static => E.No = E.No'Old and then E.Na = E.Na'Old
       and then E.Nv = E.Nv'Old and then E.Nu = E.Nu'Old
       and then E.Initialized = E.Initialized'Old
       and then E.Control = E.Control'Old and then E.Act = E.Act'Old);
end MJ.Data.Advanced_Control.Computation;
