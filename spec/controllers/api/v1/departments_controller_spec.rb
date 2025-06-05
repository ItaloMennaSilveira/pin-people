require 'rails_helper'

RSpec.describe 'Api::V1::Departments', type: :request do
  let!(:company) { create(:department, level: :company) }
  let!(:board) { create(:department, level: :board, parent: company) }
  let!(:area) { create(:department, level: :area, parent: board) }
  let(:url) { '/api/v1/departments' }

  describe 'INDEX /api/v1/departments' do
    before do
      create_list(:department, 25, level: :area, parent: board)
    end

    it 'returns paginated departments' do
      get url, params: { page: 1, per_page: 10 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include('departments', 'meta')
      expect(json['departments'].size).to eq(10)
      expect(json['meta']).to include('current_page', 'total_pages', 'total_count')
    end

    it 'filters departments by level with pagination' do
      get url, params: { level: 'area', page: 1, per_page: 5 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['departments'].size).to eq(5)
      expect(json['departments']).to all(include('level' => 'area'))
    end

    it 'returns all departments if level is not specified' do
      get url, params: { page: 1, per_page: 10 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['departments'].size).to eq(10)
    end

    it 'returns empty array if page is out of range' do
      get url, params: { page: 100, per_page: 10 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['departments']).to be_empty
    end
  end

  describe 'SHOW /api/v1/departments/:id' do
    it 'returns the hierarchy from the company root' do
      get "#{url}/#{area.id}"
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json['id']).to eq(company.id)
      expect(json['sub_departments'].first['id']).to eq(board.id)
      expect(json['sub_departments'].first['sub_departments'].first['id']).to eq(area.id)
    end

    it 'returns not found for non-existent department' do
      get "#{url}/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'CREATE /api/v1/departments' do
    it 'fails to create a company with a parent' do
      post url, params: {
        department: { name: 'Invalid Company', level: 'company', parent_id: board.id }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include('Parent must be blank for company-level departments')
    end

    it 'fails to create a non-company without parent' do
      post url, params: {
        department: { name: 'No Parent', level: 'board' }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include('Parent must be present for non-company departments')
    end

    it 'fails to create with invalid level' do
      expect do
        post url, params: {
          department: { name: 'Invalid Level', level: 'invalid_level', parent_id: company.id }
        }
      end.to raise_error(ArgumentError, /is not a valid level/)
    end
  end

  describe 'UPDATE /api/v1/departments/:id' do
    it 'fails to update company-level with a parent' do
      put "#{url}/#{board.id}", params: {
        department: { level: 'company', parent_id: company.id }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include('Parent must be blank for company-level departments')
    end

    it 'prevents changing level after creation' do
      put "#{url}/#{board.id}", params: {
        department: { level: 'management' }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include('Level cannot be changed after creation')
    end

    it 'prevents changing parent_id after creation' do
      other_company = create(:department, level: :company)
      put "#{url}/#{board.id}", params: {
        department: { parent_id: other_company.id }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include('Parent cannot be changed after creation')
    end
  end

  describe 'DESTROY /api/v1/departments/:id' do
    let!(:sub_dep) { create(:department, parent: board) }
    let!(:user) { create(:user, department: sub_dep) }

    it 'destroys the department and sub_department' do
      delete "#{url}/#{board.id}"
      expect(response).to have_http_status(:no_content)
      expect(Department.where(id: [board.id, sub_dep.id])).to be_empty
    end

    it 'nullifies department_id of associated users' do
      delete "#{url}/#{board.id}"
      expect(response).to have_http_status(:no_content)
      expect(user.reload.department_id).to be_nil
    end

    it 'returns not found if department does not exist' do
      delete "#{url}/999999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
