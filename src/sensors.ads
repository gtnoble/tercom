package Sensors is
  type Measurement is digits 6;

  -- Pascal, from space pressure (~= 0) to twice standard sea-level pressure;
  type Pressure is new Measurement range 0 .. 101365 * 2;

  --  Meters per second, limits exceed 100 G in both directions
  type Acceleration is new Measurement  range -1000 .. 1000;
  package Acceleration_Vector is new Vector (Acceleration);

  -- Microtesla, limits exceed earth's magnetic field range
  type Magnetic_Flux_Density is new Measurement range 10 .. 80;
  package Magnetic_Field_Vector is new Vector (Magnetic_Flux_Density);

  
  type Accelerometer_Reading is new Acceleration_Vector.Vector3D;
  type Magnetometer_Reading is new Magnetic_Field_Vector.Vector3D;
  type Barometer_Reading is new Pressure;
  
  type Sensor_Readings is record
    Accelerometer : Accelerometer_Reading;
    Magnetometer : Magnetometer_Reading;
    Barometer : Barometer_Reading;
  end record;
  
end Sensors;