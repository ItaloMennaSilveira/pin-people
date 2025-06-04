require 'rails_helper'

RSpec.describe DashboardsController, type: :controller do
  render_views

  let!(:company1) { create(:department, level: 0, name: "Company 1") }
  let!(:company2) { create(:department, level: 0, name: "Company 2") }

  describe 'GET #index' do
    it 'assigns @users_by_area as a hash' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:users_by_area)).to be_a(Hash)
    end

    it 'assigns @average_interest_distribution as a hash' do
      get :index
      expect(assigns(:average_interest_distribution)).to be_a(Hash)
    end

    it 'assigns @enps_distribution as a hash' do
      get :index
      expect(assigns(:enps_distribution)).to be_a(Hash)
    end
  end

  describe 'GET #exploratory_data_analysis' do
    let(:fake_statistics) do
      {
        interest_distribution: { "high" => 10, "low" => 5 },
        mean: 3.1415,
        median: 3.1415,
        variance: 3.1415,
        standard_deviation: 3.1415,
        enps_distribution: { "Promoters" => 20, "Passives" => 10, "Detractors" => 5 }
      }
    end

    it 'assigns @companies' do
      allow_any_instance_of(ExploratoryDataAnalysisService).to receive(:call).and_return(fake_statistics)
      get :exploratory_data_analysis
      expect(assigns(:companies)).to match_array([company1, company2])
    end

    it 'calls ExploratoryDataAnalysisService with company_id param' do
      allow_any_instance_of(ExploratoryDataAnalysisService).to receive(:call).and_return(fake_statistics)
      get :exploratory_data_analysis, params: { company_id: company1.id }
      expect(assigns(:selected_company_id)).to eq(company1.id.to_s)
    end

    it 'calls ExploratoryDataAnalysisService without company_id param' do
      allow_any_instance_of(ExploratoryDataAnalysisService).to receive(:call).and_return(fake_statistics)
      get :exploratory_data_analysis
      expect(assigns(:selected_company_id)).to be_nil
    end
  end

  describe 'GET #company_data_visualization' do
    it 'assigns @companies' do
      get :company_data_visualization
      expect(assigns(:companies)).to match_array([company1, company2])
    end

    it 'calls CompanyDataVisualizationService with company_id param' do
      expect_any_instance_of(CompanyDataVisualizationService).to receive(:call).and_return({})
      get :company_data_visualization, params: { company_id: company2.id }
      expect(assigns(:company_id)).to eq(company2.id)
      expect(assigns(:data)).to eq({})
    end

    it 'calls CompanyDataVisualizationService with first company if no param' do
      expect_any_instance_of(CompanyDataVisualizationService).to receive(:call).and_return({})
      get :company_data_visualization
      expect(assigns(:company_id)).to eq(company1.id)
    end

    it 'assigns empty hash to @data if no company available' do
      Department.delete_all
      get :company_data_visualization
      expect(assigns(:data)).to eq({})
    end
  end

  describe 'GET #area_data_visualization' do
    let!(:dept1) { create(:department, company_id: company1.id, level: 1, parent: company1, name: "Area 1") }
    let!(:dept2) { create(:department, company_id: company1.id, level: 2, parent: dept1, name: "Area 2") }

    it 'assigns @companies and @departments' do
      get :area_data_visualization, params: { company_id: company1.id }
      expect(assigns(:companies)).to include(company1, company2)
      expect(assigns(:departments)).to include(dept1, dept2)
    end

    it 'sets @department_id only if valid' do
      get :area_data_visualization, params: { company_id: company1.id, department_id: dept1.id }
      expect(assigns(:department_id)).to eq(dept1.id)

      get :area_data_visualization, params: { company_id: company1.id, department_id: 99999 }
      expect(assigns(:department_id)).to be_nil
    end

    it 'calls AreaDataVisualizationService with correct params' do
      expect_any_instance_of(AreaDataVisualizationService).to receive(:call).and_return({})
      get :area_data_visualization, params: { company_id: company1.id, department_id: dept1.id }
      expect(assigns(:data)).to eq({})
    end

    it 'assigns empty hash to @data if no company_id' do
      get :area_data_visualization
      expect(assigns(:data)).to be_a(Hash)
    end
  end

  describe 'GET #user_data_visualization' do
    let!(:dept1) { create(:department, company_id: company1.id, level: 1, parent: company1, name: "Dept 1") }
    let!(:user) { create(:user, department: dept1) }
    let!(:survey_response) { create(:survey_response, user: user, enps: 8, contribution: 7) }

    it 'assigns @companies and @users' do
      get :user_data_visualization, params: { company_id: company1.id }
      expect(assigns(:companies)).to include(company1, company2)
      expect(assigns(:users)).to be_an(ActiveRecord::Relation)
      expect(assigns(:total_users_count)).to be_an(Integer)
      expect(assigns(:area_averages)).to be_a(Hash)
    end

    it 'paginates users with default page 1' do
      expect(User).to receive(:joins).and_call_original
      get :user_data_visualization, params: { company_id: company1.id }
    end

    it 'supports ransack params' do
      get :user_data_visualization, params: { company_id: company1.id, q: { function_cont: 'Engineer' } }
      expect(assigns(:q)).to be_present
    end
  end
end
