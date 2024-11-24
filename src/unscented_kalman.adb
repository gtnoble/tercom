package body Unscented_Kalman is
  
  function Predict (
   Filter : in out Kalman_Filter_Access;
   Transition_Noise_Covariance : State_Covariance_Type
  ) return State_Statistics
  is
    Propagated_Sigma_Points : Sigma_Points_Type (
      Filter.Sigma_Points'Range(1),
      Filter.Sigma_Points'Range(2)
      );
   begin
    for Index in Filter.Sigma_Points'Range loop
       Propagated_Sigma_Points (Index) := Filter.State_Transition (
         Filter.Sigma_Points (Index)
      );
    end loop;
    
    Filter.Current_Statistics := Predict_Statistics (
      Propagated_Sigma_Points, 
      Filter.Weights,
      Real_Matrix (Transition_Noise_Covariance)
   );
   return Filter.Current_Statistics;
  end Predict;
  
  function Update (
   Filter : in out Kalman_Filter_Access;
    Actual_Measurement           : Measurement_Point_Type;
    Measurement_Noise_Covariance : Measurement_Covariance_Type
  ) return State_Statistics
  is
    
    Propagated_Measurement_Points : Sigma_Measurements_Type (
      Filter.Sigma_Points'Range, 
      Actual_Measurement'Range
   );
    Measurement_Prediction : Measurement_Statistics (Actual_Measurement'Length);
    Kalman_Gain : Kalman_Gain_Type (
      Actual_Measurement'Range, 
      Actual_Measurement'Range
   );
    begin
      Filter.Sigma_Points := Update_Sigma_Points(
         Filter.Sigma_Points, 
         Filter.Current_Statistics, 
         Filter.Weight_Parameters.Alpha, 
         Filter.Weight_Parameters.Kappa
      );

       for Index in Filter.Sigma_Points'Range loop
          Propagated_Measurement_Points (Index) :=
            Filter.Measurement_Transformation (
               Filter.Sigma_Points (Index)
            );
       end loop;

       Measurement_Prediction := Predict_Statistics(
         Propagated_Measurement_Points, 
         Filter.Weights, 
         Measurement_Noise_Covariance
       );
       
       declare
         State_Measurement_Cross_Covariance : Cross_Covariance_Type := (others => (others => 0));
       begin
         for Index in Filter.Sigma_Points'Range loop
           State_Measurement_Cross_Covariance := State_Measurement_Cross_Covariance +
                                                 Filter.Weights.Covariance (Index) *
                                                 Calculate_Cross_Covariance (
                                                   Filter.Sigma_Points (Index) - Filter.Current_Statistics.Mean,
                                                   Propagated_Measurement_Points (Index) - Measurement_Prediction.Mean
                                                   );
         end loop;
         Kalman_Gain := State_Measurement_Cross_Covariance * Inverse (Measurement_Prediction.Covariance);
       end;
    
    Filter.Current_Statistics := (Mean => Previous_Prediction.Mean + 
                    Kalman_Gain * (Actual_Measurement - Measurement_Prediction.Mean),
            Covariance => Previous_Prediction.Covariance - 
                          Kalman_Gain * 
                          Measurement_Prediction.Covariance * 
                          Transpose (Kalman_Gain));
    return Filter.Current_Statistics;
  end Update;

  
  function Get_Weights (
   Alpha, Beta, Kappa : T; 
   Num_Sigma_Points : Positive
   ) return Sigma_Point_Weights
  is
    Resulting_Weights : Sigma_Point_Weights (Num_Sigma_Points);
  begin
    declare
      Mean_Weights : Sigma_Point_Weight_Type := (others => (1 / (2 * Alpha ** 2 * Kappa)));
      Covariance_Weights : Sigma_Point_Weight_Type := Mean_Weights;
      Center_Element_Index : Positive := (Resulting_Weights'First + Resulting_Weights'Last) / 2;
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
    Propagated_Points  : Points_Type;
    Weights            : Sigma_Point_Weights;
    Noise_Covariance   : Covariance_Type
  ) return Prediction_Type
  is
   subtype Data_Vector_Range is Propagated_Points'Range(2);
   subtype Point_Type is Real_Vector (Data_Vector_Range);
   subtype Covariance_Type is Real_Matrix (Data_Vector_Range, Data_Vector_Range);

    Predicted_Mean       : Point_Type := (others => 0.0);
    Predicted_Covariance : Covariance_Type := Noise_Covariance;
  begin
    for Point_Index in Propagated_Points'Range loop
      Predicted_Mean := Predicted_Mean + Propagated_Points (Point_Index) * Weights.Mean (Point_Index);
    end loop;

    for Point_Index in Propagated_Points'Range loop
     Predicted_Covariance := (Propagated_Points (Point_Index) - Predicted_Mean) + 
                             Weights.Covariance (Point_Index) * 
                             Calculate_Autocovariance (Estimate_Difference)
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
              Updated_Sigma_Points (Row_Index) := State_Estimate.Mean + Absolute_State_Bias;
           else
              Updated_Sigma_Points (Row_Index) := State_Estimate.Mean - Absolute_State_Bias;
            end if;
         end;
      end loop;
      return Updated_Sigma_Points;
  end;
  
  function Kalman_Filter (
   Initial_State : State_Point_Type;
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
  
  function Calculate_Cross_Covariance (X, Y : Point_Type) return Covariance_Type
   is
      Row_Matrix : Matrix_Type (X'Range, 1);
      Column_Matrix : Matrix_Type (1, Y'Range);
   begin
      for Row in X'Range loop
         Row_Matrix (Row, 1) := X (Row);
      end loop;

      for Column in Y'Range loop
         Column_Matrix (1, Column) := Y (Column);
      end loop;
      
      return Row_Matrix * Column_Matrix;
   end Calculate_Cross_Covariance;
   
   function Calculate_Autocovariance (X : Point_Type) return Covariance_Type
      is
      begin
         return Calculate_Cross_Covariance (X, X);
      end Calculate_Autocovariance;
  
end Unscented_Kalman;