class AreaDataVisualizationService
  def initialize(company_id:, department_id: nil)
    @company_id = company_id
    @department_id = department_id
  end

  def call
    areas = Department.where(company_id: @company_id).where.not(level: 0)
    areas = areas.where(id: @department_id) if @department_id.present?

    enps_by_area = areas.map do |area|
      users = User.where(department_id: area.id)
      responses = SurveyResponse.where(user_id: users.select(:id)).where.not(enps: nil)

      next if responses.empty?

      scores = responses.map(&:enps)
      promoters = scores.count { |s| s >= 9 }
      detractors = scores.count { |s| s <= 6 }
      total = scores.size

      enps = ((promoters - detractors) * 100.0 / total).round(2)

      {
        department_name: area.name,
        enps: enps,
        total_responses: total
      }
    end.compact

    {
      enps_by_area: enps_by_area
    }
  end
end
