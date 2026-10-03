with MJ.Types; use MJ.Types;
with MJ.Models;
package MJ.API.Model_Info with SPARK_Mode is
   function Type_Name (Kind : Obj_Kind) return String is
     (case Kind is
         when Obj_Body => "body",
         when Obj_Xbody => "xbody",
         when Obj_Joint => "joint",
         when Obj_Dof => "dof",
         when Obj_Geom => "geom",
         when Obj_Site => "site",
         when Obj_Camera => "camera",
         when Obj_Light => "light",
         when Obj_Flex => "flex",
         when Obj_Mesh => "mesh",
         when Obj_Skin => "skin",
         when Obj_Hfield => "hfield",
         when Obj_Texture => "texture",
         when Obj_Material => "material",
         when Obj_Pair => "pair",
         when Obj_Exclude => "exclude",
         when Obj_Equality => "equality",
         when Obj_Tendon => "tendon",
         when Obj_Actuator => "actuator",
         when Obj_Sensor => "sensor",
         when Obj_Numeric => "numeric",
         when Obj_Text => "text",
         when Obj_Tuple => "tuple",
         when Obj_Key => "key",
         when Obj_Plugin => "plugin",
         when Obj_Frame => "frame",
         when others => "") with Global => null;
   function Name_Type (Name : String) return Obj_Kind with Global => null,
     Post => (if Name_Type'Result /= Obj_Unknown then Type_Name (Name_Type'Result) = Name);
   function Is_Sparse (S : MJ.Models.Sizes; Jacobian : Integer) return Boolean is
     (Jacobian = 1 or else (Jacobian = 2 and then S.Nv >= 60)) with Global => null;
   function Is_Pyramidal (Cone : Integer) return Boolean is (Cone = 0) with Global => null;
   function Is_Dual (Solver, Noslip_Iterations : Integer) return Boolean is
     (Solver = 0 or else Noslip_Iterations > 0) with Global => null;
end MJ.API.Model_Info;
