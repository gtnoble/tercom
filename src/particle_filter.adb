package body Particle_Filter is
  function Predict_Particles (Particles : Particle_States) return Particle_States
  is
    Predicted_Particles : Particle_States;
  begin
    for Particle of Particles loop
      Predicted_Particles := 
        Models.Predict_Particle_State (Previous_State => Particle);
    end loop;
    return Predicted_Particles;
  end Predict_Particles;
  
  function Weight_Particles (
    Particles            : Particle_States; 
    Current_Observations : Observations
  ) return Probabilities
  is
    Weights : Probabilities;
  begin
    for Index in T loop
      Weights (Index) := Observations.Observation_Likelihood (
        Observation => Current_Observations (Index),
        State       => Particles (Index)
      );
    end loop;
    return Weights;
  end Weight_Particles;
  
  function Resample_Particles (
    Particles  : Particle_States;
    Weights    : Probabilities
  )
  is
    Resampled_Particles : Particle_States;
  begin
    declare
      Probability_Mass_Function : Cumulative_Statistics.Probability_Mass := 
        Cumulative_Statistics.Normalize_PMF (Weights);
      Cumulative_Distribution   : Cumulative_Statistics.Cumulative_Distribution := 
        Cumulative_Statistics.PMF_To_CDF;
    begin
      for Index in T loop
        Resampled_Particles (Index) := 
          Particles (Cumulative_Statistics.Sample_CDF (Cumulative_Distribution));
      end loop;
    end;
    return Resampled_Particles;
  end Resample_Particles;
  
end Particle_Filter;