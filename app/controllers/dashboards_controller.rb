class DashboardsController < ApplicationController
  def index
    @users_by_area = Department
                     .where(level: 4)
                     .left_joins(:department_users)
                     .group(:name)
                     .order(:name)
                     .count
    @users_by_area = {} if @users_by_area.blank?

    @average_interest_distribution = User.average_interest_distribution
    @average_interest_distribution = {} if @average_interest_distribution.blank?

    @enps_distribution = SurveyResponse.group(:enps).count.sort_by { |k, _v| k.to_i }.to_h
    @enps_distribution = {} if @enps_distribution.blank?
  end

  def exploratory_data_analysis
    @companies = Department.where(level: 0)
    @selected_company_id = params[:company_id].presence
    @statistics = ExploratoryDataAnalysisService.new(company_id: @selected_company_id).call
  end

  def company_data_visualization
    @companies = Department.where(level: 0)
    company_id = params[:company_id] || @companies.first&.id

    if company_id
      @company_id = company_id.to_i
      @data = CompanyDataVisualizationService.new(@company_id).call
    else
      @data = {}
    end
  end

  def area_data_visualization
    @companies = Department.where(level: 0)
    @company_id = params[:company_id]&.to_i || @companies.first&.id

    @departments = Department.where(company_id: @company_id).where.not(level: 0)
    @department_id = params[:department_id]&.to_i if @departments.pluck(:id).include?(params[:department_id]&.to_i)

    @data = if @company_id
              AreaDataVisualizationService.new(
                company_id: @company_id,
                department_id: @department_id
              ).call
            else
              {}
            end
  end

  def user_data_visualization
    @companies = Department.where(level: 0)
    @company_id = params[:company_id] || @companies.first&.id

    @q = User.joins(:department).where(departments: { company_id: @company_id }).ransack(params[:q])

    @users = @q.result
               .select(:id, :company_tenure, :function, :genre, :generation, :department_id)
               .offset(((params[:page] || 1).to_i - 1) * 50)
               .limit(50)

    department_ids = @users.map(&:department_id).uniq

    @area_averages = SurveyResponse
                     .joins(:user)
                     .where(users: { department_id: department_ids })
                     .group('users.department_id')
                     .pluck('users.department_id, AVG(enps), AVG(contribution)')
                     .to_h do |dept_id, enps_avg, satisfaction_avg|
      [dept_id,
       { enps_avg: enps_avg,
         satisfaction_avg: satisfaction_avg }]
    end

    @total_users_count = @q.result.count
  end
end
