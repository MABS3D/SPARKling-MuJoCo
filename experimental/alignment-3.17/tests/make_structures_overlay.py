"""Regenerate only the structures overlay after the separate root validation overlay.
This is source preparation: it never compiles or proves anything.
"""
from pathlib import Path
import difflib
import hashlib
import json
import subprocess
import tempfile
ROOT = Path(__file__).resolve().parents[3]
CANDIDATE = ROOT / "experimental/alignment-3.17"
CLAUSES = r'''
   --  Per-row C CSR domain: padding, gaps and unused storage are admissible.
   --  The older M/B/D compact CSR clauses above remain a separate policy.
   function Sparse_Flexedge_J_OK (M : Model) return Boolean is
     (Structure.Matrix_Valid (M.Flexes.Flexedge_J_Rownnz.all, M.Flexes.Flexedge_J_Rowadr.all,
       M.Flexes.Flexedge_J_Colind.all, M.S.Nflexedge, M.S.Nv, M.S.NJfe))
     with Pre => Valid_Layout (M);
   function Sparse_Flexvert_J_OK (M : Model) return Boolean is
     (Structure.Matrix_Valid (M.Flexes.Flexvert_J_Rownnz.all, M.Flexes.Flexvert_J_Rowadr.all,
       M.Flexes.Flexvert_J_Colind.all, 2*M.S.Nflexvert, M.S.Nv, 2*M.S.NJfv))
     with Pre => Valid_Layout (M);
   function Sparse_Efm0_L_OK (M : Model) return Boolean is
     (Structure.Matrix_Valid (M.Flexes.Efm0_L_Rownnz.all, M.Flexes.Efm0_L_Rowadr.all,
       M.Flexes.Efm0_L_Colind.all, M.S.Nefm0dof, M.S.Nefm0dof, M.S.Nefm0L))
     with Pre => Valid_Layout (M);
   function Efm0_Dofs_OK (M : Model) return Boolean is
     (for all K in 0 .. M.S.Nefm0dof-1 => M.Flexes.Efm0_Dofid (K) in 0 .. M.S.Nv-1)
     with Pre => Valid_Layout (M);
   function Flex_Structures_OK (M : Model) return Boolean is
     (Sparse_Flexedge_J_OK (M) and then Sparse_Flexvert_J_OK (M)
      and then Sparse_Efm0_L_OK (M) and then Efm0_Dofs_OK (M))
     with Pre => Valid_Layout (M);
   function B_Inputs_OK (M : Model) return Boolean is
     (Structure.Body_Links (M.Bodies.Body_Parentid.all, M.Bodies.Body_Weldid.all,
       M.Bodies.Body_Dofnum.all, M.S.Nv)) with Pre => Valid_Layout (M);
   function B_Root_OK (M : Model) return Boolean is
     (M.Sparse.B_Rownnz (0) = M.S.Nv and then (M.S.Nv = 0 or else M.Sparse.B_Rowadr (0) = 0))
     with Pre => Valid_Layout (M) and then M.S.Nbody >= 1;
   function B_Parent_Subset_At (M : Model; B : Integer) return Boolean is
     (declare P : constant Integer := M.Bodies.Body_Parentid (B); begin
       Structure.Row_Valid (M.Sparse.B_Colind.all, M.Sparse.B_Rowadr (B), M.Sparse.B_Rownnz (B), M.S.Nv)
       and then Structure.Row_Valid (M.Sparse.B_Colind.all, M.Sparse.B_Rowadr (P), M.Sparse.B_Rownnz (P), M.S.Nv)
       and then Structure.Sorted_Subset (M.Sparse.B_Colind.all, M.Sparse.B_Rowadr (B), M.Sparse.B_Rownnz (B),
         M.Sparse.B_Rowadr (P), M.Sparse.B_Rownnz (P), M.S.Nv))
     with Pre => Valid_Layout (M) and then B_Inputs_OK (M) and then Sparse_B_OK (M)
       and then B in 1 .. M.S.Nbody-1;
   function B_Ancestor_At (M : Model; B : Integer) return Boolean is
     (declare P : constant Integer := M.Bodies.Body_Parentid (B);
       Count : constant Int64 := Structure.Ancestor_Count (M.Bodies.Body_Parentid.all,
         M.Bodies.Body_Weldid.all, M.Bodies.Body_Dofnum.all, M.S.Nv, M.Bodies.Body_Weldid (P)); begin
       Count <= Int64 (M.Sparse.B_Rownnz (B)) and then Count <= Int64 (M.Sparse.B_Rownnz (P)))
     with Pre => Valid_Layout (M) and then B_Inputs_OK (M) and then Sparse_B_OK (M)
       and then B in 1 .. M.S.Nbody-1;
   function B_Structure_OK (M : Model) return Boolean is
     (B_Inputs_OK (M) and then B_Root_OK (M)
      and then (for all B in 1 .. M.S.Nbody-1 => B_Parent_Subset_At (M, B) and then B_Ancestor_At (M, B)))
     with Pre => Valid_Layout (M) and then M.S.Nbody >= 1 and then Sparse_B_OK (M);
   function D_B_Row_At (M : Model; D : Integer) return Boolean is
     (M.Dofs.Dof_Bodyid (D) in 0 .. M.S.Nbody-1 and then
       (declare B : constant Integer := M.Dofs.Dof_Bodyid (D); begin
         Structure.Span (M.Sparse.D_Colind.all, M.Sparse.D_Rowadr (D), M.Sparse.D_Rownnz (D))
         and then Structure.Span (M.Sparse.B_Colind.all, M.Sparse.B_Rowadr (B), M.Sparse.B_Rownnz (B))
         and then Structure.Rows_Equal (M.Sparse.D_Colind.all, M.Sparse.D_Rowadr (D), M.Sparse.D_Rownnz (D),
           M.Sparse.B_Colind.all, M.Sparse.B_Rowadr (B), M.Sparse.B_Rownnz (B))))
     with Pre => Valid_Layout (M) and then Sparse_B_OK (M) and then Sparse_D_OK (M) and then D in 0 .. M.S.Nv-1;
   function D_B_Rows_OK (M : Model) return Boolean is
     (for all D in 0 .. M.S.Nv-1 => D_B_Row_At (M, D))
     with Pre => Valid_Layout (M) and then Sparse_B_OK (M) and then Sparse_D_OK (M);
'''

