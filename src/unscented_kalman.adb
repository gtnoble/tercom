package body Unscented_Kalman is
  function Inital_Estimate_Weights (Alpha, Kappa : T) return Estimate_Weights_Vector
  is
    Weights : Estimate_Weights_Vector := (others => 1);
  begin
    Weights := Weights *
      (Alpha ** 2 * Kappa - (Weights'Length / 2)) /
      Alpha ** 2 * Kappa;
    return Weights;
  end Initial_Estimate_Weights;
  
  function Estimate_Weights (Alpha, Kappa : T)
  is
    Weights : Estimate_Weights_Vector := (others => 1);
  begin
    Weights := Weights * (1 / (2 * Alpha ** 2 * Kappa));
    return Weights;
  end Estimate_Weights;
  

end Unscented_Kalman;