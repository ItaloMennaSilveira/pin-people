class ExploratoryDataAnalysisService
  def initialize
    @responses = SurveyResponse.pluck(:interest_in_position)
  end

  def call
    return {} if @responses.empty?

    {
      mean: mean(@responses),
      median: median(@responses),
      mode: mode(@responses),
      variance: variance(@responses),
      standard_deviation: standard_deviation(@responses),
      min: @responses.min,
      max: @responses.max,
      count: @responses.size,
      interest_distribution: SurveyResponse.group(:interest_in_position).count,
      enps_distribution: SurveyResponse.group(:enps).count
    }
  end

  private

  def mean(array)
    array.sum.to_f / array.size
  end

  def median(array)
    sorted = array.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def mode(array)
    freq = array.tally
    max_freq = freq.values.max
    modes = freq.select { |_, v| v == max_freq }.keys
    modes.size == array.size ? nil : modes
  end

  def variance(array)
    m = mean(array)
    sum = array.reduce(0) { |acc, x| acc + (x - m)**2 }
    sum / (array.size - 1).to_f
  end

  def standard_deviation(array)
    Math.sqrt(variance(array))
  end
end