def replace_once(text, before, after):
    assert text.count(before) == 1, before[:140]
    return text.replace(before, after)

def main():
    originals = {name: (ROOT/name).read_text() for name in ("src/mj-models-validity.ads", "src/mj-validation.adb")}
    overlay = CANDIDATE/"overlays/validation.patch"
    with tempfile.TemporaryDirectory(prefix="sparkling-structures-overlay-") as temporary:
        folder = Path(temporary)
        for name, data in originals.items():
            p=folder/name; p.parent.mkdir(parents=True,exist_ok=True);p.write_text(data)
        subprocess.run(["patch","--batch","--fuzz=0","-p1","-i",str(overlay)],cwd=folder,check=True,capture_output=True)
        base={name:(folder/name).read_text() for name in originals}
    modified=dict(base)
    name="src/mj-models-validity.ads";s=modified[name]
    s=replace_once(s,"with Interfaces;            use type Interfaces.Unsigned_8;", "with MJ.Model_Structures;\nwith Interfaces;            use type Interfaces.Unsigned_8;")
    s=replace_once(s,"package MJ.Models.Validity with SPARK_Mode is", "package MJ.Models.Validity with SPARK_Mode is\n   package Structure renames MJ.Model_Structures;")
    anchor="   function D_Diag_At (M : Model; I : Integer) return Boolean is"
    s=replace_once(s,anchor,CLAUSES+"\n"+anchor)
    s=replace_once(s,"(M.Sparse.D_Diag (I) in 0 .. M.Sparse.D_Rownnz (I) - 1", "(M.Sparse.D_Diag (I) = Row_Len (M, I)-1\n      and then M.Sparse.D_Diag (I) in 0 .. M.Sparse.D_Rownnz (I) - 1")
    s=replace_once(s,"with Pre => Valid_Layout (M) and then Sparse_D_OK (M) and then I in 0 .. M.S.Nv - 1;", "with Pre => Valid_Layout (M) and then Sparse_D_OK (M) and then Madr_Range_OK (M) and then I in 0 .. M.S.Nv - 1;")
    s=replace_once(s,"with Pre => Valid_Layout (M) and then Sparse_D_OK (M);", "with Pre => Valid_Layout (M) and then Sparse_D_OK (M) and then Madr_Range_OK (M);")
    s=replace_once(s,"and then D_Diags_OK (M) and then Maps_OK (M)\n", "and then D_Diags_OK (M) and then Maps_OK (M)\n      and then Flex_Structures_OK (M) and then B_Structure_OK (M) and then D_B_Rows_OK (M)\n")
    s=replace_once(s,"and then (if M.Meshes.Mesh_Normalnum (I) > 0 then\n                       M.Meshes.Mesh_Facenormal (3 * F + K) in 0 .. M.Meshes.Mesh_Normalnum (I) - 1)", "and then M.Meshes.Mesh_Facenormal (3 * F + K) in 0 .. M.Meshes.Mesh_Normalnum (I) - 1")
    s=replace_once(s,"M.Meshes.Mesh_Texcoordadr (I) >= 0 and then M.Meshes.Mesh_Texcoordnum (I) > 0", "M.Meshes.Mesh_Texcoordadr (I) >= 0")
    modified[name]=s
    name="src/mj-validation.adb";s=modified[name]
    s=replace_once(s,"with Interfaces;            use type Interfaces.Unsigned_8;", "with MJ.Model_Admission;\nwith Interfaces;            use type Interfaces.Unsigned_8;")
    s=replace_once(s,"and then D_Diags_OK (M) and then Maps_OK (M))", "and then D_Diags_OK (M) and then Maps_OK (M)\n                and then Flex_Structures_OK (M) and then B_Structure_OK (M) and then D_B_Rows_OK (M))")
    s=replace_once(s,"      Result := OK_Result;\n   end Diagnose_Sparse;", "      MJ.Model_Admission.Check_Flex (M, Result);\n      if Result.Status /= OK then return; end if;\n      MJ.Model_Admission.Check_Bodies (M, Result);\n      if Result.Status /= OK then return; end if;\n      MJ.Model_Admission.Check_Dofs (M, Result);\n   end Diagnose_Sparse;")
    # Body checks require one body, a fact established by Sizes_OK before this procedure.
    s=replace_once(s,"Pre  => Valid_Layout (M) and then Madr_Range_OK (M) and then Dof_Parent_Ranges_OK (M) and then Madrs_OK (M),", "Pre  => Valid_Layout (M) and then M.S.Nbody >= 1 and then Madr_Range_OK (M) and then Dof_Parent_Ranges_OK (M) and then Madrs_OK (M),")
    modified[name]=s
    chunks=[]
    for name in base:
        chunks.extend(difflib.unified_diff(base[name].splitlines(True),modified[name].splitlines(True),fromfile="a/"+name,tofile="b/"+name))
    for p in sorted((CANDIDATE/"src").glob("*.ad?")):
        name="src/"+p.name
        chunks.extend(difflib.unified_diff([],p.read_text().splitlines(True),fromfile="/dev/null",tofile="b/"+name))
    destination=CANDIDATE/"overlays/validation-structures.patch"
    destination.write_text("".join(chunks))
    receipt=dict(base_overlay_sha256=hashlib.sha256(overlay.read_bytes()).hexdigest(),patch_sha256=hashlib.sha256(destination.read_bytes()).hexdigest(),helpers={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((CANDIDATE/"src").glob("*.ad?"))},compiled=False,proved=False)
    (CANDIDATE/"overlays/validation-structures-source.json").write_text(json.dumps(receipt,indent=2)+"\n")
    print(json.dumps(receipt,indent=2))

if __name__=="__main__": main()
