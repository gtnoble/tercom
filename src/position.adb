package body Position is
  
  function Earth_Mean_Radius_Of_Curvature (Phi : Latitude) return Earth_Radius
  is
  begin
    return 2.0 / 
      (
        (1 / Meridional_Radius_Of_Curvature(Phi)) + 
        (1 / Prime_Vertical_Radius_Of_Curvature(Phi))
      );
  end Earth_Mean_Radius_Of_Curvature;
  
  function Meridional_Radius_Of_Curvature (Phi : Latitude) return Earth_Radius
  is
  begin
    return (1 - Earth_Elipsoid_Eccentricity_Squared) * 
    Prime_Vertical_Radius_Of_Curvature (Phi) ** 3 /
    A ** 2;
  end Meridional_Radius_Of_Curvature;
  
  function Prime_Vertical_Radius_Of_Curvature (Phi : Latitude) return Earth_Radius
  is
    Latitude_Radians : Radians;
  begin
    Latitude_Radians := To_Radians (Phi);
    return A / Precise_Math.Sqrt (1 - E_Squared * Precise_Math.Sin (Latitude_Radians) ** 2);
  end Prime_Vertical_Radius_Of_Curvature;
  
  function To_Radians (Angle : Degrees) return Precise_Float
  is
  begin
    return Angle / 180 *  Pi;
  end To_Radians;
  
  function To_Degrees (Angle : Radians) return Precise_Float
  is
  begin
    return Angle / Pi * 180;
  end To_Degrees;
  
  function Shifted_Location (Current_Location : Geographic_Location; Displacement : Motion)
  is
    Tangent_Sphere_Radius : Earth_Radius;
    Delta_Latitude        : Precise_Float;
    Delta_Longitude       : Precise_Float; 
    Delta_Altitude        : Precise_Float;
    Shifted_Coordinates   : Geographic_Coordinates;
  begin
    Tangent_Sphere_Radius := Earth_Mean_Radius_Of_Curvature(Current_Location.Latitude);

    Delta_Latitude  := To_Degrees (Displacement (1) / Tangent_Sphere_Radius);
    Delta_Longitude := To_Degrees (
      Displacement (0) / 
      (
        Tangent_Sphere_Radius * 
        Precise_Math.Cos(To_Radians(Current_Location.Latitude))
      )
    );
    Delta_Altitude := Displacement (2);

    Shifted_Coordinates.Latitude  := Current_Location.Latitude + Delta_Latitude;
    Shifted_Coordinates.Longitude := Wrap_Longitude (
                                      Current_Location.Longitude + 
                                      Delta_Longitude);
    Shifted_Altitude              := Current_Location.Altitude + Delta_Altitude;

    return (Altitude => Shifted_Altitude, Coordinates => Shifted_Coordinates);
  end Shifted_Location;
  
  function Wrap_Longitude (Angle : Degrees) return Longitude 
  is
    Revolutions : Precise_Float;
  begin
    Revolutions := Angle / 360;
    return Longitude(Angle - Degrees (360 * Revolutions'Rounding));
  end Wrap_Longitude;

end Position;