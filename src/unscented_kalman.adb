package body Unscented_Kalman is
  
  function Predict (
   Filter : in out Kalman_Filter_Type;
   Transition_Noise_Covariance : State_Covariance_Type
  ) return State_Statistics_Type
  is
     use Data_Points;
     Current_Sigma_Points : State_Points_Type := Filter.Sigma_Points;
    Propagated_Sigma_Points : State_Points_Type;
   begin
    for Index in 
      First (Current_Sigma_Points) .. Last (Current_Sigma_Points)
   loop
      Set (
         Propagated_Sigma_Points, 
         Index, 
         Filter.State_Transition (
            Get (Current_Sigma_Points, Index))
         );
    end loop;
    
    Filter.Current_Statistics := Predict_Statistics (
      Propagated_Sigma_Points, 
      Filter.Mean_Weight,
      Filter.Covariance_Weight,
      Transition_Noise_Covariance
   );
   return Filter.Current_Statistics;
  end Predict;
  
  function Update (
   Filter : in out Kalman_Filter_Type;
    Actual_Measurement           : Measurement_Point_Type;
    Measurement_Noise_Covariance : Measurement_Covariance_Type
  ) return State_Statistics_Type
  is
     use Data_Points;
     use Data_Point;
    
    Propagated_Measurement_Points : Measurement_Points_Type;
    Measurement_Prediction : Measurement_Statistics_Type;
    Kalman_Gain : Kalman_Gain_Type (
      Actual_Measurement'Range, 
      Actual_Measurement'Range
   );
    begin
      Update_Sigma_Points(
         Filter.Sigma_Points, 
         Filter.Current_Statistics, 
         Filter.Mean_Weight (0)
      );

       for Index in First (Filter.Sigma_Points) .. Last (Filter.Sigma_Points) loop
          Set (
            Points =>Propagated_Measurement_Points,
             Index => Index,
             Value => Filter.Measurement_Transformation (
               Get (Filter.Sigma_Points, Index)
             ));
       end loop;

       Measurement_Prediction := Predict_Statistics(
         Propagated_Measurement_Points, 
         Filter.Mean_Weight,
         Filter.Covariance_Weight, 
         Measurement_Noise_Covariance
       );
       
       declare
         State_Measurement_Cross_Covariance : Cross_Covariance_Type(
            Point_First (Filter.Sigma_Points) .. Point_Last (Filter.Sigma_Points), 
            Point_First (Propagated_Measurement_Points) .. Point_Last (Propagated_Measurement_Points)
            ) := (others => (others => 0.0));
       begin
         for Index in 
            First (Filter.Sigma_Points) .. 
            Last (Filter.Sigma_Points)
         loop
           State_Measurement_Cross_Covariance := 
            State_Measurement_Cross_Covariance +
            Filter.Covariance_Weight (Index) *
            Calculate_Cross_Covariance (
               Get (Filter.Sigma_Points, Index) - Mean (Filter.Current_Statistics),
               Get (Propagated_Measurement_Points, Index) - Mean (Measurement_Prediction)
            );
         end loop;
         Kalman_Gain := State_Measurement_Cross_Covariance * Inverse (Covariance (Measurement_Prediction));
       end;
    
    Filter.Current_Statistics := Make_Statistics (
      Mean => Mean (Filter.Current_Statistics) + 
               Kalman_Gain * (Actual_Measurement - Mean (Measurement_Prediction)),
      Covariance => Covariance (Filter.Current_Statistics) - 
                     Kalman_Gain * 
                     Covariance (Measurement_Prediction) * 
                     Transpose (Kalman_Gain));
    return Filter.Current_Statistics;
  end Update;

  
  function Mean_Weight (
   Index : Sigma_Point_Index_Type;
   Alpha, Kappa : Float_Type) return Float_Type
   is
      L : Sigma_Point_Index_Type := (Index'Last - Index'First) / 2;
      Weight : Float_Type;
   begin
      if Index = 0 then
         Weight := (Alpha ** 2 * Kappa - L)  / (Alpha ** 2 * Kappa);
      else
         Weight := 1 / (2 * Alpha ** 2 * Kappa);
      end if;
      return Weight;
   end Mean_Weight;
   
   function Covariance_Weight (
      Index : Sigma_Point_Index_Type;
      Alpha, Beta, Kappa : Float_Type
   ) return Float_Type
   is
      Weight : Float_Type;
   begin
      if Index = 0 then
         Weight := 
            Mean_Weight (Index => Index, Alpha => Alpha, Kappa => Kappa) +
            1 - Alpha ** 2 + Beta;
      else
         Weight := Mean_Weight (Index => Index, Alpha => Alpha, Kappa => Kappa);
      end if;
      return Weight;
   end Covariance_Weight;
  
  procedure Update_Sigma_Points (
    Sigma_Points   : in out State_Points_Type;
    State_Estimate : State_Statistics_Type;
    Center_Weight : Float_Type
  )
  is
     use Data_Point;
     use Data_Points;

     Start_Row_Index : Integer := First (Sigma_Points);
     End_Row_Index : Integer := Last (Sigma_Points);
     Number_Rows : Natural := Natural (Num_Points (Sigma_Points));
     Middle_Index : Integer :=  (Start_Row_Index + End_Row_Index) / Number_Rows;

     Decomposed_Covariance : Covariance_Type (
      Covariance (State_Estimate)'Range(1), 
      Covariance (State_Estimate)'Range(2)
      );
  begin
     Decomposed_Covariance := Cholesky_Decomposition (State_Estimate.Covariance);
     for Row_Index in Start_Row_Index .. End_Row_Index loop
        declare
           Absolute_State_Bias : Displacement_Type := Center_Weight * Decomposed_Covariance (Row_Index);
        begin
           if Row_Index = 0 then
              Set (Sigma_Points, Row_Index, Mean (State_Estimate));
           elsif Row_Index < 0 then
              Set (Sigma_Points, Row_Index, Mean (State_Estimate) + Absolute_State_Bias);
           else
              Set (Sigma_Points, Row_Index, Mean (State_Estimate) - Absolute_State_Bias);
            end if;
         end;
      end loop;
  end Update_Sigma_Points;
  
  function Make_Kalman_Filter (
   Initial_State : State_Point_Type;
   Initial_Covariance : State_Covariance_Type;
   State_Transition : Transition_Function;
   Measurement_Transformation : Measurement_Function;
   Num_Sigma_Points : Positive;
   Weight_Parameters : Sigma_Weight_Parameters
  ) return Kalman_Filter_Type
  is
     use Data_Points;
     Sigma_Points_Index_Start : Integer := - Num_Sigma_Points / 2;
     Sigma_Points_Index_End : Integer := Num_Sigma_Points / 2;

     function Mean_Weight_Function (Index : Sigma_Point_Index_Type) return Float_Type
      is
      begin
         return Mean_Weight (
            Index => Index, 
            Alpha => Weight_Parameters.Alpha, 
            Kappa => Weight_Parameters.Kappa
         );
      end Mean_Weight_Function;
      
      function Covariance_Weight_Function (Index : Sigma_Point_Index_Type) return Float_Type
      is
      begin
         return Covariance_Weight (
            Index => Index, 
            Alpha => Weight_Parameters.Alpha, 
            Beta => Weight_Parameters.Beta, 
            Kappa => Weight_Parameters.Kappa);
      end Covariance_Weight_Function;

     Filter : Kalman_Filter_Type := (Current_Statistics =>
                                       Make_Statistics (Initial_State, Initial_Covariance),
                                     Sigma_Points =>
                                       New_Points (
                                          Sigma_Points_Index_Start, 
                                          Sigma_Points_Index_End
                                       ),
                                     State_Transition =>
                                       Transition_Function,
                                     Measurement_Transformation =>
                                       Measurement_Function,
                                    Mean_Weight => Mean_Weight_Function'Access, 
                                    Covariance_Weight => Covariance_Weight_Function'Access);
  begin
     Update_Sigma_Points (
      Sigma_Points => Filter.Sigma_Points, 
      State_Estimate => Filter.Current_Statistics, 
      Alpha => Filter.Weight_Parameters.Alpha,
      Kappa => Filter.Weight_Parameters.Kappa
      );
     return Filter;
  end Make_Kalman_Filter;
  
end Unscented_Kalman;