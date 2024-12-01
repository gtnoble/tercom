package body Point.Statistics is
   pragma Assertion_Policy (Check);

   function Predict_Statistics
     (Propagated_Points  : Points_Instance.Points_Type;
      Mean_Weights       : access function
        (Index : Points_Instance.Points_Index_Type) return Float_Type;
      Covariance_Weights : access function
        (Index : Points_Instance.Points_Index_Type) return Float_Type;
      Noise_Covariance   : Covariance_Type) return Statistics_Type
   is
      use Points_Instance;

      Predicted_Mean       :
        Point_Type
          (Point_First (Propagated_Points) ..
               Point_Last (Propagated_Points)) :=
        (others => 0.0);
      Predicted_Covariance : Covariance_Type := Noise_Covariance;
   begin
      for Point_Index in First (Propagated_Points) .. Last (Propagated_Points)
      loop
         Predicted_Mean :=
           Predicted_Mean +
           Get (Propagated_Points, Point_Index) * Mean_Weights (Point_Index);
      end loop;

      for Point_Index in First (Propagated_Points) .. Last (Propagated_Points)
      loop
         Predicted_Covariance :=
           Covariance_Weights (Point_Index) *
           Calculate_Autocovariance
             (Get (Propagated_Points, Point_Index) - Predicted_Mean);
      end loop;

      return Make_Statistics (Predicted_Mean, Predicted_Covariance);
   end Predict_Statistics;

   function Make_Statistics
     (Mean : Point_Type; Covariance : Covariance_Type) return Statistics_Type
   is
      pragma Assert (Mean'First = 1);
      pragma Assert (Covariance'First(1) = Mean'First);
      pragma Assert (Covariance'First(2) = Mean'First);
      pragma Assert (Covariance'Last(1) = Mean'Last);
      pragma Assert (Covariance'Last(2) = Mean'Last);


      Created_Statistics : Statistics_Type;
   begin
      Created_Statistics.Mean       := To_Holder (Mean);
      Created_Statistics.Covariance := To_Holder (Covariance);
      return Created_Statistics;
   end Make_Statistics;

   function Mean (Statistics : Statistics_Type) return Point_Type is
   begin
      return Element (Statistics.Mean);
   end Mean;

   function Covariance (Statistics : Statistics_Type) return Covariance_Type is
   begin
      return Element (Statistics.Covariance);
   end Covariance;

end Point.Statistics;
