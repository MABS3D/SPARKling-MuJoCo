with MJ.Types; use MJ.Types;

--  Ordered scalar building blocks for mj_jacSum and contact diagApprox.
--  Contributions already carry the sign produced by mj_vertBodyWeight.
--  Absent sparse entries preserve both the accumulator and its support bit.
package MJ.Flex_Response_Kernels with SPARK_Mode is
   Max_Terms : constant := 1458;
   subtype Prefix is Natural range 0 .. Max_Terms;
   subtype Jacobian_Value is Real range -3.0e20 .. 3.0e20;
   subtype Body_Weight is Real range -5.0e4 .. 5.0e4;
   subtype Product_Value is Real range -1.5e25 .. 1.5e25;
   subtype Work is Real range -1.0e30 .. 1.0e30;
   subtype Frame_Value is Real range -2.0 .. 2.0;
   type Contribution is record
      Present : Boolean := False;
      Value : Jacobian_Value := 0.0;
      Weight : Body_Weight := 0.0;
   end record;
   type Contributions is array (Natural range 0 .. Max_Terms - 1) of Contribution;
   type Accumulator is record
      Present : Boolean := False;
      Value : Work := 0.0;
   end record;
   function Bounded (A : Accumulator; Visited : Prefix) return Boolean is
     (A.Value in -Real (Visited) * 2.0e25 .. Real (Visited) * 2.0e25);

   function Scale (Value : Jacobian_Value; Weight : Body_Weight) return Product_Value
     with Global => null, Inline, Post => Scale'Result = Weight * Value;
   function Add (Previous : Work; Term : Product_Value) return Real
     with Global => null, Inline, Post => Add'Result = Previous + Term;

   function Advance (A : Accumulator; C : Contribution; Visited : Prefix)
     return Accumulator
     with Global => null, Inline,
       Pre => Visited < Max_Terms and then Bounded (A, Visited),
       Post => (Static => Bounded (Advance'Result, Visited + 1)
         and then Advance'Result.Present = (A.Present or C.Present)
         and then Advance'Result.Value =
           (if not C.Present then A.Value
            elsif A.Present then A.Value + C.Weight * C.Value
            else C.Weight * C.Value));

   --  False seeds sparse/dense Jacobian scaling on the first present term.
   --  True seeds diagApprox: its first term is added to positive zero in C.
   function Fold (Terms : Contributions; Count : Prefix; Seed_Present : Boolean)
     return Accumulator
     with Ghost => Static, Global => null,
       Subprogram_Variant => (Decreases => Count),
       Post => (Static => Bounded (Fold'Result, Count)
         and then Fold'Result =
           (if Count = 0 then Accumulator'(Seed_Present, 0.0)
            else Advance (Fold (Terms, Count - 1, Seed_Present),
              Terms (Count - 1), Count - 1)));
   procedure Combine (Terms : Contributions; Count : Prefix; Seed_Present : Boolean;
     Value : out Accumulator)
     with Global => null,
       Post => (Static => Bounded (Value, Count)
         and then Value = Fold (Terms, Count, Seed_Present));

   function Frame_Step (Previous : Real; Value : Work; Weight : Frame_Value) return Real
     with Global => null, Inline,
       Pre => Previous in -1.0e32 .. 1.0e32,
       Post => Frame_Step'Result =
         (if Weight = 0.0 then Previous else Previous + Weight * Value);
   function Project (X, Y, Z : Work; A, B, C : Frame_Value) return Real
     with Global => null, Inline,
       Post => Project'Result =
         Frame_Step (Frame_Step (Frame_Step (0.0, X, A), Y, B), Z, C);
end MJ.Flex_Response_Kernels;
