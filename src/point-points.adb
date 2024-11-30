package body Point.Points is

   function Make_Points 
      (Points_Start_Index, Points_End_Index : Points_Index_Type;
      Point_Start_Index, Point_End_Index    : Point_Index_Type) return Points_Type 
   is
      Points_Array : Points_Array_Type (Points_Start_Index .. Points_End_Index);
   begin
      return (Points            => To_Holder (Points_Array),
              Point_Start_Index => Point_Start_Index,
              Point_End_Index   => Point_End_Index);
   end Make_Points;

   function New_Points
     (Fill                                 : Point_Type;
      Points_Start_Index, Points_End_Index : Points_Index_Type)
      return Points_Type
   is
      Created_Points : Points_Type;
      Points_Array   :
        Points_Array_Type (Points_Start_Index .. Points_End_Index) :=
        (others => To_Holder (Fill));
   begin
      Created_Points.Point_Start_Index := Point_Index_Type (Fill'First);
      Created_Points.Point_End_Index   := Point_Index_Type (Fill'Last);
      Created_Points.Points            := To_Holder (Points_Array);
      return Created_Points;
   end New_Points;

   function First (Points : Points_Type) return Points_Index_Type is
   begin
      return Element (Points.Points)'First;
   end First;

   function Last (Points : Points_Type) return Points_Index_Type is
   begin
      return Element (Points.Points)'Last;
   end Last;

   function Get (Points : Points_Type; Index : Points_Index_Type) return Point_Type is
   begin
      return Element (Element (Points.Points) (Index));
   end Get;

   procedure Set
     (Points : in out Points_Type; Index : Points_Index_Type; Value : Point_Type)
   is
      Point_Element_Container : Point_Holders.Holder :=
        Element (Points.Points) (Index);
   begin
      Replace_Element (Point_Element_Container, Value);
   end Set;

   function Point_First (Points : Points_Type) return Point_Index_Type is
   begin
      return Points.Point_Start_Index;
   end Point_First;

   function Point_Last (Points : Points_Type) return Point_Index_Type is
   begin
      return Points.Point_End_Index;
   end Point_Last;

   function Num_Points (Points : Points_Type) return Positive is
   begin
      return Element (Points.Points)'Length;
   end Num_Points;
   
   function Matrix_To_Points (Matrix : Matrix_Type) return Points_Type is
      Points : Points_Type := Make_Points
         (Points_Start_Index => Points_Index_Type (Matrix'First(1)), 
         Points_End_Index => Points_Index_Type (Matrix'Last(1)),
         Point_Start_Index   => Point_Index_Type (Matrix'First(2)), 
         Point_End_Index  => Point_Index_Type (Matrix'First(2)));
   begin
      for Row_Index in Matrix'Range (1) loop
         declare
            Row : Point_Type (Matrix'Range (2));
         begin
            for Column_Index in Row'Range loop
               Row (Column_Index) := Matrix (Row_Index, Column_Index);
            end loop;
               Set (Points, Points_Index_Type (Row_Index), Row);
         end;
      end loop;
      return Points;
   end Matrix_To_Points;

end Point.Points;
