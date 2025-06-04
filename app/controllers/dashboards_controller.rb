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

    @enps_distribution = SurveyResponse.group(:enps).count.sort_by { |k, v| k.to_i }.to_h
    @enps_distribution = {} if @enps_distribution.blank?
  end

  def exploratory_data_analysis
    @statistics = ExploratoryDataAnalysisService.new.call
  end
end
