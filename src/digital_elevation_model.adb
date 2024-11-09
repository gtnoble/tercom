package body Digital_Elevation_Model is
  
  function DEM_Elevation (
    Coordinates : Position.Geographic_Coordinates; DEM_Map : DEM
  ) return Altitude
  is
  begin
    declare
      Reference_Location : constant Reference_Coordinates := 
        DEM_Map.Reference_Location;
      Map_Column_Index : DEM_Row_Column_Index := 
        DEM_Row_Column_Index ((Coordinates.Longitude - 
        Longitude (Reference_Location.Longitude)) * DEM_Dimensions);
      Map_Row_Index : DEM_Row_Column_Index := 
        DEM_Row_Column_Index ((Coordinates.Latitude - 
        Latitude (Reference_Location.Latitude)) * DEM_Dimensions);
      
      Data_Row_Index : DEM_Data_Index := DEM_Dimensions * Map_Row_Index;
      Data_Column_Index : DEM_Data_Index := Data_Row_Index + Map_Row_Index;
    begin
      return DEM_Map.Map (Data_Column_Index);
    end;
  end DEM_Elevation;

  function Load_DEM (
    Coordinates : Reference_Coordinates;
    Files_Directory : String
  ) return DEM
  is
    DEM_Map : DEM;
    package DEM_IO is new Ada.Sequential_IO (DEM_Element);
    DEM_File : DEM_IO.File_Type;
  begin
    DEM_IO.Open (
      DEM_File, 
      DEM_IO.In_File, 
      Files_Directory & "/" & DEM_Filename (Coordinates)
    );

    DEM_Map.Reference_Location := Coordinates;
    
    declare
      Raw_DEM_Value : DEM_Element;
      DEM_Index : DEM_Data_Index := 1;
    begin
      while not DEM_IO.End_Of_File (DEM_File) loop
        DEM_IO.Read (DEM_File, Raw_DEM_Value);
        DEM_Map.Map (DEM_Index) := Raw_DEM_Value.Elevation;
        DEM_Index := DEM_Index + 1;
      end loop;
    end;

    DEM_IO.Close (DEM_File);
  end Load_DEM;
  
  function Get_Reference_Coordinates (
    Coordinates : Geographic_Coordinates
  ) return Reference_Coordinates
  is
  begin
    declare
      Filename_Reference_Latitude : constant Latitude 
        := Latitude'Ceiling (Coordinates.Latitude);
      Filename_Reference_Longitude : constant Longitude 
        := Longitude'Ceiling (Coordinates.Longitude);
    begin
      return (Filename_Reference_Latitude,
              Filename_Reference_Longitude);
    end;
  end Get_Reference_Coordinates;

  function DEM_Filename (
    Coordinates : Reference_Coordinates
  ) return String
  is
    Filename_Prefix : constant String := "NASADEM_HGT";
    Filename_Extension : constant String := "hgt";

    Number_Latitude_Digits : constant Natural := 2;
    Number_Longitude_Digits : constant Natural := 3;
    
    type Absolute_Latitude is new Natural range 0 .. 90;
    type Absolute_Longitude is new Natural range 0..180;
    
  begin
    declare

      Latitude_Text : constant String := 
        Zeros_Pad (Absolute_Latitude (abs Coordinates.Latitude));
      Latitude_Direction : String (1 .. 1);

      Longitude_Text : constant String := 
        Zeros_Pad (Absolute_Longitude (abs Coordinates.Longitude));
      Longitude_Direction : String (1 .. 1);

    begin
      if Filename_Reference_Latitude > 0 then
        Latitude_Direction := "n";
      elsif Filename_Reference_Latitude < 0 then
        Latitude_Direction := "s";
      else
        Latitude_Direction := "";
      end if;
      
      if Filename_Reference_Longitude > 0 then
        Longitude_Direction := "w";
      elsif Filename_Reference_Longitude < 0 then
        Longitude_Direction := "e";
      else
        Longitude_Direction := "";
      end if;
      
      return 
        Filename_Prefix & "_" & 
        Latitude_Direction & Latitude_Text &
        Longitude_Direction & Longitude_Text &
        "." & Filename_Extension;
    end;
  end DEM_Filename;
  
  function Zeros_Pad (Number : Natural; Padded_Length : Positive) return String
  is
  begin
    declare
      Unpadded : String := Natural'Image (Number);
      Padded : String (1 .. Padded_Length) := (others => '0');
    begin
      Padded (Padded'Last - Unpadded'Length + 1 .. Padded'Last) := Unpadded;
      return Padded;
    end;
  end Zeros_Pad;
  
  

end Digital_Elevation_Model;