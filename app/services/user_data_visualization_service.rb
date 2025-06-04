class UserDataVisualizationService
  def initialize(company_id)
    @company_id = company_id
  end

  def call
    users = User.joins(:department)
                .where(departments: { company_id: @company_id })
                .includes(:survey_responses, department: :parent)

    user_data = users.map do |user|
      responses = user.survey_responses
      next if responses.empty?

      enps_scores = responses.map(&:enps).compact
      avg_enps = enps_scores.sum.to_f / enps_scores.size

      {
        id: user.id,
        position: user.position,
        function: user.function,
        company_tenure: user.company_tenure,
        generation: user.generation,
        genre: user.genre,
        department_id: user.department_id,
        department_name: user.department.name,
        avg_enps: avg_enps.round(2)
      }
    end.compact

    area_averages = SurveyResponse.joins(:user)
                                  .where(users: { department_id: user_data.map { |u| u[:department_id] } })
                                  .group('users.department_id')
                                  .pluck('users.department_id, AVG(enps), AVG(contribution)')
                                  .to_h do |dept_id, enps_avg, satisfaction_avg|
      [dept_id,
       { enps_avg: enps_avg.to_f.round(2),
         satisfaction_avg: satisfaction_avg.to_f.round(2) }]
    end

    user_data.each do |u|
      averages = area_averages[u[:department_id]] || { enps_avg: nil, satisfaction_avg: nil }
      u[:area_enps_avg] = averages[:enps_avg]
      u[:area_satisfaction_avg] = averages[:satisfaction_avg]
    end

    {
      users: user_data,
      area_averages: area_averages
    }
  end
end
