with Interfaces.C;
with System;
package Bench_Adapter is
   procedure Run (Input, Output : System.Address; Steps : Interfaces.C.int)
     with Export, Convention => C, External_Name => "contact_run";
end Bench_Adapter;
