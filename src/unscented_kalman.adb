package body Unscented_Kalman is
  
  function Predict (
    Previous_Update : State_Statistics;
    Sigma_Points : Sigma_Point_States;
    State_To_Next_Map : Transition_Function;
    Transition_Noise_Covariance : State_Covariance;
    Weights : Sigma_Point_Weights
  ) return State_Statistics
  is
    Predicted_Estimate : State_Statistics;
    Propagated_Sigma_Points : Sigma_Point_States;
  begin
    for Index in Sigma_Points'Range loop
      Set_Row(
         Index, 
         Real_Matrix (Propagated_Sigma_Points), 
         State_To_Next_Map (Get_Row(Index, Sigma_Points))
      );
    end loop;
    
    return Predict_Statistics (Propagated_Sigma_Points, Weights, Transition_Noise_Covariance);
  end Predict;
  
  function Update (
    Previous_Prediction : State_Statistics;
    Actual_Measurement : Measurement;
    Sigma_Points : in out Sigma_Point_States;
    State_To_Measurement_Map : Measurement_Function;
    Measurement_Noise_Covariance : Measurement_Covariance;
    Weights : Sigma_Point_Weights
  ) return State_Statistics
  is
    type Measurement_Prediction_Type is record
      Mean : Measurement;
      Covariance : Measurement_Covariance;
    end record;
    
    Propagated_Measurement_Points : Sigma_Point_Measurements;
    Measurement_Prediction : Measurement_Prediction_Type;
    Kalman_Gain : Measurement_Covariance;
  begin
    Update_Sigma_Points(Sigma_Points, Previous_Prediction);

    for Index in Sigma_Points'Range loop
       Set_Row (
         Index, 
         Propagated_Measurement_Points, 
         Measurement_Function (Get_Row (Index, Sigma_Points))
      );
    end loop;

    Measurement_Prediction := Predict_Statistics(
      Propagated_Measurement_Points, 
      Weights, 
      Measurement_Noise_Covariance
    );
    
    declare
      State_Measurement_Cross_Covariance : Cross_Covariance_Matrix := (others => (others => 0));
    begin
      for Index in Sigma_Points'Range loop
        State_Measurement_Cross_Covariance := State_Measurement_Cross_Covariance +
                                              Weights.Covariance (Index) *
                                              To_Column_Vector (Get_Row(Index, Sigma_Points) - Previous_Prediction.Mean) *
                                              To_Row_Vector (
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
  end Get_Weights;
  
  function Predict_Statistics (
    Propagated_Points  : Real_Matrix;
    Weights            : Sigma_Point_Weights;
    Noise_Covariance   : Real_Matrix
  ) return Prediction_Type
  is
   subtype Data_Vector_Range is Propagated_Points'Range(2);
   subtype Point_Type is Real_Vector (Data_Vector_Range);
   subtype Covariance_Type is Real_Matrix (Data_Vector_Range, Data_Vector_Range);

    Predicted_Mean       : Point_Type := (others => (1));
    Predicted_Covariance : Covariance_Type := (others => (others => 0));
  begin
    for Point_Index in Propagated_Points'Range loop
      Predicted_Mean := Predicted_Mean + Get_Row (Point_Index, Propagated_Points) * Weights.Mean (Point_Index);
    end loop;

    for Point_Index in Propagated_Points'Range loop
      declare
        Estimate_Difference : Point_Type := Get_Row (Point_Index, Propagated_Points) - Predicted_Mean;
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