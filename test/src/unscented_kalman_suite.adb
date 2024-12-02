with Unscented_Kalman_Test;         use Unscented_Kalman_Test;
with AUnit.Test_Caller;

package body Unscented_Kalman_Suite is

   package Caller is new AUnit.Test_Caller (
      Unscented_Kalman_Test.Unscented_Kalman_Fixture
   );

   function Suite return Access_Test_Suite is
      Ret : constant Access_Test_Suite := new Test_Suite;
   begin
      Ret.Add_Test
        (Caller.Create ("Test Make Kalman Filter", Test_Make_Kalman_Filter'Access));
      Ret.Add_Test
        (Caller.Create ("Test Predict", Test_Predict'Access));
      return Ret;
   end Suite;

end Unscented_Kalman_Suite;