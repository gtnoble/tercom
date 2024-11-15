package body Statistics.Cumulative is
  
  function PMF_To_CDF (
    Probability_Mass : Probabilities
  ) return Probabilities
  is
    Accumumulation : Probabilities;
  begin
    for Index in U loop
      if Index = U'First then
        Accumumulation (Index) := Probability_Mass (Index);
      else
        Accumumulation (Index) := 
          Accumumulation (Index - 1) + Probability_Mass (Index);
      end if;
    end loop;
    return Accumumulation;
  end Cumulative_Distribution;
  
  function Sample_CDF  (
    Probability_Mass : Probabilities
  ) return U
  is
    Random_Number : Particle_Statistics.Probability;
    Uniform_Distribution : Particle_Statistics.Uniform_Distribution;
  begin
    for Index in U loop
      if Probability_Mass (Index) >= 
        Particle_Statistics.Random_Sample(Uniform_Distribution) then
        return Index;
      end if;
    end loop;
  end;
  
  function Normalize_PMF (
    Bins : Probabilities
  ) return Probabilities
  is
    Normalized_PMF : Probabilities;
    Bins_Sum : T := 0;
  begin
    for Index in U loop
      Probability_Sum := Bins_Sum + Bins (Index);
    end loop;
    
    for Index in U loop
      Normalized_PMF (Index) := Bins (Index) / Probability_Sum;
    end loop;
    return Normalized_PMF;
  end Normalize_PMF;
  
end Statistics.Cumulative;