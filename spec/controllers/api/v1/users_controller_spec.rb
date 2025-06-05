require 'rails_helper'

RSpec.describe 'Api::V1::Users API', type: :request do
  let!(:company) { create(:department, :company) }
  let!(:department) { create(:department, parent: company) }
  let!(:users) { create_list(:user, 3, department: department) }
  let(:user) { users.first }

  describe 'INDEX /api/v1/users' do
    it 'returns paginated users list' do
      get '/api/v1/users', params: { page: 1, per_page: 2 }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['users'].size).to eq(2)
      expect(json['total_count']).to eq(3)
    end

    it 'returns all users without pagination params' do
      get '/api/v1/users', as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['users'].size).to eq(3)
      expect(json['total_count']).to eq(3)
    end
  end

  describe 'SHOW /api/v1/users/:id' do
    it 'returns user by id' do
      get "/api/v1/users/#{user.id}", as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(user.id)
    end

    it 'returns 404 if user not found' do
      get '/api/v1/users/0', as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'CREATE /api/v1/users' do
    let(:valid_params) do
      {
        user: {
          name: 'New User',
          email: 'new@example.com',
          company_email: 'new_company@example.com',
          department_id: department.id
        }
      }
    end

    let(:invalid_params) do
      {
        user: {
          name: '',
          email: 'invalidemail',
          department_id: nil
        }
      }
    end

    it 'creates user with valid params' do
      expect do
        post '/api/v1/users', params: valid_params, as: :json
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('New User')
    end

    it 'does not create user with invalid params' do
      expect do
        post '/api/v1/users', params: invalid_params, as: :json
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'UPDATE /api/v1/users/:id' do
    let(:update_params) do
      {
        user: {
          name: 'Updated Name'
        }
      }
    end

    it 'updates user with valid params' do
      put "/api/v1/users/#{user.id}", params: update_params, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('Updated Name')
      expect(user.reload.name).to eq('Updated Name')
    end

    it 'returns error with invalid data' do
      put "/api/v1/users/#{user.id}", params: { user: { company_email: '' } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 404 if user does not exist' do
      put '/api/v1/users/0', params: { user: { name: 'x' } }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DESTROY /api/v1/users/:id' do
    it 'deletes existing user' do
      expect do
        delete "/api/v1/users/#{user.id}", as: :json
      end.to change(User, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 if user does not exist' do
      delete '/api/v1/users/0', as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
