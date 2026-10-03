with Ada.Text_IO; use Ada.Text_IO;
with Ada.Assertions;
with Ada.Unchecked_Conversion;
with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Advanced_State;
procedure Stage_Probe is
   use type Interfaces.Unsigned_64;
   function Bits is new Ada.Unchecked_Conversion (Real, Interfaces.Unsigned_64);
   Values : constant Real_Array :=
     [-Real'Last, -1.0e11, Real'Adjacent (-Max_Val, -Real'Last), -Max_Val,
      -1.0, -Min_Val, -0.0, 0.0, Min_Val, 1.0, Max_Val,
      Real'Adjacent (Max_Val, Real'Last), 1.0e11, Real'Last];
   type Indices is array (Positive range <>) of Natural;
   Bases : constant Indices := [0, 1, 3, 4, Natural'Last];
   Offsets : constant Indices := [0, 1, 3, Natural'Last];
   Sizes : constant Indices := [0, 4];
   Count, Failed : Natural := 0;
   --  The previous production Stage body, with Configuration fields passed
   --  as scalars; Apply is Act_Limited and then Dyn_Kind /= 5.
   procedure Previous (A : in out Real_Array; Can_Advance : in out Boolean;
                       Base, Offset : Natural; Value : Real;
                       Lower, Upper : Tier0_Real; Apply : Boolean) is
      X : Real := Value;
   begin
      if Apply then X := Real'Min (Upper, Real'Max (Lower, X)); end if;
      if X not in Tier0_Real then Can_Advance := False;
      else A (Base+Offset) := X; end if;
   end Previous;
   procedure Compare (N, Base, Offset : Natural; Value : Real;
                      Lower, Upper : Tier0_Real; Apply, Initial : Boolean) is
      A, B : Real_Array (0 .. Integer (N)-1);
      CA, CB : Boolean := Initial;
      EA, EB : Natural := 0;
      Same : Boolean;
   begin
      for I in A'Range loop A (I) := Real (I)+0.25; end loop;
      B := A;
      begin
         Previous (A, CA, Base, Offset, Value, Lower, Upper, Apply);
      exception
         when Constraint_Error => EA := 1;
         when Ada.Assertions.Assertion_Error => EA := 2;
         when others => EA := 3;
      end;
      begin
         MJ.Advanced_State.Stage_Activation (B, CB, Base, Offset, Value, Lower, Upper, Apply);
      exception
         when Constraint_Error => EB := 1;
         when Ada.Assertions.Assertion_Error => EB := 2;
         when others => EB := 3;
      end;
      Same := EA = EB and then CA = CB;
      for I in A'Range loop Same := Same and then Bits (A (I)) = Bits (B (I)); end loop;
      Count := Count+1;
      if not Same then
         Failed := Failed+1;
         Put_Line ("FAIL" & Count'Image & EA'Image & EB'Image);
      end if;
   end Compare;
begin
   if Real'Size /= 64 or else Interfaces.Unsigned_64'Size /= 64 then
      raise Program_Error with "probe requires binary64 width";
   end if;
   for N of Sizes loop
      for Base of Bases loop
         for Offset of Offsets loop
            for Value of Values loop
               for Apply in Boolean loop
                  for Initial in Boolean loop
                     Compare (N, Base, Offset, Value, -2.0, 2.0, Apply, Initial);
                     Compare (N, Base, Offset, Value, 2.0, -2.0, Apply, Initial);
                     Compare (N, Base, Offset, Value, -Max_Val, Max_Val, Apply, Initial);
                  end loop;
               end loop;
            end loop;
         end loop;
      end loop;
   end loop;
   Put_Line ("RESULT" & Count'Image & Natural'Image (Count-Failed));
   if Failed /= 0 then raise Program_Error with "stage mismatch"; end if;
end Stage_Probe;
