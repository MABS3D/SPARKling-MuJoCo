package body MJ.Data.Advanced.Test_Export is
   function Capture (E : Engine) return MJ.Data.Advanced_Control.Evaluation_State is
     (MJ.Data.Advanced_Control.Capture_Evaluation (E.C));
end MJ.Data.Advanced.Test_Export;
