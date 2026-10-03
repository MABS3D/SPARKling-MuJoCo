with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Models;
package MJ.API.Names with SPARK_Mode is
   use type Interfaces.Unsigned_64;
   function Hash_Step (H : Interfaces.Unsigned_64; C : Character) return Interfaces.Unsigned_64 is
     ((Interfaces.Shift_Left (H, 5) + H) xor
       (if Character'Pos (C) < 128 then Interfaces.Unsigned_64 (Character'Pos (C))
        else Interfaces.Unsigned_64'Last - Interfaces.Unsigned_64 (255 - Character'Pos (C))))
     with Global => null;
   function Hash (Name : String) return Interfaces.Unsigned_64 with Global => null;
   function Object_Count (S : MJ.Models.Sizes; Kind : Obj_Kind) return Natural with Global => null;
   function Name2id (M : MJ.Models.Model; Kind : Obj_Kind; Name : String) return Integer with
     Global => null, Post => Name2id'Result >= -1;
   --  C NULL is represented by the empty Ada string. Returned values own
   --  their storage; no borrowed pointer survives Model.Free.
   function Id2name (M : MJ.Models.Model; Kind : Obj_Kind; Id : Integer) return String with Global => null;
end MJ.API.Names;
