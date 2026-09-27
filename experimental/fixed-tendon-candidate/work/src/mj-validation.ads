--  The proven checker (spec 5): computes the capacities, evaluates Is_Valid,
--  and on failure names the first offending field and element.
with MJ.Types;           use MJ.Types;
with MJ.Fields;          use MJ.Fields;
with MJ.Models;          use MJ.Models;
with MJ.Models.Validity; use MJ.Models.Validity;

package MJ.Validation with SPARK_Mode is

   type Validate_Options is record
      Contact_Cap : Cap_Type := 0;   --  0 selects the automatic rule of spec 5.11
   end record;

   procedure Validate (M : in out Model; Options : Validate_Options; Result : out Load_Result) with
     Pre  => Valid_Layout (M),
     Post => Valid_Layout (M) and then M.S = M.S'Old
             and then (if Result.Status = OK then Is_Valid (M));

end MJ.Validation;
