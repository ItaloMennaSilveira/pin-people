require 'rails_helper'

RSpec.describe CompanyDataVisualizationService do
  describe '#call' do
    let(:company) { create(:department, level: 0, name: "Acme Corp") }

    let!(:area1) { create(:department, parent: company, level: 1, name: "Sales") }
    let!(:area2) { create(:department, parent: company, level: 1, name: "Support") }

    let(:tenures) { User.company_tenures.keys }

    let!(:user1) { create(:user, department: area1, company_tenure: tenures[0]) }
    let!(:user2) { create(:user, department: area1, company_tenure: tenures[1]) }
    let!(:user3) { create(:user, department: area2, company_tenure: tenures[2]) }

    before do
      create(:survey_response, user: user1,
             interest_in_position: 8,
             contribution: 7,
             learning_and_development: 9,
             feedback: 6,
             manager_interaction: 7,
             career_clarity: 8,
             permanence_expectation: 7,
             enps: 10)

      create(:survey_response, user: user2,
             interest_in_position: 5,
             contribution: 6,
             learning_and_development: 5,
             feedback: 4,
             manager_interaction: 5,
             career_clarity: 6,
             permanence_expectation: 5,
             enps: 5)

      create(:survey_response, user: user3,
             interest_in_position: 7,
             contribution: 8,
             learning_and_development: 7,
             feedback: 6,
             manager_interaction: 8,
             career_clarity: 7,
             permanence_expectation: 6,
             enps: 9)
    end

    it 'returns overall satisfaction average correctly' do
      service = CompanyDataVisualizationService.new(company.id)
      result = service.call

      expected_average = ((7.43 + 5.14 + 7.0) / 3).round(2)

      expect(result[:overall_satisfaction].round(2)).to eq(expected_average)
    end

    it 'returns eNPS grouped by company tenure correctly' do
      service = CompanyDataVisualizationService.new(company.id)
      result = service.call

      enps_by_tenure = result[:enps_by_tenure]

      expect(enps_by_tenure).to be_a(Hash)
      expect(enps_by_tenure[tenures[0]]).to eq(10.0)
      expect(enps_by_tenure[tenures[1]]).to eq(5.0)
      expect(enps_by_tenure[tenures[2]]).to eq(9.0)
    end
  end
end
