with Statistics;

generic
  type T is digits <>;
  type U is range <>;
package Statistics.Cumulative is
  type Probability is new Statistics_Math.Probability (T);
  type Probabilities is array (U) of Probability;

  type Probability_Mass is new Probabilities;
  type Cumulative_Distribution is new Probabilities;

  function Normalize_PMF (
    Bins : Probabilities
  ) return Probability_Mass;

  function PMF_To_CDF (
    PMF : Probability_Mass
  ) return Cumulative_Distribution;

  function Sample_CDF  (
    CDF : Cumulative_Distribution
  ) return U;

end Statistics.Cumulative;