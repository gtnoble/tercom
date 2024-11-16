with Math; use Math;
with Statistics; use Statistics;
with Position;
with Sensors;
with Ada.Numerics.Generic_Real_Arrays;

package Models is
  package Model_Kinematics is new Generic_Kinematics (Precise_Float);

  package Observation_Vectors is new Ada.Numerics.Generic_Real_Arrays (Float);
  type State_Index is range 1 .. 12;
  type State_Vector is new Observation_Vectors.Real_Vector (State_Index);
  type State_Covariance is new Observation_Vectors.Real_Matrix (
    State_Index, 
    State_Index
  );
  
  type Particle_State is record
    Location                : Position.Geographic_Location;
    Velocity                : Model_Kinematics.Velocity;
    IMU_Orientation         : Model_Kinematics.Rotation;
    IMU_Orientation_Rate    : Model_Kinematics.Rotation_Rate;
  end record;
  
  function To_State_Vector (
    State : Particle_State
  ) return State_Vector;

  function From_State_Vector (
    State : State_Vector
  ) return Particle_State;
  
  function State_Transition_Function (
    Current_State : State_Vector
  ) return State_Vector;
  
  function Transition_Noise_Covariance (
    Current_State : State_Vector
  ) return State_Covariance;
  
end Models;