require 'rails_helper'

RSpec.describe UserDataVisualizationService do
  describe '#call' do
    let(:company) { create(:department, level: 0, name: "Acme Corp") }
    let(:area1) { create(:department, parent: company, level: 1, name: "Sales") }
    let!(:area2) { create(:department, parent: company, level: 1, name: "Support") }

    let(:user1) { create(:user, department: area1, company_tenure: User.company_tenures.keys.sample) }
    let(:user2) { create(:user, department: area1, company_tenure: User.company_tenures.keys.sample) }
    let(:user3) { create(:user, department: area2, company_tenure: User.company_tenures.keys.sample) }

    before do
      create(:survey_response, user: user1, enps: 9, contribution: 8)
      create(:survey_response, user: user1, enps: 7, contribution: 7)

      create(:survey_response, user: user2, enps: 10, contribution: 9)

      create(:survey_response, user: user3, enps: 5, contribution: 6)
      create(:survey_response, user: user3, enps: 6, contribution: 7)
    end

    it 'returns aggregated user data with averages' do
      result = described_class.new(company.id).call

      expect(result).to have_key(:users)
      expect(result).to have_key(:area_averages)

      users_data = result[:users]
      area_averages = result[:area_averages]

      expect(users_data.size).to eq(3)

      user1_data = users_data.find { |u| u[:id] == user1.id }
      expect(user1_data).to include(
        position: user1.position,
        function: user1.function,
        company_tenure: user1.company_tenure,
        department_id: area1.id,
        department_name: area1.name
      )
      expect(user1_data[:avg_enps]).to be_within(0.01).of((9 + 7) / 2.0)

      user3_data = users_data.find { |u| u[:id] == user3.id }
      expect(user3_data[:avg_enps]).to be_within(0.01).of((5 + 6) / 2.0)

      expect(area_averages.keys).to include(area1.id, area2.id)

      expected_area1_enps_avg = ((9 + 7 + 10) / 3.0).round(2)
      expect(area_averages[area1.id][:enps_avg]).to be_within(0.01).of(expected_area1_enps_avg)

      expected_area1_contrib_avg = ((8 + 7 + 9) / 3.0).round(2)
      expect(area_averages[area1.id][:satisfaction_avg]).to be_within(0.01).of(expected_area1_contrib_avg)

      expect(user1_data[:area_enps_avg]).to eq(area_averages[area1.id][:enps_avg])
      expect(user1_data[:area_satisfaction_avg]).to eq(area_averages[area1.id][:satisfaction_avg])
    end

    context 'when user has no survey responses' do
      let!(:user_without_responses) { create(:user, department: area1) }

      it 'excludes users without responses from the result' do
        result = described_class.new(company.id).call
        user_ids = result[:users].map { |u| u[:id] }

        expect(user_ids).not_to include(user_without_responses.id)
      end
    end
  end
end
