with Aunit.Run;
with Unscented_Kalman_Test;

procedure Test is
   Test_Cases : aliased Unscented_Kalman_Test.Unscented_Kalman_Test;
begin
   Aunit.Run.Run(Test_Cases'Access);
end Test;
