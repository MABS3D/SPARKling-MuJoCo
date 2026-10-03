with Ada.Text_IO;

--  Diagnostic-only exporter: capture the actual assembled Ada problem for
--  replay by solvers_probe, without changing the engine's production trace.
package MJ.Data.Constrained.Test_Export with SPARK_Mode => Off is
   procedure Write_Problem (E : Engine; File : Ada.Text_IO.File_Type);
end MJ.Data.Constrained.Test_Export;
