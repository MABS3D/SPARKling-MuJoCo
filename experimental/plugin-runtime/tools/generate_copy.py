"""Generate a deep model projection; never shallow-copy ownership pointers."""
from pathlib import Path
import re
ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parents[1]
source = (ROOT / 'src/gen/mj-models.ads').read_text()
records = dict(re.findall(r'type\s+(\w+_Arrays)\s+is record(.*?)end record;', source, re.S))
model = re.search(r'type Model is record(.*?)end record;', source, re.S).group(1)
lines = ['with MJ.Types; use MJ.Types;', 'package body MJ.Plugin_Model_Copy with SPARK_Mode is',
 '   procedure Build (Source : MJ.Models.Model; Base : in out MJ.Models.Model) is',
 '      S : MJ.Models.Sizes := Source.S;', '   begin',
 '      S.Nplugin := 0; S.Npluginattr := 0; S.Npluginstate := 0;',
 '      MJ.Models.Allocate (S, Base);']
for field, typ in re.findall(r'^\s*(\w+)\s*:\s*([\w.]+)\s*(?:[:;])', model, re.M):
    if typ in records:
        for member in re.findall(r'^\s*(\w+)\s*:', records[typ], re.M):
            lines += [f'      if Base.{field}.{member} /= null then',
                      f'         for I in Base.{field}.{member}\'Range loop',
                      f'            Base.{field}.{member} (I) := Source.{field}.{member} (I);',
                      '         end loop;', '      end if;']
    elif field != 'S':
        lines.append(f'      Base.{field} := Source.{field};')
lines += [
 "      Base.Bodies.Body_Plugin.all := [others => -1];",
 "      Base.Geoms.Geom_Plugin.all := [others => -1];",
 "      Base.Actuators.Actuator_Plugin.all := [others => -1];",
 "      Base.Sensors.Sensor_Plugin.all := [others => -1];",
 "      for I in 0 .. Source.S.Nactuator - 1 loop",
 "         if Source.Actuators.Actuator_Plugin (I) >= 0 then",
 "            Base.Actuators.Actuator_Gaintype (I) := 0;",
 "            Base.Actuators.Actuator_Biastype (I) := 0;",
 "            Base.Actuators.Actuator_Gainprm (10 * I) := 0.0;",
 "            Base.Actuators.Actuator_Dyntype (I) := (if Source.Actuators.Actuator_Actnum (I) = 0 then 0 else 1);",
 "         end if;", "      end loop;",
 "      for I in 0 .. Source.S.Nsensor - 1 loop",
 "         if Source.Sensors.Sensor_Type (I) = 47 then Base.Sensors.Sensor_Type (I) := 48; end if;",
 "      end loop;", "   end Build;", "end MJ.Plugin_Model_Copy;"]
(HERE / 'src/mj-plugin_model_copy.adb').write_text('\n'.join(lines)+'\n')
