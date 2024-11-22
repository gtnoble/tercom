with AUnit.Assertions; use AUnit.Assertions;

package body Unscented_Kalman_Test is

   function Name (T : Unscented_Kalman_Fixture) return Message_String
   is
   begin
      return Format ("Unscented Kalman Filter Tests");
   end Name;
   
   procedure Set_Up (T : in out Unscented_Kalman_Fixture)
   is
   begin
      null;
   end Set_Up;
   
   procedure Test_Get_Weights (T : in out Unscented_Kalman_Fixture)

   is
      Alpha : constant Float := 1.0;
      Beta : constant Float := 2.0;
      Kappa : constant Float := 3.0;
      Weights : Test_Kalman_Filter.Sigma_Point_Weights;
   begin
      Weights := Test_Kalman_Filter.Get_Weights (
         Alpha => Alpha,
         Beta => Beta,
         Kappa => Kappa
      );

      Assert (
         Weights.Mean (Weights.Mean'Last) = (1.0 / (2.0 * Alpha ** 2 * Kappa)), 
         "Unexpected Last Mean Weight"
      );
   end Test_Get_Weights;

end Unscented_Kalman_Test;