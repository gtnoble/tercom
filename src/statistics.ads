with Math; use Math;

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
    Lower_Limit : T;
    Upper_Limit : T;
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

private
end Statistics;