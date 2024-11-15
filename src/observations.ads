with Position;
with Models;
with Kinematics;

package Observations is
  type Measurement is digits 6;

  -- Pascal, from space pressure (~= 0) to twice standard sea-level pressure;
  type Pressure is new Measurement range 0 .. 101365 * 2;

  --  Meters per second, limits exceed 100 G in both directions
  package Kinematics is new Generic_Kinematics (Float);

  type Barometer_Reading is new Pressure;
  
  type Observation is record
    Accelerometer : Kinematics.Acceleration;
    Magnetometer  : Kinematics.Direction;
    Barometer     : Barometer_Reading;
    Rate_Gyro     : Kinematics.Rotation_Rate;
    DEM           : Position.Altitude;
  end record;
  
  function Observation_Likelihood (
    Observation : Observation;
    State       : Models.Particle_State
  ) return Probability;

private

  function Barometric_Observation_Likelihood (
    Barometric_Pressure_Measurement   : Sensors.Pressure;
    Estimated_Elevation               : Position.Altitude
  ) return Probability;
  
  function Magnetometer_Observation_Likelihood (
    Magnetometer_Measurement  : Kinematics.Direction;
    Estimated_IMU_Orientation : Kinematics.Rotation
  ) return Probability;
  
  function Accelerometer_Observation_Likelihood (
    Accelerometer_Measurement : Kinematics.Acceleration;
    Estimated_IMU_Orientation : Kinematics.Rotation;
    Estimated_Velocity        : Kinematics.Velocity
  ) return Probability;
  
  function Rate_Gyro_Observation_Likelihood (
    Rate_Gyro_Measurement : Kinematics.Rotation_Rate;
    Estimated_Orientation_Rate : Kinematics.Rotation_Rate
  ) return Probability;
  
  function DEM_Observation_Likelihood (
    DEM_Elevation_Observation : Position.Altitude;
    Estimated_Elevation       : Position.Altitude
  ) return Probability;
  
end Sensors;