pragma SPARK_Mode (On);
with MJ.Activation;
with MJ.Constraint_Solvers;
with MJ.Step_Publication;

--  The exact production instantiation, shared by the engine and proof gate.
package MJ.Owned_Step_Publication is new MJ.Step_Publication
  (MJ.Activation.Value_Array, MJ.Constraint_Solvers.Status,
   MJ.Constraint_Solvers.Converged, MJ.Constraint_Solvers.Iteration_Limit,
   MJ.Constraint_Solvers.Stalled, MJ.Constraint_Solvers.Line_Search_Limit);
