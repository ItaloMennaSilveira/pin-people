require 'rails_helper'

RSpec.describe 'Api::V1::SurveyResponsesController', type: :request do
  let!(:user) { create(:user) }
  let!(:survey_responses) { create_list(:survey_response, 3, user: user) }
  let(:survey_response) { survey_responses.first }
  let(:valid_attributes) do
    {
      user_id: user.id,
      response_date: Date.current,
      interest_in_position: 5,
      contribution: 6,
      learning_and_development: 7,
      feedback: 8,
      manager_interaction: 5,
      career_clarity: 6,
      permanence_expectation: 7,
      enps: 8
    }
  end
  let(:url) { '/api/v1/survey_responses' }

  describe 'INDEX /api/v1/survey_responses' do
    it 'returns paginated survey responses filtered by user_id and date range' do
      get url,
          params: { user_id: user.id, start_date: 1.year.ago.to_date, end_date: Date.current, page: 1, per_page: 2 }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['survey_responses'].size).to be <= 2
      expect(json['meta']['current_page']).to eq(1)
      expect(json['meta']['total_count']).to eq(survey_responses.count)
    end

    it 'returns the first page of survey responses with default pagination' do
      get url

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['survey_responses'].size).to eq([SurveyResponse.count, 20].min)
    end
  end

  describe 'SHOW /api/v1/survey_responses/:id' do
    it 'returns the survey response' do
      get "#{url}/#{survey_response.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(survey_response.id)
    end
  end

  describe 'CREATE /api/v1/survey_responses' do
    context 'with valid params' do
      it 'creates a new survey response' do
        expect do
          post url, params: { survey_response: valid_attributes }
        end.to change(SurveyResponse, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['user_id']).to eq(user.id)
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable_entity with errors' do
        post url, params: { survey_response: valid_attributes.merge(interest_in_position: nil) }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Interest in position can't be blank")
      end
    end
  end

  describe 'UPDATE /api/v1/survey_responses/:id' do
    context 'with valid params' do
      it 'updates the survey response' do
        put "#{url}/#{survey_response.id}", params: { survey_response: { feedback: 9 } }
        expect(response).to have_http_status(:ok)
        expect(survey_response.reload.feedback).to eq(9)
      end

      it 'allows updating user_id when not nil' do
        new_user = create(:user)
        put "#{url}/#{survey_response.id}", params: { survey_response: { user_id: new_user.id } }
        expect(response).to have_http_status(:ok)
        expect(survey_response.reload.user_id).to eq(new_user.id)
      end
    end

    context 'with user_id nil in params' do
      it 'returns unprocessable_entity error' do
        put "#{url}/#{survey_response.id}", params: { survey_response: { user_id: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('user_id cannot be null')
      end
    end

    context 'with invalid params' do
      it 'returns errors' do
        put "#{url}/#{survey_response.id}", params: { survey_response: { interest_in_position: 20 } }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Interest in position must be less than or equal to 10')
      end
    end
  end

  describe 'DESTROY /api/v1/survey_responses/:id' do
    it 'destroys the requested survey_response' do
      expect do
        delete "#{url}/#{survey_response.id}"
      end.to change(SurveyResponse, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
