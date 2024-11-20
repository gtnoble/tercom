with AUnit.Assertions; use AUnit.Assertions;

package body Unscented_Kalman_Test is
   
   function Name (T : Unscented_Kalman_Test) return Message_String
   is
      return Format ("Unscented Kalman Filter Tests");
   begin
   end Name;
   
   procedure Register_Tests (T : in out Unscented_Kalman_Test)
   is
      use Aunit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Get_Weights'Access, "Test Get Weights");
      Register_Routine (T, Test_Predict'Access, "Test Predict");
      Register_Routine (T, Test_Update'Access, "Test Update");
   end Register_Tests;
   
   procedure Set_Up (T : in out Unscented_Kalman_Test)
   is
   begin
   end Set_Up;
   
   procedure Test_Get_Weights (T : in out Test_Cases.Test_Case'Class)

   is
      Alpha : Float := 1;
      Beta : Float := 2;
      Kappa : Float := 3;
      Weights : Sigma_Point_Weights;
   begin
      Weights := Test_Kalman_Filter.Get_Weights (
         Alpha => Alpha,
         Beta => Beta,
         Kappa => Kappa
      );

      Assert (
         Weights.Mean (Weights.Mean'Last) = (1 / (2 * Alpha ** 2 * Kappa)), 
         "Unexpected Last Mean Weight"
      );
   end Test_Get_Weights;

end Unscented_Kalman_Test;