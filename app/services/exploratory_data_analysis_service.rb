class ExploratoryDataAnalysisService
  def initialize(company_id: nil)
    @company_id = company_id
    @responses = filtered_responses
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
      interest_distribution: filtered_survey.group(:interest_in_position).count,
      enps_distribution: filtered_survey.group(:enps).count
    }
  end

  private

  def filtered_survey
    return SurveyResponse.all unless @company_id

    SurveyResponse
      .joins(user: :department)
      .where(
        'departments.level = 0 AND departments.id = :company_id OR departments.level != 0 AND departments.company_id = :company_id',
        company_id: @company_id
      )
  end

  def filtered_responses
    filtered_survey.pluck(:interest_in_position)
  end

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
