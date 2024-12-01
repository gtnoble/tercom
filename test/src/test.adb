pragma Assertion_Policy (Check);

with AUnit.Reporter.Text;
with Aunit.Run;
with Unscented_Kalman_Suite; use Unscented_Kalman_suite;

procedure Test is
   procedure Runner is new AUnit.Run.Test_Runner (Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Runner (Reporter);
end Test;
