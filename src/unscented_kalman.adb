package body Unscented_Kalman is
  
  function Predict (
    Previous_Update : Filter_Estimate;
    Sigma_Points : Sigma_Points_Type;
    Transition_Function : Transition_Function_Type;
    Transition_Noise_Covariance : State_Covariance;
    Weights : Weights_Type
  ) return Filter_Estimate
  is
    Predicted_Estimate : Filter_Estimate;
    Propagated_Sigma_Points : Sigma_Points_Type;
  begin
    for Index in Sigma_Points'Range loop
      Propagated_Sigma_Points (Index) := Transition_Function (Sigma_Points (Index));
    end loop;
    
    return Predict_State_Statistics (Propagated_Sigma_Points, Weights, Transition_Noise_Covariance);
  end Predict;
  
  function Update (
    Previous_Prediction : Filter_Estimate;
    Actual_Measurement : Measurement;
    Sigma_Points : in out Sigma_Points_Type;
    Measurement_Function : Measurement_Function_Type;
    Measurement_Noise_Covariance : Measurement_Covariance_Matrix;
    Weights : Weights_Type
  ) return Filter_Estimate
  is
    type Measurement_Prediction_Type is record
      Mean : Measurement;
      Covariance : Measurement_Covariance_Matrix;
    end record;
    
    Propagated_Measurement_Points : Measurement_Matrix_Type;
    Measurement_Prediction : Measurement_Prediction_Type;
    Kalman_Gain : Measurement_Covariance_Matrix;
    
  begin
    Update_Sigma_Points(Sigma_Points, Previous_Prediction);

    for Index of Sigma_Points'Range loop
      Propagated_Measurement_Points (Index) := Measurement_Function (Sigma_Points (Index));
    end loop;

    Measurement_Prediction := Predict_Measurement_Statistics(
      Propagated_Measurement_Points, 
      Weights, 
      Measurement_Noise_Covariance
    );
    
    declare
      State_Measurement_Cross_Covariance : Cross_Covariance_Matrix := (others => (others => 0));
    begin
      for Index of Sigma_Points'Range loop
        State_Measurement_Cross_Covariance := State_Measurement_Cross_Covariance +
                                              Weights.Covariance (Index) *
                                              (Sigma_Points (Index) - Previous_Prediction.Mean) *
                                              Transpose (
                                                Propagated_Measurement_Points (Index) - Measurement_Prediction.Mean
                                              ) +
                                              Measurement_Noise_Covariance;
      end loop;
      Kalman_Gain := State_Measurement_Cross_Covariance * Inverse (Measurement_Prediction.Covariance);
    end;
    
    return (Mean => Previous_Prediction.Mean + 
                    Kalman_Gain * (Actual_Measurement - Measurement_Prediction.Mean),
            Covariance => Previous_Prediction.Covariance - 
                          Kalman_Gain * 
                          Measurement_Prediction.Covariance * 
                          Transpose (Kalman_Gain));
  end Update;

  
  function Get_Weights (Alpha, Beta, Kappa : T) return Weights_Type
  is
    Resulting_Weights : Weights_Type;
  begin
    declare
      Mean_Weights : Weights_Type := (others => (1 / (2 * Alpha ** 2 * Kappa)));
      Covariance_Weights : Weights_Type := Mean_Weights;
      Center_Element_Index : Sigma_Points_Vector_Range := (Resulting_Weights'First + Resulting_Weights'Last) / 2;
    begin
      Mean_Weights (Mean_Weights'First) := (Alpha ** 2 * Kappa - Resulting_Weights'Length / 2) / 
                                           (Alpha ** 2 * Kappa);
      Covariance_Weights (Covariance_Weights'First) := Mean_Weights (Mean_Weights'First) + 
                                                       1 - 
                                                       Alpha ** 2 + 
                                                       Beta;
      Resulting_Weights.Covariance := Covariance_Weights;
      Resulting_Weights.Mean := Mean_Weights;
    end;
    return Resulting_Weights;
  end Weights;
  
  function Predict_Statistics_Generic (
    Propagated_Points  : Propagated_Points_Type;
    Weights            : Weights_Type;
    Noise_Covariance   : Covariance_Type
  ) return Prediction_Type
  is
    Predicted_Mean       : Propagated_Point_Type := (others => (1));
    Predicted_Covariance : Covariance_Type := (others => (others => 0));
  begin
    for Point_Index in Propagated_Points'Range loop
      Predicted_Mean := Predicted_Mean + Propagated_Points (Point_Index) * Weights.Mean (Point_Index);
    end loop;

    for Point_Index in Propagated_Points'Range loop
      declare
        Estimate_Difference : Point_Type := Propagated_Points (Point_Index) - Predicted_Mean;
      begin
        Predicted_Covariance := Predicted_Covariance + 
                                Weights.Covariance (Point_Index) * 
                                Estimate_Difference * 
                                Transpose (Estimate_Difference) + 
                                Noise_Covariance;
      end;
    end loop;

    return (Mean => Predicted_Mean, Covariance => Predicted_Covariance);
  end;
  
end Unscented_Kalman;