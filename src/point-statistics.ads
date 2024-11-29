with Point;
with Point.Points;

generic
   with package Points_Instance is new Point.Points (<>);
package Point.Statistics is

   type Statistics_Type is private;

   function Mean (Statistics : Statistics_Type) return Point_Type;
   function Covariance (Statistics : Statistics_Type) return Covariance_Type;

   function Predict_Statistics
     (Propagated_Points  : Points_Instance.Points_Type;
      Mean_Weights       : access function
        (Index : Points_Instance.Points_Index_Type) return Float_Type;
      Covariance_Weights : access function
        (Index : Points_Instance.Points_Index_Type) return Float_Type;
      Noise_Covariance   : Covariance_Type) return Statistics_Type;

   function Make_Statistics
     (Mean : Point_Type; Covariance : Covariance_Type) return Statistics_Type;
private

   package Covariance_Holders is new Ada.Containers.Indefinite_Holders
     (Covariance_Type);
   use Covariance_Holders;
   subtype Covariance_Holder_Type is Covariance_Holders.Holder;

   package Point_Holders is new Ada.Containers.Indefinite_Holders (Point_Type);
   use Point_Holders;
   subtype Point_Holder_Type is Point_Holders.Holder;

   type Statistics_Type is record
      Mean       : Point_Holder_Type;
      Covariance : Covariance_Holder_Type;
   end record;

end Point.Statistics;
