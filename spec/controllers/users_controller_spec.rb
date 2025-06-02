require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:url) { '/api/v1/users' }

  describe 'INDEX /api/v1/users' do
    let(:department) { create(:department) }
    let(:users) { create_list(:user, 3, department: department) }

    it 'returns paginated users' do
      get url, params: { page: 1, per_page: 2 }, format: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['users'].size).to eq(2)
      expect(json['total_count']).to eq(3)
    end

    it 'filters users by department' do
      other_department = create(:department)
      create(:user, department: other_department)

      get url, params: { department_id: department.id }, format: :json
      json = JSON.parse(response.body)
      expect(json['users'].all? { |u| u['department_id'] == department.id }).to be true
    end
  end

  describe 'SHOW /api/v1/users/:id' do
    it 'returns a user if found' do
      user = create(:user)
      get url, params: { id: user.id }, format: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(user.id)
    end

    it 'returns not found if user does not exist' do
      get url, params: { id: 999999 }, format: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'CREATE /api/v1/users' do
    let(:department) { create(:department) }

    it 'creates a user with valid params' do
      post url, params: { user: attributes_for(:user, department_id: department.id) }, format: :json

      expect(response).to have_http_status(:created)
      expect(User.count).to eq(1)
    end

    it 'returns not found if department_id is invalid' do
      post url, params: { user: attributes_for(:user, department_id: 999999) }, format: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'returns errors if user is invalid' do
      post url, params: { user: { name: '' } }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'UPDATE /api/v1/users' do
    let(:user) { create(:user) }
    let(:department) { create(:department) }

    it 'updates user with valid params' do
      patch url, params: { id: user.id, user: { name: 'Updated Name', department_id: department.id } }, format: :json

      expect(response).to have_http_status(:ok)
      expect(user.reload.name).to eq('Updated Name')
    end

    it 'returns not found if department_id is invalid' do
      patch url, params: { id: user.id, user: { department_id: 999999 } }, format: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DESTROY /api/v1/users/:id' do
    it 'destroys the user and associated survey responses' do
      user = create(:user)
      create_list(:survey_response, 2, user: user)

      expect {
        delete url, params: { id: user.id }, format: :json
      }.to change { User.count }.by(-1)
       .and change { SurveyResponse.count }.by(-2)

      expect(response).to have_http_status(:no_content)
    end
  end
end
