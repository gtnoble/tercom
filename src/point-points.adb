package body Statistics.Point is

  function Predict_Statistics (
    Propagated_Points  : Points_Type;
    Mean_Weights            : Weights_Type;
    Covariance_Weights : Weights_Type;
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
  
  function New_Points (
     Fill : Point_Type;
      Points_Start_Index, Points_End_Index : Points_Index_Type
   ) return Points_Type
     is
        Created_Points : Points_Type;
        Points_Array : Points_Array_Type (Points_Start_Index .. Points_End_Index) := (
         others => To_Holder (Fill)
         );
     begin
        Created_Points.Point_Start_Index := Fill.First;
        Created_Points.Point_End_Index := Fill.Last;
        Created_Points.Points := To_Holder (Points_Array);
        return Created_Points;
     end New_Points;
  
    function First (Points : Points_Type) return Integer
    is
       begin
          return Points.Points.Reference.all'First;
       end First;
       
       function Last (Points : Points_Type) return Integer
          is
          begin
          return Points.Points.Reference.all'Last;
          end Last;
   
   function Get (Points : Points_Type; Index : Positive) return Point_Type
      is
      begin
         return Points.Points.Reference.all (Index).Reference.all;
      end Get;
   
   procedure Set (Points : in out Points_Type; Index : Positive; Value : Point_Type)
      is
      begin
         Points.Points.Reference.all (Index).Reference.all := Value;
      end Set;

          function Point_First (Points : Points_Type) return Positive
             is
             begin
             return Points.Point_Start_Index;
             end Point_First;

          function Point_Last (Points : Points_Type) return Positive
             is
             begin
             return Points.Point_End_Index;
             end Point_Last;
             
   function Num_Points (Points : Points_Type)
   is
   begin
      return Points.Points.Reference.all'Length;
   end Num_Points;
             
   function Point_Dimension (Points : Points_Type) return Positive
      is
      begin
         return Points.Point_End_Index - Points.Point_Start_Index + 1;
      end Point_Dimension;
             
   function Mean (Statistics : Statistics_Type) return Point_Type
      is
      begin
         return Statistics.Mean.all;
      end Mean;
      
   function Covariance (Statistics : Statistics_Type) return Covariance_Type
      is
      begin
         return Statistics.Covariance.all;
      end Covariance;

  function Make_Statistics (
   Mean : Point_Type; 
   Covariance : Covariance_Type
   ) return Statistics_Type
   is
      Created_Statistics : Statistics_Type;
   begin
      Created_Statistics.Mean.Reference.all := Mean;
      Created_Statistics.Covariance.Reference.all := Covariance;
      return Created_Statistics;
   end Make_Statistics;
     
  
end Statistics.Point;