package body Point.Statistics is

  function Predict_Statistics (
    Propagated_Points  : Points_Instance.Points_Type;
    Mean_Weights            : Weight_Function;
    Covariance_Weights : Weight_Function;
    Noise_Covariance   : Covariance_Type
  ) return Statistics_Type
  is
    Predicted_Mean       : Point_Type (
      Point_First_Index (Propagated_Points) .. Point_Last_Index (Propagated_Points)
      ) := (others => 0.0);
    Predicted_Covariance : Covariance_Type := Noise_Covariance;
  begin
    for Point_Index in First (Propagated_Points) .. Last (Propagated_Points) loop
      Predicted_Mean := Predicted_Mean + 
         Get (Propagated_Points, Point_Index) * Mean_Weights (Point_Index);
    end loop;

    for Point_Index in First (Propagated_Points) .. Last (Propagated_Points) loop
     Predicted_Covariance :=  Covariance_Weights (Point_Index) * 
                             Calculate_Autocovariance (
                              Get (Propagated_Points, Point_Index) - Predicted_Mean
                              );
    end loop;
    
    return Make_Statistics (Predicted_Mean, Predicted_Covariance);
  end;
  
  function Make_Statistics (
   Mean : Point_Type; 
   Covariance : Covariance_Type
   ) return Statistics_Type
   is
      Created_Statistics : Statistics_Type;
   begin
      Created_Statistics.Mean := To_Holder (Mean);
      Created_Statistics.Covariance := To_Holder (Covariance);
      return Created_Statistics;
   end Make_Statistics;

   function Mean (Statistics : Statistics_Type) return Point_Type
      is
      begin
         return Element (Statistics.Mean);
      end Mean;
      
   function Covariance (Statistics : Statistics_Type) return Covariance_Type
      is
      begin
         return Element (Statistics.Covariance);
      end Covariance;


end Point.Statistics;
     