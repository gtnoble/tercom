with Ada.Numerics.Generic_Real_Arrays;

package body Unscented_Kalman is
   pragma Assertion_Policy (Check);

   function Predict
     (Filter                      : in out Kalman_Filter_Type;
      Transition_Noise_Covariance :        State_Covariance_Type)
      return State_Statistics_Type
   is
      use Data_Points;
      use Data_Statistics;

      Current_Sigma_Points    : State_Points_Type := Filter.Sigma_Points;
      Propagated_Sigma_Points : State_Points_Type := Data_Points.Make_Points (First (Current_Sigma_Points), Last (Current_Sigma_Points));

      function Mean_Weight (Index : Sigma_Point_Index_Type) return Float_Type
      is
      begin
         return
           Mean_Weight_Function
             (Index => Index, Weight_Parameters => Filter.Weight_Parameters,
              Sigma_Points_Index_Start => First (Filter.Sigma_Points),
              Sigma_Points_Index_End   => Last (Filter.Sigma_Points));
      end Mean_Weight;

      function Covariance_Weight
        (Index : Sigma_Point_Index_Type) return Float_Type
      is
      begin
         return
           Covariance_Weight_Function
             (Index => Index, Weight_Parameters => Filter.Weight_Parameters,
              Sigma_Points_Index_Start => First (Filter.Sigma_Points),
              Sigma_Points_Index_End   => Last (Filter.Sigma_Points));
      end Covariance_Weight;

   begin
      for Index in First (Current_Sigma_Points) .. Last (Current_Sigma_Points)
      loop
         Set
           (Propagated_Sigma_Points, Index,
            Filter.State_Transition (Get (Current_Sigma_Points, Index)));
      end loop;

      Filter.Current_Statistics :=
        Predict_Statistics
          (Propagated_Sigma_Points, Mean_Weight'Access,
           Covariance_Weight'Access, Transition_Noise_Covariance);
      return Filter.Current_Statistics;
   end Predict;

   function Update
     (Filter                       : in out Kalman_Filter_Type;
      Actual_Measurement           :        Measurement_Point_Type;
      Measurement_Noise_Covariance :        Measurement_Covariance_Type)
      return State_Statistics_Type
   is
      use Data_Points;
      use Data_Point;
      use Data_Statistics;
      use Matrix;

      subtype Measurement_Statistics_Type is Data_Statistics.Statistics_Type;

      Propagated_Measurement_Points : Measurement_Points_Type;
      Measurement_Prediction        : Measurement_Statistics_Type;
      Kalman_Gain                   :
        Kalman_Gain_Type (Actual_Measurement'Range, Actual_Measurement'Range);
      function Mean_Weight (Index : Sigma_Point_Index_Type) return Float_Type
      is
      begin
         return
           Mean_Weight_Function
             (Index => Index, Weight_Parameters => Filter.Weight_Parameters,
              Sigma_Points_Index_Start => First (Filter.Sigma_Points),
              Sigma_Points_Index_End   => Last (Filter.Sigma_Points));
      end Mean_Weight;

      function Covariance_Weight
        (Index : Sigma_Point_Index_Type) return Float_Type
      is
      begin
         return
           Covariance_Weight_Function
             (Index => Index, Weight_Parameters => Filter.Weight_Parameters,
              Sigma_Points_Index_Start => First (Filter.Sigma_Points),
              Sigma_Points_Index_End   => Last (Filter.Sigma_Points));
      end Covariance_Weight;
   begin
      Update_Sigma_Points
        (Filter.Sigma_Points, Filter.Current_Statistics, Mean_Weight (0));

      for Index in First (Filter.Sigma_Points) .. Last (Filter.Sigma_Points)
      loop
         Set
           (Points => Propagated_Measurement_Points, Index => Index,
            Value  =>
              Filter.Measurement_Transformation
                (Get (Filter.Sigma_Points, Index)));
      end loop;

      Measurement_Prediction :=
        Predict_Statistics
          (Propagated_Measurement_Points, Mean_Weight'Access,
           Covariance_Weight'Access, Measurement_Noise_Covariance);

      declare
         First_Sigma_Point : State_Point_Type := Get 
            (Filter.Sigma_Points, First (Filter.Sigma_Points));
         State_Measurement_Cross_Covariance :
           Cross_Covariance_Type (First_Sigma_Point'Range, First_Sigma_Point'Range) :=
            (others => (others => 0.0));
      begin
         for Index in First (Filter.Sigma_Points) .. Last (Filter.Sigma_Points)
         loop
            State_Measurement_Cross_Covariance :=
              State_Measurement_Cross_Covariance +
              Covariance_Weight (Index) *
                Calculate_Cross_Covariance
                  (Get (Filter.Sigma_Points, Index) -
                   Mean (Filter.Current_Statistics),
                   Get (Propagated_Measurement_Points, Index) -
                   Mean (Measurement_Prediction));
         end loop;
         Kalman_Gain :=
           State_Measurement_Cross_Covariance *
           Inverse (Covariance (Measurement_Prediction));
      end;

      Filter.Current_Statistics :=
        Make_Statistics
          (Mean       =>
             Mean (Filter.Current_Statistics) +
             Kalman_Gain *
               (Actual_Measurement - Mean (Measurement_Prediction)),
           Covariance =>
             Covariance (Filter.Current_Statistics) -
             Kalman_Gain * Covariance (Measurement_Prediction) *
               Transpose (Kalman_Gain));
      return Filter.Current_Statistics;
   end Update;

   procedure Update_Sigma_Points
     (Sigma_Points   : in out State_Points_Type;
      State_Estimate :    State_Statistics_Type; Center_Weight : Float_Type)
   is
      use Data_Point;
      use Data_Points;
      use Data_Statistics;
      use Matrix;

      package Matrix_Ops is new Matrix_Operations (Matrix);

      Start_Sigma_Point_Index : Integer := First (Sigma_Points);
      End_Sigma_Point_Index   : Integer := Last (Sigma_Points);
      pragma Assert (-Start_Sigma_Point_Index = End_Sigma_Point_Index);

      Decomposed_Covariance : Points_Type;
   begin
      Decomposed_Covariance :=
        Matrix_To_Points
             (Matrix_Ops.Cholesky_Decomposition
                (Covariance (State_Estimate)));
      for Sigma_Point_Index in Start_Sigma_Point_Index .. End_Sigma_Point_Index loop
         if Sigma_Point_Index = 0 then
            Set (Sigma_Points, Sigma_Point_Index, Mean (State_Estimate));
         else
            declare
               Absolute_State_Bias : Displacement_Type :=
                 Center_Weight *
                 Displacement_Type (Get 
                  (Decomposed_Covariance, 
                  (abs Sigma_Point_Index) - 1 + First (Decomposed_Covariance)));
            begin
               if Sigma_Point_Index < 0 then
                  Set
                    (Sigma_Points, Sigma_Point_Index,
                     Mean (State_Estimate) + Absolute_State_Bias);
               else
                  Set
                    (Sigma_Points, Sigma_Point_Index,
                     Mean (State_Estimate) - Absolute_State_Bias);
               end if;
            end;
         end if;
      end loop;
   end Update_Sigma_Points;

   function Make_Kalman_Filter
     (Initial_State              : State_Point_Type;
      Initial_Covariance         : State_Covariance_Type;
      State_Transition           : Transition_Function;
      Measurement_Transformation : Measurement_Function;
      Weight_Parameters : Sigma_Weight_Parameters)
      return Kalman_Filter_Type
   is
      use Data_Points;

      Sigma_Points_Index_Start : Integer := -Initial_State'Length;
      Sigma_Points_Index_End   : Integer := Initial_State'Length;

      Filter : Kalman_Filter_Type :=
        (Current_Statistics         =>
           Data_Statistics.Make_Statistics (Initial_State, Initial_Covariance),
         Sigma_Points               =>
           New_Points (
            Fill => Initial_State, 
            Points_Start_Index => Sigma_Points_Index_Start, 
            Points_End_Index => Sigma_Points_Index_End),
         State_Transition           => State_Transition,
         Measurement_Transformation => Measurement_Transformation,
         Weight_Parameters          => Weight_Parameters);
   begin
      Update_Sigma_Points
        (Center_Weight  =>
           Mean_Weight_Function
             (Index => 0, Weight_Parameters => Weight_Parameters,
              Sigma_Points_Index_Start => Sigma_Points_Index_Start,
              Sigma_Points_Index_End   => Sigma_Points_Index_End),
         Sigma_Points   => Filter.Sigma_Points,
         State_Estimate => Filter.Current_Statistics);
      return Filter;
   end Make_Kalman_Filter;

   function Mean_Weight_Function
     (Index                    : Sigma_Point_Index_Type;
      Weight_Parameters        : Sigma_Weight_Parameters;
      Sigma_Points_Index_Start : Sigma_Point_Index_Type;
      Sigma_Points_Index_End   : Sigma_Point_Index_Type) return Float_Type
   is
      L      : Float_Type :=
        Float_Type ((Sigma_Points_Index_End - Sigma_Points_Index_Start) / 2);
      Weight : Float_Type;
   begin
      if Index = 0 then
         Weight :=
           (Weight_Parameters.Alpha**2 * Weight_Parameters.Kappa - L) /
           (Weight_Parameters.Alpha**2 * Weight_Parameters.Kappa);
      else
         Weight :=
           1.0 / (2.0 * Weight_Parameters.Alpha**2 * Weight_Parameters.Kappa);
      end if;
      return Weight;
   end Mean_Weight_Function;

   function Covariance_Weight_Function
     (Index                    : Sigma_Point_Index_Type;
      Weight_Parameters        : Sigma_Weight_Parameters;
      Sigma_Points_Index_Start : Sigma_Point_Index_Type;
      Sigma_Points_Index_End   : Sigma_Point_Index_Type) return Float_Type
   is
      Weight      : Float_Type;
      Mean_Weight : Float_Type :=
        Mean_Weight_Function
          (Index => Index, Weight_Parameters => Weight_Parameters,
           Sigma_Points_Index_Start => Sigma_Points_Index_Start,
           Sigma_Points_Index_End   => Sigma_Points_Index_End);
   begin
      if Index = 0 then
         Weight :=
           Mean_Weight + 1.0 - Weight_Parameters.Alpha**2 +
           Weight_Parameters.Beta;
      else
         Weight := Mean_Weight;
      end if;
      return Weight;
   end Covariance_Weight_Function;
   
   function Mean (Statistics: State_Statistics_Type) return State_Point_Type is
   begin
      return Data_Statistics.Mean (Statistics => Statistics);
   end Mean;
   
   function Covariance (Statistics : State_Statistics_Type) return State_Covariance_Type is
   begin
      return Data_Statistics.Covariance (Statistics => Statistics);
   end Covariance;

end Unscented_Kalman;
