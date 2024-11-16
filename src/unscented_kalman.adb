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
  
  function Initial_Covariance_Weights (Alpha, Beta : T) return Covariance_Weights_Vector
  is
    Weights : Covariance_Weights_Vector := (others => 1.0);
  begin
    Weights := Initial_Estimate_Weights + (1 - Alpha ** 2 + Beta) * Weights;
    return Weights;
  end Initial_Covariance_Weights;
  
  function Covariance_Weights (Alpha, Kappa : T) return Covariance_Weights_Vector
  is
  begin
    return Covariance_Weights_Vector (Estimate_Weights (Alpha => Alpha, Kappa => Kappa));
  end Covariance_Weights;
  
  function Predict_State (
    Propagated_State : State_Matrix; 
    Weights : Estimate_Weights_Vectori
  ) return State_Vector
  is
  begin
    return Sum_Columns (Propagated_State * Weights);
  end Predict_State;
  
  function Predict_State_Covariance (
    Propagated_State : State_Matrix;
    Predict_State : State_Vector;
    Weights : Covariance_Weights_Vector;
    Transition_Noise_Covariance : State_Covariance_Matrix
  ) return State_Covariance_Matrix
  is
    Predicted_State_Covariance : State_Covariance_Matrix := (others => (others => 0.0));
  begin
    for Sigma_Point in Propagated_State loop
      Predicted_State_Covariance := Predicted_State_Covariance + 
        Sigma_Point * Data_Arrays.Transpose (Sigma_Point) * Weights + Transition_Noise_Covariance;
    end loop;
    return Predicted_State_Covariance;
  end Predict_State_Covariance;
  
  function Update_State_Estimate (
    Predicted_State : State_Vector;
    Kalman_Gain : Measurement_Covariance_Matrix;
    Predicted_Measurement : Measurement_Vector;
    Actual_Measurement : Measurement_Vector
  ) return State_Vector
  is
  begin
    return Predicted_State + Kalman_Gain * (Actual_Measurement - Predicted_Measurement);
  end Update_State_Estimate;
  
  function Update_State_Covariance (
    Predicted_Covariance : State_Covariance_Matrix;
    Kalman_Gain : Measurement_Covariance_Matrix;
    Measurement_Covariance_Matrix : Measurement_Covariance_Matrix
  ) return State_Covariance_Matrix
  is
  begin
    return Predicted_Covariance - 
      Kalman_Gain * Measurement_Covariance_Matrix * Data_Arrays.Transpose (Kalman_Gain);
  end Update_State_Covariance;
  
end Unscented_Kalman;