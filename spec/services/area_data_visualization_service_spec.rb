require 'rails_helper'

RSpec.describe AreaDataVisualizationService do
  describe '#call' do
    let(:company) { create(:department, level: 0, name: "Acme Corp") }

    let(:area1) { create(:department, parent: company, level: 1, name: "Sales") }
    let!(:area2) { create(:department, parent: company, level: 1, name: "Support") }

    let(:user1) { create(:user, department: area1) }
    let(:user2) { create(:user, department: area1) }
    let(:user3) { create(:user, department: area2) }

    before do
      create(:survey_response, user: user1, enps: 10)
      create(:survey_response, user: user2, enps: 5)
      create(:survey_response, user: user3, enps: 8)
    end

    it 'calculates eNPS per area correctly without department_id' do
      result = described_class.new(company_id: company.id).call
      enps_data = result[:enps_by_area]

      sales_data = enps_data.find { |d| d[:department_name] == "Sales" }
      support_data = enps_data.find { |d| d[:department_name] == "Support" }

      expect(sales_data[:enps]).to eq(0.0)
      expect(sales_data[:total_responses]).to eq(2)

      expect(support_data[:enps]).to eq(0.0)
      expect(support_data[:total_responses]).to eq(1)
    end

    it 'filters by department_id' do
      result = described_class.new(company_id: company.id, department_id: area1.id).call
      enps_data = result[:enps_by_area]

      expect(enps_data.size).to eq(1)
      expect(enps_data.first[:department_name]).to eq("Sales")
    end

    it 'excludes areas without responses' do
      area3 = create(:department, parent: company, level: 1, name: "Finance")
      result = described_class.new(company_id: company.id).call
      department_names = result[:enps_by_area].map { |d| d[:department_name] }

      expect(department_names).to include("Sales", "Support")
      expect(department_names).not_to include("Finance")
    end
  end
end
