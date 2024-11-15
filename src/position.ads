with Math; use Math;
with Kinematics;

package Position is
  type Latitude is new Degrees range -90 .. 90;
  type Latitude_Change is new Latitude;
  type Longitude is new Degrees_Wrapped;
  type Longitude_Change is new Longitude;
  
  package Kinematics is new Generic_Kinematics (Precise_Float);

  -- Elevation Extremes on Earth's Surface in meters
  type Altitude is new Precise_Float range -1000 .. 10000;
  type Altitude_Change is new Precise_Float range -11000 .. 11000;

  type Geographic_Coordinates is record
    Latitude  : Latitude;
    Longitude : Longitude;
  end record;
  
  type Geographic_Location is record
    Position : Geographic_Coordinates;
    Altitude : Altitude;
  end record;
  
  type Heading is new Degrees_Wrapped;
  
  -- WGS 84 Parameters
  type Earth_Radius is new Precise_Float range 6_300_000 .. 6_400_000;
  Earth_Elipsoid_Semi_Major_Axis : constant Earth_Radius := 6378137.0;
  Earth_Elipsoid_Semi_Minor_Axis : constant Earth_Radius := 6356752.314245;
  Earth_Elipsoid_Inverse_Flattening : constant := 298.257223563;
  
  Earth_Elipsoid_Flattening : constant Precise_Float := 1 / Earth_Elipsoid_Inverse_Flattening;
  Earth_Elipsoid_Eccentricity_Squared : constant Precise_Float := Earth_Elipsoid_Flattening * (2 - Earth_Elipsoid_Flattening);
  
  
  function Shifted_Location (Current_Location : Geographic_Location; Displacement : Kinematics.Displacement) return Geographic_Coordinates;
  function Earth_Mean_Radius_Of_Curvature (Phi : Latitude) return Earth_Radius;
  
private

  A : constant Precise_Float := Earth_Elipsoid_Semi_Major_Axis;
  B : constant Precise_Float := Earth_Elipsoid_Semi_Minor_Axis;
  Pi : constant := Ada.Numerics.Pi;
  E_Squared : constant Precise_Float := Earth_Elipsoid_Eccentricity_Squared;

  function Meridional_Radius_Of_Curvature (Phi : Latitude) return Earth_Radius;
  function Prime_Vertical_Radius_Of_Curvature (Phi : Latitude) return Earth_Radius;
  function Wrap_Longitude (Angle : Degrees) return Longitude;

end Position;