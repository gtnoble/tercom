with Math; use Math;
with Ada.Numerics.Float_Random;

generic
  type T is digits <>;
package Statistics is
  package Statistics_Math is new Ada.Numerics.Generic_Elementary_Functions(T);
  use Statistics_Math;

  type Probability is new T range 0 .. 1;
  
  type Gaussian_Distribution is record
    Mean : T;
    Standard_Deviation : T;
  end record;
  
  type Uniform_Distribution is record
    Lower_Limit : T := 0.0;
    Upper_Limit : T := 1.0;
  end record;
  
  function Probability_Density 
    (
      x : T;
      Distribution : Gaussian_Distribution
    ) return Probability;
    
  function Probability_Density
    (
      x : T;
      Distribution : Uniform_Distribution
    ) return Probability;
    
  function Random_Sample (
    Distribution : Uniform_Distribution
  ) return T;
  
private
end Statistics;