--  Minimal assertion helper for the test programs. Not SPARK.
package Check is
   procedure Assert (Cond : Boolean; Msg : String);
   procedure Assert_Eq (Actual, Expected : Integer; Msg : String);
   --  Distinct name: an overload on Long_Long_Integer would make universal-integer
   --  arguments such as 'Length ambiguous.
   procedure Assert_Eq64 (Actual, Expected : Long_Long_Integer; Msg : String);
   procedure Assert_Eq (Actual, Expected : String; Msg : String);
   procedure Fail (Msg : String);
   function Failures return Natural;
   --  Prints the summary and sets the process exit status (1 on any failure).
   procedure Report_And_Exit;
end Check;
