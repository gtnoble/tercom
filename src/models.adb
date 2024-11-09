package body Models is
  
  function "-" (x : Atmospheric_Temperature_Kelvin; y : Atmospheric_Temperature_Kelvin) return Temperature_Change_Kelvin
  is
  begin
    return Temperature_Change_Kelvin (Precise_Float (x) - Precise_Float (y));
  end "-";
  

  function Modeled_Temperature_Likelihood (
    Estimated_Temperature, Previous_Temperature : Atmospheric_Temperature;
    Step_Time_Interval : Seconds
  ) return Probability
  is
    Distribution : Gaussian_Distribution;
    Standard_Deviation : constant := Max_Temperature_Change_Rate * 6;
  begin
    Distribution := (
      Precise_Float (Previous_Temperature), 
      Precise_Float (Standard_Deviation)
    );
    return Probability_Density(Estimated_Temperature, Distribution);
  end Modeled_Temperature_Likelihood;
  
  function Modeled_Compass_Offset_Likelihood (
    Estimated_Compass_Offset, 
    Previous_Orientation, 
    Compass_Observation : Position.Orientation
  ) return Probability
  is
    Model_Distribution : Gaussian_Distribution;
    Observation_Distribuition : Gaussian_Distribution;
  begin
    Model_Distribution := (Previous_Orientation,
                           Compass_Offset_Model_Error_Standard_Deviation);
    Observation_Distribuition := (Compass_Observation,
                                  Compass_Observation_Measurement_Error_Standard_Deviation);
    return 
      Probability_Density (Estimated_Compass_Offset, Model_Distribution) *
      Probability_Density (Estimated_Compass_Offset, Observation_Distribuition);
  end Modeled_Compass_Offset_Likelihood;
  
end Models;