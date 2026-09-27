package body MJ.Data.Topology_Checks is
   package T renames MJ.Smooth_Topology;
   package AR renames MJ.Ancestor_Rows;
   procedure Require (Condition : Boolean; Context : String) is
   begin
      if not Condition then raise Program_Error with Context; end if;
   end Require;
   procedure Check (M : MJ.Models.Model; D : Simulation; Expect_All_Simple : Boolean) is
      Parent, Last : Integer;
   begin
      Require (T.Body_Count (D.Topology) = D.Nb and then T.Dof_Count (D.Topology) = D.Nv, "cache sizes");
      for B in 0 .. D.Nb - 1 loop
         Require (T.Root (D.Topology, B) = M.Bodies.Body_Rootid (B), "body root");
         Parent := B;
         while Parent > 0 and then M.Bodies.Body_Dofnum (Parent) = 0 loop
            Parent := M.Bodies.Body_Parentid (Parent);
         end loop;
         Last := (if Parent = 0 then -1 else M.Bodies.Body_Dofadr (Parent) + M.Bodies.Body_Dofnum (Parent) - 1);
         Require (T.Last_Dof (D.Topology, B) = Last, "last DOF");
         if B > 0 then
            Require (abs (T.Subtree_Mass (D.Topology, B) - M.Bodies.Body_Subtreemass (B))
              <= 2.0e-12 * (1.0 + M.Bodies.Body_Subtreemass (B)), "subtree mass versus C compiler");
         end if;
      end loop;
      for V in 0 .. D.Nv - 1 loop
         Require (T.Parent_Dof (D.Topology, V) = M.Dofs.Dof_Parentid (V), "true parent DOF");
         Require (T.Dof_Body (D.Topology, V) = M.Dofs.Dof_Bodyid (V), "DOF body");
         Require (T.Dof_Joint (D.Topology, V) = M.Dofs.Dof_Jntid (V), "DOF joint");
         Require (T.Armature (D.Topology, V) = M.Dofs.Dof_Armature (V), "armature");
         if Expect_All_Simple then
            Require (T.Simple_Count (D.Topology, V) = D.Nv - V, "simple run");
            Require (T.Simple_Count (D.Topology, V) = M.Dofs.Dof_Simplenum (V), "simple run versus C compiler");
            Require (AR.Length (D.Ancestors, V) = 1 and then AR.Parent (D.Ancestors, V) = -1, "simple diagonal-only row");
            Require (abs (T.Fixed_Inertia (D.Topology, V) - M.Dofs.Dof_M0 (V))
              <= 2.0e-12 * (1.0 + M.Dofs.Dof_M0 (V)), "fixed inertia versus C compiler");
         end if;
      end loop;
   end Check;
   procedure General_Only (D : Simulation) is
   begin
      for V in 0 .. D.Nv - 1 loop
         Require (T.Simple_Count (D.Topology, V) = 0, "unvalidated simple flag accepted");
         Require (AR.Parent (D.Ancestors, V) = T.Parent_Dof (D.Topology, V), "general ancestry pruned");
      end loop;
   end General_Only;
   procedure Same (A, B : Simulation) is
   begin
      Require (A.Nb = B.Nb and then A.Nv = B.Nv, "same dimensions");
      for I in 0 .. A.Nb - 1 loop
         Require (T.Root (A.Topology, I) = T.Root (B.Topology, I), "owned root changed");
         Require (T.Last_Dof (A.Topology, I) = T.Last_Dof (B.Topology, I), "owned last DOF changed");
         Require (T.Subtree_Mass (A.Topology, I) = T.Subtree_Mass (B.Topology, I), "owned subtree mass changed");
      end loop;
      for V in 0 .. A.Nv - 1 loop
         Require (T.Simple_Count (A.Topology, V) = T.Simple_Count (B.Topology, V), "stale M0 changed simple eligibility");
         Require (T.Fixed_Inertia (A.Topology, V) = T.Fixed_Inertia (B.Topology, V), "stale M0 changed computed fixed inertia");
         Require (AR.Length (A.Ancestors, V) = AR.Length (B.Ancestors, V), "stale M0 changed sparsity");
      end loop;
   end Same;
end MJ.Data.Topology_Checks;
