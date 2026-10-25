with MJ.Types; use MJ.Types;
with MJ.Models;
with MJ.Models.Validity;
with MJ.Native_Mass_Patterns;

-- Complete owned model copy, independent of the simulation state package.
package MJ.Native_Mass_Models with SPARK_Mode is
   package NP renames MJ.Native_Mass_Patterns;
   type Capture_Status is (Success, Invalid_Model, Capacity_Exceeded);
   function Consistent (P : NP.Pattern) return Boolean is
     (P.Nv = 0 or else (NP.Valid (P) and then P.Shared = NP.Has_Sharing (P.Rows, P.Nv)))
     with Global => null;
   function Matches_Model (P : NP.Pattern; M : MJ.Models.Model) return Boolean
     with Ghost => Static, Global => null;
   procedure Capture (M : MJ.Models.Model; P : out NP.Pattern; Result : out Capture_Status)
     with Global => null, Post => Consistent (P);
   pragma Postcondition (Static =>
     Result = (if not MJ.Models.Valid_Layout (M) then Invalid_Model
       elsif not MJ.Models.Validity.Is_Valid (M) then Invalid_Model
       elsif M.S.Nv not in 1 .. NP.Max_Dofs or else M.S.Nc > NP.Max_Entries then Capacity_Exceeded
       else Success)
     and then (if Result = Success then Matches_Model (P, M)));
   procedure Capture_Validated (M : MJ.Models.Model; P : out NP.Pattern; Result : out Capture_Status)
     with Global => null,
       Pre => MJ.Models.Valid_Layout (M) and then MJ.Models.Validity.Is_Valid (M),
       Post => Consistent (P);
   pragma Postcondition (Static =>
     Result = (if M.S.Nv not in 1 .. NP.Max_Dofs or else M.S.Nc > NP.Max_Entries then Capacity_Exceeded else Success)
     and then (if Result = Success then Matches_Model (P, M)));
private
   function Source_Layout (M : MJ.Models.Model) return Boolean is
     (M.Sparse.M_Rownnz /= null and then M.Sparse.M_Rowadr /= null
      and then M.Sparse.M_Colind /= null and then M.Dofs.Dof_Simplenum /= null
      and then M.Dofs.Dof_M0 /= null and then M.Dofs.Dof_Armature /= null
      and then NP.Input_Layout (M.Sparse.M_Rownnz.all, M.Sparse.M_Rowadr.all,
        M.Sparse.M_Colind.all, M.Dofs.Dof_Simplenum.all, M.Dofs.Dof_M0.all,
        M.Dofs.Dof_Armature.all, M.S.Nv, M.S.Nc)) with Ghost => Static, Global => null;
   function Source_Ready (M : MJ.Models.Model) return Boolean is
     (Source_Layout (M) and then NP.Input_Valid
       (M.Sparse.M_Rownnz.all, M.Sparse.M_Rowadr.all, M.Sparse.M_Colind.all,
        M.Dofs.Dof_Simplenum.all, M.Dofs.Dof_M0.all, M.Dofs.Dof_Armature.all, M.S.Nv, M.S.Nc))
     with Ghost => Static, Global => null;
   function Matches_Model (P : NP.Pattern; M : MJ.Models.Model) return Boolean is
     (Source_Ready (M) and then NP.Valid (P)
      and then NP.Matches (P, M.Sparse.M_Rownnz.all, M.Sparse.M_Rowadr.all,
        M.Sparse.M_Colind.all, M.Dofs.Dof_Simplenum.all, M.Dofs.Dof_M0.all,
        M.Dofs.Dof_Armature.all, M.S.Nv, M.S.Nc)
      and then P.Shared = NP.Sharing_Model (P.Rows, M.S.Nv));
end MJ.Native_Mass_Models;
