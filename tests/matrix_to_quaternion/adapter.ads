with Interfaces.C;
with System;
package Adapter is
   procedure Evaluate (A, R : System.Address; Status : out Interfaces.C.int) with
     Export, Convention => C, External_Name => "matquat_evaluate";
   procedure Run (Reps : Interfaces.C.int; A, R : System.Address) with
     Export, Convention => C, External_Name => "matquat_run", No_Inline;
end Adapter;
