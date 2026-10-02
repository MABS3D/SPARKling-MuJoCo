with Interfaces; use Interfaces;
package MJ.Friction_Random with SPARK_Mode, Pure is
   type Generator is record
      State : Unsigned_64 := 0;
      Increment : Unsigned_64 := 1;
   end record;
   package Model with Ghost => Static is
      function Next_State (G : Generator) return Unsigned_64 is
        (G.State * 6_364_136_223_846_793_005 + (G.Increment or 1));
      function Output (State : Unsigned_64) return Unsigned_32 is
        (declare X : constant Unsigned_32 := Unsigned_32
                   (Shift_Right (Shift_Right (State, 18) xor State, 27) and 16#FFFF_FFFF#);
                 R : constant Natural := Natural (Shift_Right (State, 59));
         begin Shift_Right (X, R) or Shift_Left (X, (32 - R) mod 32));
   end Model;
   procedure Next (G : in out Generator; Value : out Unsigned_32)
   with Global => null,
     Post => (Static => G.State = Model.Next_State (G'Old)
       and G.Increment = G.Increment'Old and Value = Model.Output (G.State'Old));
end MJ.Friction_Random;
