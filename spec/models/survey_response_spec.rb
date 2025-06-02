require 'rails_helper'

RSpec.describe SurveyResponse, type: :model do
  it { should belong_to(:user) }

  %i[
    interest_in_position contribution learning_and_development
    feedback manager_interaction career_clarity permanence_expectation enps
  ].each do |attr|
    it { should validate_numericality_of(attr).only_integer.is_greater_than(0).is_less_than_or_equal_to(10) }
    it { should validate_presence_of(attr) }
  end

  describe 'scopes' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    let!(:response1) { create(:survey_response, user: user1, response_date: Date.new(2024, 1, 10)) }
    let!(:response2) { create(:survey_response, user: user2, response_date: Date.new(2024, 3, 15)) }
    let!(:response3) { create(:survey_response, user: user1, response_date: Date.new(2024, 5, 1)) }

    describe '.by_user_id' do
      it 'returns responses for the specified user' do
        expect(SurveyResponse.by_user_id(user1.id)).to match_array([response1, response3])
      end

      it 'returns all responses when user_id is nil' do
        expect(SurveyResponse.by_user_id(nil)).to match_array([response1, response2, response3])
      end
    end

    describe '.by_response_date_range' do
      let!(:response_old) { create(:survey_response, response_date: 2.years.ago.to_date) }
      let!(:response_mid) { create(:survey_response, response_date: 6.months.ago.to_date) }
      let!(:response_recent) { create(:survey_response, response_date: Date.current) }

      it 'returns all responses when both dates are nil' do
        expect(SurveyResponse.by_response_date_range(nil, nil)).to match_array(SurveyResponse.all)
      end

      it 'returns responses between start_date and end_date when both are present' do
        start_date = 7.months.ago.to_date
        end_date = 1.month.ago.to_date
        expected = SurveyResponse.where(response_date: start_date..end_date)
        expect(SurveyResponse.by_response_date_range(start_date, end_date)).to match_array(expected)
      end

      it 'returns responses from start_date to today when only start_date is present' do
        start_date = 7.months.ago.to_date
        expected = SurveyResponse.where(response_date: start_date..Date.current)
        expect(SurveyResponse.by_response_date_range(start_date, nil)).to match_array(expected)
      end

      it 'returns responses from 1 year before end_date when only end_date is present' do
        end_date = Date.current
        expected = SurveyResponse.where(response_date: (end_date - 1.year)..end_date)
        expect(SurveyResponse.by_response_date_range(nil, end_date)).to match_array(expected)
      end
    end
  end
end
