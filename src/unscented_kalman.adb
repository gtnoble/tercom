package body Unscented_Kalman is
  
  function Predict (
   Filter : in out Kalman_Filter_Access;
   Transition_Noise_Covariance : State_Covariance_Type
  ) return State_Statistics
  is
    Propagated_Sigma_Points : Sigma_Points_Type;
   begin
    for Index in 
      Filter.Sigma_Points.First_Index .. Filter.Sigma_Points.Last_Index 
   loop
       Points_Vectors.Append (
         Propagated_Sigma_Points, 
         Filter.State_Transition (Filter.Sigma_Points (Index))
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
    
    Propagated_Measurement_Points : Measurement_Points_Type;
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

       for Index in Filter.Sigma_Points.First_Index .. Filter.Sigma_Points.Last_Index loop
          Points_Vectors.Append (
            Propagated_Measurement_Points, 
            Filter.Measurement_Transformation (
               Filter.Sigma_Points (Index)
            )
         );
       end loop;

       Measurement_Prediction := Predict_Statistics(
         Propagated_Measurement_Points, 
         Filter.Weights, 
         Measurement_Noise_Covariance
       );
       
       declare
         State_Measurement_Cross_Covariance : Cross_Covariance_Type(
            Filter.Sigma_Points.First_Element'Range, 
            Propagated_Measurement_Points.First_Element'Range
            ) := (others => (others => 0.0));
       begin
         for Index in 
            Filter.Sigma_Points.First_Index .. 
            Filter.Sigma_Points.Last_Index 
         loop
           State_Measurement_Cross_Covariance := 
            State_Measurement_Cross_Covariance +
            Filter.Weights.Covariance (Index) *
            Calculate_Cross_Covariance (
               Filter.Sigma_Points (Index) - Filter.Current_Statistics.Mean,
               Propagated_Measurement_Points (Index) - Measurement_Prediction.Mean
            );
         end loop;
         Kalman_Gain := State_Measurement_Cross_Covariance * Inverse (Measurement_Prediction.Covariance);
       end;
    
    Filter.Current_Statistics := (
      Point_Dimension => Filter.Sigma_Points.First_Element'Length,
      Mean => Filter.Current_Statistics.Mean + 
               Kalman_Gain * (Actual_Measurement - Measurement_Prediction.Mean),
      Covariance => Filter.Current_Statistics.Covariance - 
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
      Mean_Weights : Sigma_Point_Weight_Type (
         Resulting_Weights.Mean'Range
      ) := (others => (1.0 / (2.0 * Alpha ** 2 * Kappa)));
      Covariance_Weights : Sigma_Point_Weight_Type (
         Resulting_Weights.Covariance'Range
      ) := Mean_Weights;
      Center_Element_Index : Positive := (
         Resulting_Weights.Mean'First + Resulting_Weights.Mean'Last
      ) / 2;
    begin
      Mean_Weights (Mean_Weights'First) := (Alpha ** 2 * Kappa - T (Resulting_Weights.Mean'Length) / 2.0) / 
                                           (Alpha ** 2 * Kappa);
      Covariance_Weights (Covariance_Weights'First) := Mean_Weights (Mean_Weights'First) + 
                                                       1.0 - 
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
  ) return Statistics
  is
    Predicted_Mean       : Point_Type (
      Propagated_Points.First_Element'Range
      ) := (others => 0.0);
    Predicted_Covariance : Covariance_Type := Noise_Covariance;

    First_Point_Index : Integer := Propagated_Points.First_Index;
    Last_Point_Index : Integer := Propagated_Points.Last_Index;
  begin
    for Point_Index in First_Point_Index .. Last_Point_Index loop
      Predicted_Mean := Predicted_Mean + 
         Propagated_Points (Point_Index) * Weights.Mean (Point_Index);
    end loop;

    for Point_Index in First_Point_Index .. Last_Point_Index loop
     Predicted_Covariance :=  Weights.Covariance (Point_Index) * 
                             Calculate_Autocovariance (
                              Propagated_Points (Point_Index) - Predicted_Mean
                              );
    end loop;

    return (
       Point_Dimension => Predicted_Mean'Length,
      Mean => Predicted_Mean, 
      Covariance => Predicted_Covariance);
  end;
  
  procedure Update_Sigma_Points (
    Sigma_Points   : in out Sigma_Points_Type;
    State_Estimate : State_Statistics;
    Alpha : T;
    Kappa : T
  ) return Sigma_Points_Type
  is
     Start_Row_Index : Integer := Sigma_Points.First_Index;
     End_Row_Index : Integer := Sigma_Points.Last_Index;
     Number_Rows : Natural := Natural (Sigma_Points.Length);
     Middle_Index : Integer :=  (Start_Row_Index + End_Row_Index) / Number_Rows;

     Decomposed_Covariance : Real_Matrix (State_Estimate.Covariance'Range(1), State_Estimate.Covariance'Range(2));
  begin
     Decomposed_Covariance := Cholesky_Decomposition (State_Estimate.Covariance);
     for Row_Index in Start_Row_Index .. End_Row_Index loop
        declare
           Absolute_State_Bias : State_Point_Type := Alpha * Math.Sqrt (Kappa) * Decomposed_Covariance (Row_Index);
        begin
           if Row_Index <= Middle_Index then
              Sigma_Points (Row_Index) := State_Estimate.Mean + Absolute_State_Bias;
           else
              Sigma_Points (Row_Index) := State_Estimate.Mean - Absolute_State_Bias;
            end if;
         end;
      end loop;
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