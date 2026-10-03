package body MJ.API.Names with SPARK_Mode is
   use type Byte_Array_Access;
   use type Int_Array_Access;
   use type Interfaces.Unsigned_8;
   function Hash (Name : String) return Interfaces.Unsigned_64 is
      H : Interfaces.Unsigned_64 := 5381;
   begin
      for C of Name loop
         exit when C = Character'Val (0);
         H := Hash_Step (H, C);
      end loop;
      return H;
   end Hash;
   function Object_Count (S : MJ.Models.Sizes; Kind : Obj_Kind) return Natural is
   begin
      return (case Kind is
         when Obj_Body | Obj_Xbody => S.Nbody,
         when Obj_Joint => S.Njnt,
         when Obj_Geom => S.Ngeom,
         when Obj_Site => S.Nsite,
         when Obj_Camera => S.Ncam,
         when Obj_Light => S.Nlight,
         when Obj_Flex => S.Nflex,
         when Obj_Mesh => S.Nmesh,
         when Obj_Skin => S.Nskin,
         when Obj_Hfield => S.Nhfield,
         when Obj_Texture => S.Ntex,
         when Obj_Material => S.Nmat,
         when Obj_Pair => S.Npair,
         when Obj_Exclude => S.Nexclude,
         when Obj_Equality => S.Neq,
         when Obj_Tendon => S.Ntendon,
         when Obj_Actuator => S.Nactuator,
         when Obj_Sensor => S.Nsensor,
         when Obj_Numeric => S.Nnumeric,
         when Obj_Text => S.Ntext,
         when Obj_Tuple => S.Ntuple,
         when Obj_Key => S.Nkey,
         when Obj_Plugin => S.Nplugin,
         when others => 0);
   end Object_Count;
   function Address (M : MJ.Models.Model; Kind : Obj_Kind; Id : Natural) return Integer is
   begin
      case Kind is
         when Obj_Body | Obj_Xbody =>
            if M.Names.Name_Bodyadr /= null and then Id in M.Names.Name_Bodyadr'Range then
               return M.Names.Name_Bodyadr (Id);
            end if;
         when Obj_Joint =>
            if M.Names.Name_Jntadr /= null and then Id in M.Names.Name_Jntadr'Range then
               return M.Names.Name_Jntadr (Id);
            end if;
         when Obj_Geom =>
            if M.Names.Name_Geomadr /= null and then Id in M.Names.Name_Geomadr'Range then
               return M.Names.Name_Geomadr (Id);
            end if;
         when Obj_Site =>
            if M.Names.Name_Siteadr /= null and then Id in M.Names.Name_Siteadr'Range then
               return M.Names.Name_Siteadr (Id);
            end if;
         when Obj_Camera =>
            if M.Names.Name_Camadr /= null and then Id in M.Names.Name_Camadr'Range then
               return M.Names.Name_Camadr (Id);
            end if;
         when Obj_Light =>
            if M.Names.Name_Lightadr /= null and then Id in M.Names.Name_Lightadr'Range then
               return M.Names.Name_Lightadr (Id);
            end if;
         when Obj_Flex =>
            if M.Names.Name_Flexadr /= null and then Id in M.Names.Name_Flexadr'Range then
               return M.Names.Name_Flexadr (Id);
            end if;
         when Obj_Mesh =>
            if M.Names.Name_Meshadr /= null and then Id in M.Names.Name_Meshadr'Range then
               return M.Names.Name_Meshadr (Id);
            end if;
         when Obj_Skin =>
            if M.Names.Name_Skinadr /= null and then Id in M.Names.Name_Skinadr'Range then
               return M.Names.Name_Skinadr (Id);
            end if;
         when Obj_Hfield =>
            if M.Names.Name_Hfieldadr /= null and then Id in M.Names.Name_Hfieldadr'Range then
               return M.Names.Name_Hfieldadr (Id);
            end if;
         when Obj_Texture =>
            if M.Names.Name_Texadr /= null and then Id in M.Names.Name_Texadr'Range then
               return M.Names.Name_Texadr (Id);
            end if;
         when Obj_Material =>
            if M.Names.Name_Matadr /= null and then Id in M.Names.Name_Matadr'Range then
               return M.Names.Name_Matadr (Id);
            end if;
         when Obj_Pair =>
            if M.Names.Name_Pairadr /= null and then Id in M.Names.Name_Pairadr'Range then
               return M.Names.Name_Pairadr (Id);
            end if;
         when Obj_Exclude =>
            if M.Names.Name_Excludeadr /= null and then Id in M.Names.Name_Excludeadr'Range then
               return M.Names.Name_Excludeadr (Id);
            end if;
         when Obj_Equality =>
            if M.Names.Name_Eqadr /= null and then Id in M.Names.Name_Eqadr'Range then
               return M.Names.Name_Eqadr (Id);
            end if;
         when Obj_Tendon =>
            if M.Names.Name_Tendonadr /= null and then Id in M.Names.Name_Tendonadr'Range then
               return M.Names.Name_Tendonadr (Id);
            end if;
         when Obj_Actuator =>
            if M.Names.Name_Actuatoradr /= null and then Id in M.Names.Name_Actuatoradr'Range then
               return M.Names.Name_Actuatoradr (Id);
            end if;
         when Obj_Sensor =>
            if M.Names.Name_Sensoradr /= null and then Id in M.Names.Name_Sensoradr'Range then
               return M.Names.Name_Sensoradr (Id);
            end if;
         when Obj_Numeric =>
            if M.Names.Name_Numericadr /= null and then Id in M.Names.Name_Numericadr'Range then
               return M.Names.Name_Numericadr (Id);
            end if;
         when Obj_Text =>
            if M.Names.Name_Textadr /= null and then Id in M.Names.Name_Textadr'Range then
               return M.Names.Name_Textadr (Id);
            end if;
         when Obj_Tuple =>
            if M.Names.Name_Tupleadr /= null and then Id in M.Names.Name_Tupleadr'Range then
               return M.Names.Name_Tupleadr (Id);
            end if;
         when Obj_Key =>
            if M.Names.Name_Keyadr /= null and then Id in M.Names.Name_Keyadr'Range then
               return M.Names.Name_Keyadr (Id);
            end if;
         when Obj_Plugin =>
            if M.Names.Name_Pluginadr /= null and then Id in M.Names.Name_Pluginadr'Range then
               return M.Names.Name_Pluginadr (Id);
            end if;
         when others => null;
      end case;
      return -1;
   end Address;
   function Table_Offset (M : MJ.Models.Model; Kind : Obj_Kind) return Int64 is
      Offset : Int64 := Int64 (M.S.Nnames_Map);
      Active : Boolean := False;
   begin
      Active := Active or else Kind in Obj_Body | Obj_Xbody;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nbody); end if;
      Active := Active or else Kind = Obj_Joint;
      if Active then Offset := Offset - 2 * Int64 (M.S.Njnt); end if;
      Active := Active or else Kind = Obj_Geom;
      if Active then Offset := Offset - 2 * Int64 (M.S.Ngeom); end if;
      Active := Active or else Kind = Obj_Site;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nsite); end if;
      Active := Active or else Kind = Obj_Camera;
      if Active then Offset := Offset - 2 * Int64 (M.S.Ncam); end if;
      Active := Active or else Kind = Obj_Light;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nlight); end if;
      Active := Active or else Kind = Obj_Flex;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nflex); end if;
      Active := Active or else Kind = Obj_Mesh;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nmesh); end if;
      Active := Active or else Kind = Obj_Skin;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nskin); end if;
      Active := Active or else Kind = Obj_Hfield;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nhfield); end if;
      Active := Active or else Kind = Obj_Texture;
      if Active then Offset := Offset - 2 * Int64 (M.S.Ntex); end if;
      Active := Active or else Kind = Obj_Material;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nmat); end if;
      Active := Active or else Kind = Obj_Pair;
      if Active then Offset := Offset - 2 * Int64 (M.S.Npair); end if;
      Active := Active or else Kind = Obj_Exclude;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nexclude); end if;
      Active := Active or else Kind = Obj_Equality;
      if Active then Offset := Offset - 2 * Int64 (M.S.Neq); end if;
      Active := Active or else Kind = Obj_Tendon;
      if Active then Offset := Offset - 2 * Int64 (M.S.Ntendon); end if;
      Active := Active or else Kind = Obj_Actuator;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nactuator); end if;
      Active := Active or else Kind = Obj_Sensor;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nsensor); end if;
      Active := Active or else Kind = Obj_Numeric;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nnumeric); end if;
      Active := Active or else Kind = Obj_Text;
      if Active then Offset := Offset - 2 * Int64 (M.S.Ntext); end if;
      Active := Active or else Kind = Obj_Tuple;
      if Active then Offset := Offset - 2 * Int64 (M.S.Ntuple); end if;
      Active := Active or else Kind = Obj_Key;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nkey); end if;
      Active := Active or else Kind = Obj_Plugin;
      if Active then Offset := Offset - 2 * Int64 (M.S.Nplugin); end if;
      return (if Active then Offset else -1);
   end Table_Offset;
   function Equal_Name (Names : Byte_Array; Start : Integer; Name : String) return Boolean is
      Position : Int64 := Int64 (Start);
   begin
      for C of Name loop
         exit when C = Character'Val (0);
         if Position not in Int64 (Names'First) .. Int64 (Names'Last) then return False; end if;
         if Names (Natural (Position)) /= Character'Pos (C) then return False; end if;
         Position := Position + 1;
      end loop;
      return Position in Int64 (Names'First) .. Int64 (Names'Last)
        and then Names (Natural (Position)) = 0;
   end Equal_Name;
   function Name2id (M : MJ.Models.Model; Kind : Obj_Kind; Name : String) return Integer is
      Count : constant Natural := Object_Count (M.S, Kind);
      Base : constant Int64 := Table_Offset (M, Kind);
      Number : constant Int64 := 2 * Int64 (Count);
      Slot : Int64;
      Id, Adr : Integer;
   begin
      if Count = 0 or else Base < 0 or else M.Names.Names = null
        or else M.Names.Names_Map = null then return -1; end if;
      if Base + Number > Int64 (M.Names.Names_Map'Last) + 1
        or else Base < Int64 (M.Names.Names_Map'First) then return -1; end if;
      Slot := Int64 (Hash (Name) mod Interfaces.Unsigned_64 (Number));
      for Attempt in 1 .. Number loop
         Id := M.Names.Names_Map (Natural (Base + Slot));
         if Id < 0 or else Id >= Count then return -1; end if;
         Adr := Address (M, Kind, Natural (Id));
         if Equal_Name (M.Names.Names.all, Adr, Name) then return Id; end if;
         Slot := (if Slot + 1 = Number then 0 else Slot + 1);
         pragma Loop_Invariant (Static => Slot in 0 .. Number - 1);
      end loop;
      return -1;
   end Name2id;
   function Id2name (M : MJ.Models.Model; Kind : Obj_Kind; Id : Integer) return String is
      Count : constant Natural := Object_Count (M.S, Kind);
      Adr : Integer;
      Last : Integer;
   begin
      if Id < 0 or else Id >= Count or else M.Names.Names = null then return ""; end if;
      Adr := Address (M, Kind, Natural (Id));
      if Adr not in M.Names.Names'Range then return ""; end if;
      Last := Adr;
      while Last in M.Names.Names'Range and then M.Names.Names (Last) /= 0 loop
         if Last = Integer'Last then return ""; end if;
         Last := Last + 1;
      end loop;
      if Last not in M.Names.Names'Range then return ""; end if;
      declare Result : String (1 .. Last - Adr);
      begin
         for J in Result'Range loop
            Result (J) := Character'Val (M.Names.Names (Adr + J - 1));
         end loop;
         return Result;
      end;
   end Id2name;
end MJ.API.Names;
