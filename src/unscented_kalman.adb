package body Unscented_Kalman is
  
  function Predict (
   Filter : in out Kalman_Filter_Access;
   Transition_Noise_Covariance : State_Covariance_Type
  ) return State_Statistics;
  is
    Propagated_Sigma_Points : Sigma_Points_Type;
   begin
    for Index in Filter.Sigma_Points'Range loop
      Set_Row(
         Index, 
         Propagated_Sigma_Points, 
         State_To_Next_Map (Get_Row(Index, Filter.Sigma_Points))
      );
    end loop;
    
    Filter.Current_Statistics := Predict_Statistics (
      Propagated_Sigma_Points, 
      Filter.Weights,
      Transition_Noise_Covariance
   );
   return Filter.Current_Statistics;
  end Predict;
  
  function Update (
   Filter : in out Kalman_Filter_Access;
    Actual_Measurement           : Measurement_Vector_Type;
    Measurement_Noise_Covariance : Measurement_Covariance_Type;
  ) return State_Statistics;
  is
    
    Propagated_Measurement_Points : Sigma_Measurements_Type;
    Measurement_Prediction : Measurement_Statistics;
    Kalman_Gain : Measurement_Covariance_Type;
  begin

    begin
      Filter.Sigma_Points := Update_Sigma_Points(
         Filter.Sigma_Points, 
         Filter.Current_Statistics, 
         Filter.Weight_Parameters.Alpha, 
         Filter.Weight_Parameters.Kappa
      );

       for Index in Filter.Sigma_Points'Range loop
          Set_Row (
            Index, 
            Propagated_Measurement_Points, 
            Filter.State_To_Measurement_Map (Get_Row (Index, Filter.Sigma_Points))
         );
       end loop;

       Measurement_Prediction := Predict_Statistics(
         Propagated_Measurement_Points, 
         Filter.Weights, 
         Measurement_Noise_Covariance
       );
       
       declare
         State_Measurement_Cross_Covariance : Cross_Covariance_Matrix := (others => (others => 0));
       begin
         for Index in Sigma_Points'Range loop
           State_Measurement_Cross_Covariance := State_Measurement_Cross_Covariance +
                                                 Filter.Weights.Covariance (Index) *
                                                 To_Column_Vector (Get_Row(Index, Filter.Sigma_Points) - Filter.Current_Statistics.Mean) *
                                                 To_Row_Vector (
                                                   Propagated_Measurement_Points (Index) - Measurement_Prediction.Mean
                                                 ) +
                                                 Measurement_Noise_Covariance;
         end loop;
         Kalman_Gain := State_Measurement_Cross_Covariance * Inverse (Measurement_Prediction.Covariance);
       end;
    
    Filter.Current_Statistics := (Mean => Previous_Prediction.Mean + 
                    Kalman_Gain * (Actual_Measurement - Measurement_Prediction.Mean),
            Covariance => Previous_Prediction.Covariance - 
                          Kalman_Gain * 
                          Measurement_Prediction.Covariance * 
                          Transpose (Kalman_Gain));
  end Update;

  
  function Get_Weights (Alpha, Beta, Kappa : T) return Sigma_Point_Weights
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
  
  function Update_Sigma_Points (
    Sigma_Points   : Sigma_Points_Type;
    State_Estimate : State_Statistics;
    Alpha : T;
    Kappa : T
  ) return Sigma_Points_Type
  is
     Updated_Sigma_Points : Sigma_Points_Type;
     Start_Row_Index : Integer := Sigma_Points'First;
     End_Row_Index : Integer := Sigma_Points'Last;
     Number_Rows : Integer := Sigma_Points'Length;
     Middle_Index : Integer :=  (Start_Row_Index + End_Row_Index) / Number_Rows;

     Decomposed_Covariance : Real_Matrix (State_Estimate.Covariance'Range(1), State_Estimate.Covariance'Range(2));
  begin
     Decomposed_Covariance := Cholesky_Decomposition (State_Estimate.Covariance);
     for Row_Index in Sigma_Points'Range loop
        declare
           Absolute_State_Bias : State := Alpha * Math.Sqrt (Kappa) * Get_Row (Row_Index, Decomposed_Covariance);
        begin
           if Row_Index <= Middle_Index then
              Set_Row (Row_Index, Updated_Sigma_Points, State_Estimate.Mean + Absolute_State_Bias);
           else
              Set_Row (Row_Index, Updated_Sigma_Points, State_Estimate.Mean - Absolute_State_Bias);
         end;
      end loop;
      return Updated_Sigma_Points;
  end;
  
  function Kalman_Filter (
   Initial_State : State_Vector_Type;
   Initial_Covariance : State_Covariance_Type;
   State_Transition : Transition_Function;
   Measurement_Transformation : Measurement_Function;
   Weight_Parameters : Sigma_Weight_Parameters;
   Num_Sigma_Points : Positive
  ) return Kalman_Filter_Access
  is
     Filter : Kalman_Filter_Access;
  begin
     Filter := new Kalman_Filter_Type (Num_Sigma_Points);
     Filter.Current_Statistics := (
      Mean => Real_Vector (Initial_State), 
      Covariance => Real_Matrix (Initial_Covariance)
      );
     Filter.State_Transition := State_Transition;
     Filter.Measurement_Transformation := Measurement_Transformation;
     Filter.Weight_Parameters := Weight_Parameters;
     Filter.Weights := Get_Weights (
      Weight_Parameters.Alpha, 
      Weight_Parameters.Beta, 
      Weight_Parameters.Kappa
   );
     return Filter;
  end Kalman_Filter;
  
end Unscented_Kalman;