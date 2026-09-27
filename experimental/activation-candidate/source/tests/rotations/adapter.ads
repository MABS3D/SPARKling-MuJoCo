with Interfaces.C;
with System;
package Adapter is
   procedure Evaluate (A, B, V, R : System.Address) with
     Export, Convention => C, External_Name => "rotation_evaluate";
   function Run (Op, Reps : Interfaces.C.int; A, B, V, R : System.Address)
     return Interfaces.C.double with Export, Convention => C,
     External_Name => "rotation_run", No_Inline;
end Adapter;
