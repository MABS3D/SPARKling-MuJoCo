with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Model_Compiler.Addresses;
procedure Compiler_Probe is
   package C renames MJ.Model_Compiler.Addresses;
   use type C.Result;
   use type C.Totals;
   Op : Character;
   N, X : Integer;
   Status : C.Result;
begin
   while not End_Of_File loop
      Get (Op); Ada.Integer_Text_IO.Get (N);
      if N not in 0 .. C.Max_Elements then raise Constraint_Error; end if;
      case Op is
         when 'J' =>
            declare
               Kinds : C.Joint_Array (0 .. N - 1);
               Q, V : Int_Array (0 .. N - 1) := (others => -17);
               Nq, Nv : Size_Type := 23;
            begin
               for I in Kinds'Range loop
                  Ada.Integer_Text_IO.Get (X); Kinds (I) := Joint_Kind'Val (X);
               end loop;
               C.Compile_Joints (Kinds, Q, V, Nq, Nv, Status);
               Put (Status'Image & Nq'Image & Nv'Image);
               for I in Kinds'Range loop Put (Q (I)'Image & V (I)'Image); end loop;
               New_Line;
            end;
         when 'A' =>
            declare
               Blocks : C.Actuator_Array (0 .. N - 1);
               Addresses : C.Actuator_Address_Array (0 .. N - 1) :=
                 (others => (Control => -1, Activation => -1, Output => 19));
               Counts : C.Totals := (23, 29, 31);
            begin
               for I in Blocks'Range loop
                  Ada.Integer_Text_IO.Get (X); Blocks (I).Controls := X;
                  Ada.Integer_Text_IO.Get (X); Blocks (I).Outputs := X;
                  Ada.Integer_Text_IO.Get (X); Blocks (I).Activations := X;
               end loop;
               C.Compile_Actuators (Blocks, Addresses, Counts, Status);
               Put (Status'Image & Counts.Control'Image & Counts.Output'Image & Counts.Activation'Image);
               for R of Addresses loop
                  Put (" " & R.Control'Image & " " & R.Output'Image & " " & R.Activation'Image);
               end loop;
               New_Line;
            end;
         when 'M' =>
            declare
               Flags : C.Flag_Array (0 .. N - 1);
               Ids : Int_Array (0 .. N - 1) := (others => -17);
               Count : Size_Type := 23;
            begin
               for I in Flags'Range loop
                  Ada.Integer_Text_IO.Get (X);
                  if X not in 0 .. 1 then raise Constraint_Error; end if;
                  Flags (I) := X = 1;
               end loop;
               C.Compile_Mocap (Flags, Ids, Count, Status);
               Put (Status'Image & Count'Image);
               for Id of Ids loop Put (" " & Id'Image); end loop;
               New_Line;
            end;
         when 'O' =>
            declare
               Ids : Int_Array (0 .. N - 1) := (others => -17);
            begin
               C.Compile_Ordinals (Ids, Status);
               Put (Status'Image);
               for Id of Ids loop Put (" " & Id'Image); end loop;
               New_Line;
            end;
         when 'R' =>
            declare
               Computed, Declared, Dyn : Integer;
            begin
               Put ("SUCCESS");
               for I in 1 .. N loop
                  Ada.Integer_Text_IO.Get (Computed); Ada.Integer_Text_IO.Get (Declared);
                  Ada.Integer_Text_IO.Get (Dyn);
                  if Dyn not in 0 .. 1 then raise Constraint_Error; end if;
                  Put (" " & C.Resolve_Activation (Computed, Declared, Dyn = 1)'Image);
               end loop;
               New_Line;
            end;
         when 'E' =>
            declare
               Kinds : C.Joint_Array (1 .. 2) := (others => Hinge);
               Q, V : Int_Array (0 .. 1) := (others => -17);
               Nq, Nv : Size_Type := 23;
               Blocks : C.Actuator_Array (0 .. 1) :=
                 [(Controls => Max_Size, Outputs => 0, Activations => 0),
                  (Controls => 1, Outputs => 0, Activations => 0)];
               Addr : C.Actuator_Address_Array (0 .. 1) :=
                 (others => (Control => -1, Output => 19, Activation => -1));
               Counts : C.Totals := (23,29,31);
               Flags : C.Flag_Array (1 .. 2) := (others => True);
               Ids : Int_Array (1 .. 2) := (others => -17);
               Count : Size_Type := 23;
            begin
               C.Compile_Joints (Kinds, Q, V, Nq, Nv, Status);
               if Status /= C.Invalid_Shape or else Q /= [-17,-17] or else V /= [-17,-17]
                 or else Nq /= 23 or else Nv /= 23 then raise Program_Error with "joint shape atomicity"; end if;
               C.Compile_Actuators (Blocks, Addr, Counts, Status);
               if Status /= C.Capacity_Limit or else Counts /= (23,29,31)
                 or else (for some R of Addr => R.Control /= -1 or else R.Output /= 19 or else R.Activation /= -1)
               then raise Program_Error with "actuator capacity atomicity"; end if;
               C.Compile_Mocap (Flags, Ids, Count, Status);
               if Status /= C.Invalid_Shape or else Ids /= [-17,-17] or else Count /= 23
               then raise Program_Error with "mocap shape atomicity"; end if;
               C.Compile_Ordinals (Ids, Status);
               if Status /= C.Invalid_Shape or else Ids /= [-17,-17]
               then raise Program_Error with "ordinal shape atomicity"; end if;
            end;
            declare
               Kinds : C.Joint_Array (0 .. C.Max_Elements) := (others => Free);
               Q, V : Int_Array (Kinds'Range) := (others => -17);
               Nq, Nv : Size_Type := 23;
            begin
               C.Compile_Joints (Kinds, Q, V, Nq, Nv, Status);
               if Status /= C.Capacity_Limit or else Nq /= 23 or else Nv /= 23
                 or else (for some X of Q => X /= -17) or else (for some X of V => X /= -17)
               then raise Program_Error with "joint capacity atomicity"; end if;
            end;
            Put_Line ("EDGES PASS");
         when others => raise Constraint_Error;
      end case;
      Skip_Line;
   end loop;
end Compiler_Probe;
