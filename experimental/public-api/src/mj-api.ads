with MJ.Models;
package MJ.API with SPARK_Mode is
   Version_Number : constant := MJ.Models.Version_Header;
   function Version return Integer is (Version_Number) with Global => null;
   function Version_String return String is ("3.14.0") with Global => null;
   type Status is (Success, Invalid_Signature, Invalid_Size,
                   Invalid_Model, Unsupported_Component, Numeric_Limit);
end MJ.API;
