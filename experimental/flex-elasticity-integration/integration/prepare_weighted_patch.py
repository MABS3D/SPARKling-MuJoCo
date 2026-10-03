"""Prepare, never apply, the scoped shared response extension for its owner."""
import difflib, hashlib, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
STEM = 'experimental/constrained-step/src/mj-data-constrained'
old = {ext: (ROOT / (STEM + ext)).read_text() for ext in ('.ads', '.adb')}
new = old.copy()

anchor = '   type Contact_Endpoint_Array is array (Natural range 0 .. Max_C - 1) of Contact_Endpoints;'
new['.ads'] = new['.ads'].replace(anchor, anchor + '''
   -- Ordered, positive C element weights, not exact real barycentric weights.
   -- Repeated bodies are retained: combining them changes rounded evaluation.
   type Weighted_Body is record
      Body_Id : Natural := 0;
      Weight : Real := 0.0;
   end record;
   type Weighted_Body_Array is array (Positive range 1 .. 4) of Weighted_Body;
   type Weighted_Side is record
      Count : Natural := 1;
      Items : Weighted_Body_Array := [1 => (0, 1.0), others => <>];
   end record;
   type Weighted_Contact is record
      Active : Boolean := False;
      Side0, Side1 : Weighted_Side;
   end record;
   type Weighted_Contact_Array is array (Natural range 0 .. Max_C - 1) of Weighted_Contact;''')
new['.ads'] = new['.ads'].replace('      Endpoints : Contact_Endpoint_Array;',
    '      Endpoints : Contact_Endpoint_Array;\n      Contact_Weights : Weighted_Contact_Array;')
anchor = '   procedure Set_Rigid_Contact_Endpoints (E : in out Engine; Result : out Status);'
new['.ads'] = new['.ads'].replace(anchor, '''   -- Validates both complete lists before publishing metadata. Geom sides
   -- require exactly one body of weight 1; flex element sides use Geom=-1.
   -- The singleton body ids are diagnostic representatives while Active.
   procedure Set_Weighted_Contact_Endpoints
     (E : in out Engine; Id : Natural; Side0, Side1 : Weighted_Side;
      Geom0, Geom1 : Integer; Result : out Status) with Global => null;
''' + anchor)
new['.adb'] = new['.adb'].replace('      E.Endpoints (Id) := (Body0, Body1, Geom0, Geom1);',
    '      E.Endpoints (Id) := (Body0, Body1, Geom0, Geom1);\n      E.Contact_Weights (Id).Active := False;')
