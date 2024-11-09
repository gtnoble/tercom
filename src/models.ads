with Math; use Math;
with Statistics; use Statistics;
with Position;
with Sensors;

package Models is
  --  Kelvin, limits exceed earth measurement records
  type Temperature is new Precise_Float range 100 .. 300;
  type Seconds is new Precise_Float;
  
  package Model_Rotation is new Rotation (Precise_Float);
  
  -- Logistic step length model parameters
  type Step_Length_Model is record
    Flat_Terrain_Step_Length : Position.Step_Distance;
    Critical_Grade :  Degrees range -90 .. 90;
    Critical_Slope_Scale : Precise_Float;
  end record;
  
  type Particle_State is record
    Location : Position.Geographic_Location;
    Heading : Position.Heading;
    Atmospheric_Temperature : Temperature;
    IMU_Orientation : Model_Rotation.Rotation_3D;
    Step_Length_Model : Step_Length_Model;
    Horizontal_Step_Distance : Position.Step_Distance;
    Unix_Time : Seconds;
  end record;

  type Particle_States is array (Natural range <>) of Models.Particle_State;

  procedure Update_States (
    States : in out Particle_States; 
    Current_Sensor_Readings : Sensors.Sensor_Readings
  );
  
  function Estimate_System_State (
    States : Particle_States
  ) return Models.Particle_State;
  
  function State_Likelihood 
    (
      Estimated_State : Particle_State; 
      Previous_State : Particle_State; 
      Current_Sensor_Readings : Sensors.Sensor_Readings
    ) return Probability;
  
  function Location_Likelihood
    (
      Estimated_Location : Position.Geographic_Location;
      Dem_Altitude : Position.Altitude;
      Measured_Barometric_Pressure : Sensors.Pressure;
      Previous_Location : Position.Geographic_Location;
      Previous_Orientation : Position.Orientation;
      Previous_Horizontal_Step_Distance : Position.Step_Distance;
      Previous_Atmospheric_Temperature : Temperature
    ) return Probability;
  
  Max_Single_Day_Temperature_Variation : constant := 56.7;
  Seconds_Per_Day : constant := 60 * 60 * 24;
  Max_Temperature_Change_Rate : constant := 
    Max_Single_Day_Temperature_Variation / (Seconds_Per_Day / 2);

  function Temperature_Likelihood 
    (
      Estimated_Temperature, Previous_Temperature : Atmospheric_Temperature;
      Step_Time_Interval : Seconds
    ) return Probability;

  Compass_Observation_Measurement_Error_Standard_Deviation : constant Degrees := 1;
  Compass_Offset_Model_Error_Standard_Deviation : constant Degrees := 0.01;

  function IMU_Orientation_Likelihood
    (
      Estimated_Orientation : Model_Rotation.Rotation_3D;
      Previous_Orientation : Model_Rotation.Rotation_3D; 
      Compass_Observation : Sensors.Magnetometer_Reading;
      Accelerometer_Observation : Sensors.Accelerometer_Reading
    ) return Probability;
  
  Heading_Model_Error_Standard_Deviation : constant Degrees := 30;
  function Heading_Likelihood 
    (
      Estimated_Heading : Position.Heading; 
      Previous_Heading : Position.Heading;
      Compass_Observation : Sensors.Magnetometer_Reading;
      Previous_IMU_Orientation : Model_Rotation.Rotation_3D
    ) return Probability;
    
  function Horizontal_Step_Distance_Likelihood
    (
      Estimated_Step_Distance : Position.Step_Distance;
      Previous_Step_Length_Model : Step_Length_Model;
      Previous_Orientation : Position.Orientation
    ) return Probability;
    
  function Step_Length_Model_Likelihood
    (
      Estimated_Step_Length_Model : Step_Length_Model;
      Previous_Step_Length_Model : Step_Length_Model
    ) return Probability;
    
end Models;