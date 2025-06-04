class CompanyDataVisualizationService
  def initialize(company_id)
    @company_id = company_id
    @department_ids = Department.where(company_id: company_id).pluck(:id)
  end

  def call
    responses = SurveyResponse
                .joins(:user)
                .where(users: { department_id: @department_ids })

    {
      overall_satisfaction: calculate_overall_satisfaction(responses),
      enps_by_tenure: calculate_enps_by_tenure
    }
  end

  private

  def calculate_overall_satisfaction(responses)
    return nil if responses.empty?

    satisfaction_components = %i[
      interest_in_position
      contribution
      learning_and_development
      feedback
      manager_interaction
      career_clarity
      permanence_expectation
    ]

    individual_averages = responses.pluck(*satisfaction_components).map do |values|
      compacted = values.compact
      next if compacted.empty?

      compacted.sum.to_f / compacted.size
    end.compact

    return 0 if individual_averages.empty?

    individual_averages.sum / individual_averages.size
  end

  def calculate_enps_by_tenure
    SurveyResponse
      .joins(:user)
      .where(users: { department_id: @department_ids })
      .group('users.company_tenure')
      .pluck('users.company_tenure', 'AVG(survey_responses.enps)')
      .to_h
  end
end
