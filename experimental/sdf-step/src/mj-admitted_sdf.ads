with MJ.SDF_Collisions;
with MJ.SDF_Provider;
package MJ.Admitted_SDF is new MJ.SDF_Collisions
  (Custom_Query => MJ.SDF_Provider.Unavailable, Fields_Admitted => True);