anchor = '   procedure Set_Rigid_Contact_Endpoints (E : in out Engine; Result : out Status) is'
new['.adb'] = new['.adb'].replace(anchor, '''   procedure Set_Weighted_Contact_Endpoints
     (E : in out Engine; Id : Natural; Side0, Side1 : Weighted_Side;
      Geom0, Geom1 : Integer; Result : out Status) is
      function Valid_Side (Side : Weighted_Side; Geom : Integer) return Boolean is
      begin
         if Side.Count not in 1 .. 4 or else Geom not in -1 .. Max_G - 1
           or else Geom not in -1 .. Integer (E.Ng) - 1 then return False; end if;
         for K in 1 .. Side.Count loop
            if Side.Items (K).Body_Id >= E.D.Nb
              or else Side.Items (K).Body_Id not in E.Bodies'Range
              or else Side.Items (K).Weight not in 0.0 .. 2.0
              or else Side.Items (K).Weight = 0.0 then return False; end if;
         end loop;
         return Geom = -1 or else (Side.Count = 1 and then Side.Items (1).Weight = 1.0
           and then E.Geoms (Geom).Body_Id = Side.Items (1).Body_Id);
      end Valid_Side;
   begin
      Result := Invalid_Index;
      if Id >= E.T.Ncontact or else Id >= Max_C
        or else not Valid_Side (Side0, Geom0) or else not Valid_Side (Side1, Geom1) then return; end if;
      Set_Contact_Endpoints (E, Id, Side0.Items (1).Body_Id, Side1.Items (1).Body_Id,
        Geom0, Geom1, Result);
      if Result = Success then E.Contact_Weights (Id) := (True, Side0, Side1); end if;
   end Set_Weighted_Contact_Endpoints;

''' + anchor)
anchor = '   procedure Assemble (E : in out Engine; Result : out Status) is'
new['.adb'] = new['.adb'].replace(anchor, '''   -- Sparse mj_jacSum: preserve body order, retain common ancestors and
   -- duplicate bodies, then project the completed world Jacobian into frame.
   procedure Weighted_Contact_Jacobian
     (E : Engine; Id : Natural; Chain : out CA.Column_Array;
      J : out CA.Matrix; N : out Natural) is
      C : MJ.Full_Contacts.Full_Contact renames E.Contacts (Id);
      Seen : array (Natural range 0 .. Max_V - 1) of Boolean := [others => False];
      World : CA.Matrix (1 .. 6, 1 .. Max_V) := [others => [others => 0.0]];
      procedure Accumulate (Side : Weighted_Side; Sign : Real) is
      begin
         for K in 1 .. Side.Count loop
            declare
               Body_Id : constant Natural := Side.Items (K).Body_Id;
               Weight : constant Real := Sign * Side.Items (K).Weight;
               V : Integer := E.Bodies (Body_Id).Leaf;
               Offset : constant Vector := Vector (C.Position) - E.D.Kinematic.Bodies (Body_Id).Center;
            begin
               while V >= 0 loop
                  declare
                     O : constant Natural := Jacobian_Offset (E.D, Body_Id, V);
                     Angular : constant Vector := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O);
                     Linear : constant Vector := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O);
                     Point : Vector;
                  begin
                     for X in 0 .. 2 loop
                        Point (X) := CK.Point_Component (Linear (X), Angular ((X+1) mod 3),
                          Angular ((X+2) mod 3), Offset ((X+1) mod 3), Offset ((X+2) mod 3));
                        if Seen (V) then
                           World (X+1, V+1) := World (X+1, V+1) + Weight * Point (X);
                           World (X+4, V+1) := World (X+4, V+1) + Weight * Angular (X);
                        else
                           World (X+1, V+1) := Weight * Point (X);
                           World (X+4, V+1) := Weight * Angular (X);
                        end if;
                     end loop;
                     Seen (V) := True;
                  end;
                  V := E.Dofs (V).Parent;
               end loop;
            end;
         end loop;
      end Accumulate;
   begin
      Chain := [others => 0]; J := [others => [others => 0.0]]; N := 0;
      Accumulate (E.Contact_Weights (Id).Side0, -1.0);
      Accumulate (E.Contact_Weights (Id).Side1, 1.0);
      for V in 0 .. E.D.Nv - 1 loop
         if Seen (V) then
            N := N + 1; Chain (N) := V;
            for R in 1 .. C.Dim loop
               declare
                  X : constant Natural := (R - 1) mod 3;
                  Base : constant Natural := (if R <= 3 then 1 else 4);
               begin
                  J (R, N) := CK.Frame_Component (World (Base, V+1), World (Base+1, V+1),
                    World (Base+2, V+1), C.Frame (3*X), C.Frame (3*X+1), C.Frame (3*X+2));
               end;
            end loop;
         end if;
      end loop;
   end Weighted_Contact_Jacobian;

   function Contact_Inverse_Weight (E : Engine; Id : Natural; Rotational : Boolean) return Real is
      Sum : Real := 0.0;
      procedure Accumulate (Side : Weighted_Side) is
      begin
         for K in 1 .. Side.Count loop
            declare
               B : constant Natural := Side.Items (K).Body_Id;
               W : constant Real := (if Rotational then E.Bodies (B).Rotation else E.Bodies (B).Translation);
            begin Sum := Sum + W * Side.Items (K).Weight; end;
         end loop;
      end Accumulate;
   begin
      if E.Contact_Weights (Id).Active then
         Accumulate (E.Contact_Weights (Id).Side0);
         Accumulate (E.Contact_Weights (Id).Side1);
         return Sum;
      elsif Rotational then
         return E.Bodies (E.Endpoints (Id).Body0).Rotation + E.Bodies (E.Endpoints (Id).Body1).Rotation;
      else
         return E.Bodies (E.Endpoints (Id).Body0).Translation + E.Bodies (E.Endpoints (Id).Body1).Translation;
      end if;
   end Contact_Inverse_Weight;

''' + anchor)
anchor = '               --  Merge both parent chains until their common ancestor:'
new['.adb'] = new['.adb'].replace(anchor, '''               if E.Contact_Weights (Id).Active then
                  Weighted_Contact_Jacobian (E, Id, Chain, J, N);
               else
''' + anchor)
anchor = '''               declare
                  Width : constant Natural := N;'''
new['.adb'] = new['.adb'].replace(anchor, '''               end if;
''' + anchor)
anchor = '''                  B1 : constant Natural := E.Endpoints (Contact_Id).Body0;
                  B2 : constant Natural := E.Endpoints (Contact_Id).Body1;
                  Tran : constant Real := E.Bodies (B1).Translation + E.Bodies (B2).Translation;
                  Rot : constant Real := E.Bodies (B1).Rotation + E.Bodies (B2).Rotation;'''
assert anchor in new['.adb']
new['.adb'] = new['.adb'].replace(anchor, '''                  Tran : constant Real := Contact_Inverse_Weight (E, Contact_Id, False);
                  Rot : constant Real := Contact_Inverse_Weight (E, Contact_Id, True);''')
patch = ''.join(''.join(difflib.unified_diff(old[e].splitlines(True),new[e].splitlines(True),
            fromfile='a/'+STEM+e,tofile='b/'+STEM+e)) for e in ('.ads','.adb'))
(OUT/'constrained-weighted-endpoints.patch').write_text(patch)
(OUT/'constrained-weighted-endpoints.json').write_text(json.dumps(dict(
    baseline={STEM+e:hashlib.sha256(old[e].encode()).hexdigest() for e in old},
    proposed={STEM+e:hashlib.sha256(new[e].encode()).hexdigest() for e in new},
    status='Prepared, not applied or verified. Central owner adds atomic contracts and applies.'),indent=2)+'\n')
print('Prepared', len(patch.splitlines()), 'patch lines')
