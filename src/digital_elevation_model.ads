with Position; use Position;
with Interfaces;
with Ada.Sequential_IO;
with Ada.System;

with Math; use Math;

package Digital_Elevation_Model is
  type DEM_Altitude_Value is new Interfaces.Integer_16;
  package DEM_IO is new Ada.Direct_IO (DEM_Altitude_Value);

  DEM_Dimensions : constant := 60;
  type DEM_Data_Index is range 0 .. DEM_Dimensions ** 2;
  type DEM_Row_Column_Index is new DEM_Data_Index range 0 .. DEM_Dimensions - 1;
  
  type Reference_Latitude is range -90 .. 90;
  type Reference_Longitude is range -180 .. 180;
  type Reference_Coordinates is record
    Latitude : Reference_Latitude;
    Longitude : Reference_Longitude;
  end record;
  
  type DEM_Element is record
    Elevation : DEM_Altitude_Value;
  end record;
  
  for DEM_Element use record
    Elevation at 0 range 0 .. 15;
  end record;
  
  for DEM_Element'Bit_Order use System.High_Order_First;
  
  type DEM is record
    Map : array (DEM_Data_Index) of DEM_Altitude_Value;
    Reference_Location : Reference_Coordinates;
  end record;
  
  function DEM_Elevation (
    Position : Position.Geographic_Coordinates; 
    Dem_Map : DEM
  ) return Altitude; 

  function Load_DEM (
    Coordinates : Reference_Coordinates;
    Files_Directory : String
  ) return DEM;

  function Get_Reference_Coordinates (
    Coordinates : Geographic_Coordinates
  ) return Reference_Coordinates;

private
  function Zeros_Pad (Number : Natural; Padded_Length : Positive) return String;
  function Get_DEM_Index (
    Coordinates : Geographic_Coordinates; 
    DEM_Map : DEM
  ) return DEM_Data_Index;
  function DEM_Filename (
    Position : Position.Geographic_Coordinates
  ) return String;

  
end Digital_Elevation_Model;