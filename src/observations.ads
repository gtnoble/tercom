with Position;
with Models;
with Kinematics;
with Ada.Numerics.Generic_Real_Arrays;

package Observations is
  type Measurement is digits 6;

  -- Pascal, from space pressure (~= 0) to twice standard sea-level pressure;
  type Pressure is new Measurement range 0 .. 101365 * 2;

  --  Meters per second, limits exceed 100 G in both directions
  package Kinematics is new Generic_Kinematics (Float);
  package Observation_Vectors is new Ada.Numerics.Generic_Real_Arrays (Float);
  
  type Measurement_Index is range 1..11;
  type Measurement_Vector is new Observation_Vectors.Real_Vector (
    Measurement_Index
  );
  type Measurement_Covariance_Matrix is new Observation_Vectors.Real_Matrix (
    Measurement_Index, 
    Measurement_Index
  );

  type Barometer_Reading is new Pressure;
  
  type Observation is record
    Accelerometer : Kinematics.Acceleration;
    Magnetometer  : Kinematics.Direction;
    Barometer     : Barometer_Reading;
    Rate_Gyro     : Kinematics.Rotation_Rate;
    DEM           : Position.Altitude;
  end record;
  
  function Measurement_Function (
    Measurement_Vector : Measurement_Vector
  ) return Models.State_Vector;
  
  function Measurement_Noise_Covariance (
    Measurement_Vector : Measurement_Vector
  ) return Measurement_Covariance_Matrix;

  function From_Measurement_Vector (
    Vector : Measurement_Vector
  ) return Observation;
  
  function To_Measurement_Vector (
    Observation : Observation
  ) return Measurement_Vector;
  
private

  function Barometric_Measurement_Function (
    Elevation : Position.Altitude
  ) return Sensors.Pressure;
  
  function Magnetometer_Measurement_Function (
    IMU_Orientation : Kinematics.Rotation
  ) return Kinematics.Direction;
  
  function Accelerometer_Measurement_Function (
    IMU_Orientation : Kinematics.Rotation;
    Acceleration : Kinematics.Acceleration
  ) return Kinematics.Acceleration;
  
  function Rate_Gyro_Measurement_Function (
    Orientation_Rate : Kinemats.Rotation_Rate
  ) return Kinematics.Rotation_Rate;
  
  function DEM_Measurement_Function (
    Position : Position.Geographic_Location
  ) return Position.Geographic_Coordinates;
  
end Sensors;