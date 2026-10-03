package body MJ.API.Model_Info with SPARK_Mode is
   function Name_Type (Name : String) return Obj_Kind is
   begin
      if Name = "body" then return Obj_Body; end if;
      if Name = "xbody" then return Obj_Xbody; end if;
      if Name = "joint" then return Obj_Joint; end if;
      if Name = "dof" then return Obj_Dof; end if;
      if Name = "geom" then return Obj_Geom; end if;
      if Name = "site" then return Obj_Site; end if;
      if Name = "camera" then return Obj_Camera; end if;
      if Name = "light" then return Obj_Light; end if;
      if Name = "flex" then return Obj_Flex; end if;
      if Name = "mesh" then return Obj_Mesh; end if;
      if Name = "skin" then return Obj_Skin; end if;
      if Name = "hfield" then return Obj_Hfield; end if;
      if Name = "texture" then return Obj_Texture; end if;
      if Name = "material" then return Obj_Material; end if;
      if Name = "pair" then return Obj_Pair; end if;
      if Name = "exclude" then return Obj_Exclude; end if;
      if Name = "equality" then return Obj_Equality; end if;
      if Name = "tendon" then return Obj_Tendon; end if;
      if Name = "actuator" then return Obj_Actuator; end if;
      if Name = "sensor" then return Obj_Sensor; end if;
      if Name = "numeric" then return Obj_Numeric; end if;
      if Name = "text" then return Obj_Text; end if;
      if Name = "tuple" then return Obj_Tuple; end if;
      if Name = "key" then return Obj_Key; end if;
      if Name = "plugin" then return Obj_Plugin; end if;
      if Name = "frame" then return Obj_Frame; end if;
      return Obj_Unknown;
   end Name_Type;
end MJ.API.Model_Info;
