with Models;
with Observations;
with Digital_Elevation_Model;

generic
  type T is range <>;
package Particle_Filter is
  

  type Stats_Float is digits 6;
  package Cumulative_Statistics is new Statistics.Cumulative (Stats_Float, T);

  type Particle_States is array(T) of Models.Particle_State;
  type Probabilities is array (T) of Particle_Statistics.Probability;
  type Observations is array (T) of Observations.Observation;

  function Predict_Particles (
    States : Particle_States
  ) return Particle_States;
  
  function Weight_Particles (
    States               : Particle_States;
    Current_Observations : Observations
  ) return Probabilities;
  
  function Resample_Particles (
    States  : Models.Particle_States;
    Weights : Probabilities
  ) return Particle_States;
  
  function Estimate_System_State (
    States  : Models.Particle_States;
    Weights : Probabilities
  ) return Models.Particle_State;
  
private
end Particle_Filter;