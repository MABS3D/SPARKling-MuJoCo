with Interfaces.C; with System;
package Bench_Ada is
   function Run (Op, NR, NC, NK, Reps, Pattern : Interfaces.C.int;
                 A, B, U, V, D, R, Ind : System.Address) return Interfaces.C.double
     with Export, Convention => C, External_Name => "bench_ada_run";
   pragma No_Inline (Run);
end Bench_Ada;
