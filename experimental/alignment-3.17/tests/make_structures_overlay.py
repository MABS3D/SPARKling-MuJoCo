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
   --  Native M/B/D/tendon and FLEX rows use this same per-row domain.
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
       Structure.Sorted_Subset (M.Sparse.B_Colind.all, M.Sparse.B_Rowadr (B), M.Sparse.B_Rownnz (B),
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
         Structure.Rows_Equal (M.Sparse.D_Colind.all, M.Sparse.D_Rowadr (D), M.Sparse.D_Rownnz (D),
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
    # Keep CSR_OK as the legacy compact utility; native admission follows C's
    # independent row spans, including shared spans and unused storage.
    for stem, group, nrows, nnz in [("M", "Sparse", "Nv", "Nc"),
                                  ("B", "Sparse", "Nbody", "Nb"),
                                  ("D", "Sparse", "Nv", "Nd"),
                                  ("Ten_J", "Tendons", "Ntendon", "Njten")]:
        suffix = ", Strict => False" if stem == "Ten_J" else ""
        before = ("(CSR_OK (M." + group + "." + stem + "_Rownnz.all, M." + group + "." + stem + "_Rowadr.all, M." + group + "." + stem + "_Colind.all,\n"
                  + "              M.S." + nrows + ", M.S." + nnz + ", M.S.Nv" + suffix + "))")
        after = ("(Structure.Matrix_Valid (M." + group + "." + stem + "_Rownnz.all, M." + group + "." + stem + "_Rowadr.all, M." + group + "." + stem + "_Colind.all,\n"
                 + "              M.S." + nrows + ", M.S.Nv, M.S." + nnz + suffix + "))")
        s = replace_once(s, before, after)
    anchor="   function D_Diag_At (M : Model; I : Integer) return Boolean is"
    s=replace_once(s,anchor,CLAUSES+"\n"+anchor)
    s=replace_once(s,"(M.Sparse.D_Diag (I) in 0 .. M.Sparse.D_Rownnz (I) - 1", "(M.Sparse.D_Diag (I) = Row_Len (M, I)-1\n      and then M.Sparse.D_Diag (I) in 0 .. M.Sparse.D_Rownnz (I) - 1")
    s=replace_once(s,"with Pre => Valid_Layout (M) and then Sparse_D_OK (M) and then I in 0 .. M.S.Nv - 1;", "with Pre => Valid_Layout (M) and then Sparse_D_OK (M) and then Madr_Range_OK (M) and then I in 0 .. M.S.Nv - 1;")
    s=replace_once(s,"with Pre => Valid_Layout (M) and then Sparse_D_OK (M);", "with Pre => Valid_Layout (M) and then Sparse_D_OK (M) and then Madr_Range_OK (M);")
    s=replace_once(s,"and then D_Diags_OK (M) and then Maps_OK (M)\n", "and then D_Diags_OK (M) and then Maps_OK (M)\n      and then Flex_Structures_OK (M) and then B_Structure_OK (M) and then D_B_Rows_OK (M)\n")
    s=replace_once(s,"and then (if M.Meshes.Mesh_Normalnum (I) > 0 then\n                       M.Meshes.Mesh_Facenormal (3 * F + K) in 0 .. M.Meshes.Mesh_Normalnum (I) - 1)", "and then M.Meshes.Mesh_Facenormal (3 * F + K) in 0 .. M.Meshes.Mesh_Normalnum (I) - 1")
    s=replace_once(s,"M.Meshes.Mesh_Texcoordadr (I) >= 0 and then M.Meshes.Mesh_Texcoordnum (I) > 0", "M.Meshes.Mesh_Texcoordadr (I) >= 0")
    mesh_start = s.index("   function Mesh_Faces_At (M : Model; I : Integer) return Boolean is")
    mesh_end = s.index("\n   --  Polygon vertex lists", mesh_start)
    mesh_core = s[mesh_start:mesh_end].replace("function Mesh_Faces_At", "function Mesh_Faces_Core")
    mesh_core = replace_once(mesh_core,
        "with Pre => Valid_Layout (M) and then I in 0 .. M.S.Nmesh - 1;",
        "with Pre => Sizes_In_Range (M.S) and then Mesh_Layout_OK (M.S, M.Meshes)\n       and then I in 0 .. M.S.Nmesh - 1;")
    mesh_public = """   procedure Reveal_Mesh_Layout (M : Model) with
     Ghost => Static, Global => null, Pre => Valid_Layout (M),
     Post => Sizes_In_Range (M.S) and then Mesh_Layout_OK (M.S, M.Meshes);
""" + mesh_core + """
   function Mesh_Faces_At (M : Model; I : Integer) return Boolean with
     Global => null, Pre => Valid_Layout (M) and then I in 0 .. M.S.Nmesh - 1,
     Post => Sizes_In_Range (M.S) and then Mesh_Layout_OK (M.S, M.Meshes)
       and then Mesh_Faces_At'Result = Mesh_Faces_Core (M, I);
"""
    s = s[:mesh_start] + mesh_public + s[mesh_end:]
    modified[name]=s
    name="src/mj-validation.adb";s=modified[name]
    s=replace_once(s,"with Interfaces;            use type Interfaces.Unsigned_8;", "with MJ.Model_Admission;\nwith Interfaces;            use type Interfaces.Unsigned_8;")
    s = replace_once(s, "      Adhesion := Has_Positive (M.Geoms.Geom_Adhesion.all)",
        "      MJ.Model_Admission.Reveal_Joint_Count_Layout (M.S, M.Joints);\n      Adhesion := Has_Positive (M.Geoms.Geom_Adhesion.all)")
    s=replace_once(s,"and then D_Diags_OK (M) and then Maps_OK (M))", "and then D_Diags_OK (M) and then Maps_OK (M)\n                and then Flex_Structures_OK (M) and then B_Structure_OK (M) and then D_B_Rows_OK (M))")
    s=replace_once(s,"      Result := OK_Result;\n   end Diagnose_Sparse;", "      MJ.Model_Admission.Check_Flex (M, Result);\n      if Result.Status /= OK then return; end if;\n      MJ.Model_Admission.Check_Bodies (M, Result);\n      if Result.Status /= OK then return; end if;\n      MJ.Model_Admission.Check_Dofs (M, Result);\n   end Diagnose_Sparse;")
    sparse_start = s.index("   procedure Diagnose_Sparse")
    for predicate, next_predicate, routine in [("Sparse_M_OK", "Sparse_B_OK", "Check_M_CSR"),
                                               ("Sparse_B_OK", "Sparse_D_OK", "Check_B_CSR"),
                                               ("Sparse_D_OK", "Sparse_Ten_J_OK", "Check_D_CSR"),
                                               ("Sparse_Ten_J_OK", "M_Rownnz_OK", "Check_Tendon_CSR")]:
        begin = s.index("      if not " + predicate + " (M) then", sparse_start)
        end = s.index("      if not " + next_predicate + " (M) then", begin)
        s = s[:begin] + "      if not " + predicate + " (M) then\n         MJ.Model_Admission." + routine + " (M, Result);\n         return;\n      end if;\n" + s[end:]
    maps_start = s.index("      if not Maps_OK (M) then", sparse_start)
    maps_end = s.index("      MJ.Model_Admission.Check_Flex", maps_start)
    s = s[:maps_start] + "      MJ.Model_Admission.Check_Maps (M, Result);\n      if Result.Status /= OK then return; end if;\n" + s[maps_end:]
    opaque_anchor = '      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Maps_OK);'
    opaque = "\n".join('      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", ' + name + ');'
                        for name in ["Flex_Structures_OK", "B_Structure_OK", "D_B_Rows_OK"])
    s = replace_once(s, opaque_anchor, opaque_anchor + "\n" + opaque)
    # Body checks require one body, a fact established by Sizes_OK before this procedure.
    s=replace_once(s,"Pre  => Valid_Layout (M) and then Madr_Range_OK (M) and then Dof_Parent_Ranges_OK (M) and then Madrs_OK (M),", "Pre  => Valid_Layout (M) and then M.S.Nbody >= 1 and then Madr_Range_OK (M) and then Dof_Parent_Ranges_OK (M) and then Madrs_OK (M),")
    s = replace_once(s,
        '      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mesh_Faces_At);',
        '      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mesh_Faces_Core);')
    valid_text = modified["src/mj-models-validity.ads"]
    conjunction = valid_text[valid_text.index("   function Is_Valid (M : Model)"):]
    conjunction = conjunction[:conjunction.index("   with Pre =>")]
    import re
    clause_names = list(dict.fromkeys(re.findall(r"\b([A-Za-z_][A-Za-z_0-9]*) \(M\)", conjunction)))
    clause_names = [value for value in clause_names if value != "Sizes_OK"]
    assert len(clause_names) > 50
    root_start = s.index("   procedure Diagnose (M : Model;")
    root_end = s.index("   procedure Validate (", root_start)
    root_body = s[root_start:root_end]
    root_anchor = '      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Valid);'
    root_hides = "\n".join('      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", ' + value + ');'
                           for value in clause_names)
    root_body = replace_once(root_body, root_anchor, root_anchor + "\n" + root_hides)
    s = s[:root_start] + root_body + s[root_end:]
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
