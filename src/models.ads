with Math; use Math;
with Statistics; use Statistics;
with Position;
with Sensors;

package Models is
  package Model_Kinematics is new Generic_Kinematics (Precise_Float);
  
  Velocity_Component_Standard_Deviation        : constant Precise_Float := 1;
  Location_Component_Standard_Deviation        : constant Precise_Float := 0.1;
  IMU_Orientation_Component_Standard_Deviation : constant Precise_Float := 3;
  
  type Particle_State is record
    Location                : Position.Geographic_Location;
    Velocity                : Model_Kinematics.Velocity;
    IMU_Orientation         : Model_Kinematics.Rotation;
    IMU_Orientation_Rate    : Model_Kinematics.Rotation_Rate;
  end record;

  function Predict_Particle_State (
    Previous_State : Particle_State
  ) return Particle_State;
  
end Models;