require 'rails_helper'

RSpec.describe ExploratoryDataAnalysisService do
  let(:company) { create(:department, level: 0, name: 'Acme Corp') }
  let!(:area) { create(:department, parent: company, level: 1, name: 'Sales') }

  let!(:user1) { create(:user, department: area) }
  let!(:user2) { create(:user, department: area) }
  let!(:user3) { create(:user, department: area) }

  before do
    create(:survey_response, user: user1, interest_in_position: 7, enps: 10)
    create(:survey_response, user: user2, interest_in_position: 5, enps: 8)
    create(:survey_response, user: user3, interest_in_position: 7, enps: 10)
  end

  describe '#call' do
    context 'when company_id is given' do
      subject { described_class.new(company_id: company.id).call }

      it 'returns the correct mean of interest_in_position' do
        expect(subject[:mean]).to eq((7 + 5 + 7) / 3.0)
      end

      it 'returns the correct median of interest_in_position' do
        expect(subject[:median]).to eq(7.0)
      end

      it 'returns the correct mode of interest_in_position' do
        expect(subject[:mode]).to eq([7])
      end

      it 'returns the correct variance of interest_in_position' do
        mean = (7 + 5 + 7) / 3.0
        variance = (((7 - mean)**2 + (5 - mean)**2 + (7 - mean)**2) / 2.0)
        expect(subject[:variance]).to be_within(0.0001).of(variance)
      end

      it 'returns the correct standard deviation of interest_in_position' do
        mean = (7 + 5 + 7) / 3.0
        variance = (((7 - mean)**2 + (5 - mean)**2 + (7 - mean)**2) / 2.0)
        std_dev = Math.sqrt(variance)
        expect(subject[:standard_deviation]).to be_within(0.0001).of(std_dev)
      end

      it 'returns the min and max of interest_in_position' do
        expect(subject[:min]).to eq(5)
        expect(subject[:max]).to eq(7)
      end

      it 'returns the count of interest_in_position' do
        expect(subject[:count]).to eq(3)
      end

      it 'returns interest_in_position distribution' do
        expect(subject[:interest_distribution]).to eq({ 7 => 2, 5 => 1 })
      end

      it 'returns enps distribution' do
        expect(subject[:enps_distribution]).to eq({ 10 => 2, 8 => 1 })
      end
    end

    context 'when company_id is nil' do
      subject { described_class.new.call }

      it 'returns data for all SurveyResponses' do
        other_company = create(:department, level: 0, name: 'Other Corp')
        other_area = create(:department, parent: other_company, level: 1)
        other_user = create(:user, department: other_area)
        create(:survey_response, user: other_user, interest_in_position: 3, enps: 5)

        result = described_class.new.call

        expect(result[:interest_distribution][3]).to be >= 1
        expect(result[:interest_distribution].keys).to include(3)
      end
    end

    context 'when there are no responses' do
      it 'returns empty hash' do
        result = described_class.new(company_id: 999_999).call
        expect(result).to eq({})
      end
    end
  end
end
