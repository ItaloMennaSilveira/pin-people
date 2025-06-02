require 'rails_helper'

RSpec.describe 'Api::V1::Departments', type: :request do
  let(:company) { create(:department, level: :company) }
  let(:board) { create(:department, level: :board, parent: company) }
  let(:area) { create(:department, level: :area, parent: board) }
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
    it 'creates a department successfully' do
      post url, params: {
        department: { name: 'New Area', level: 'area', parent_id: board.id }
      }
      expect(response).to have_http_status(:created)
    end

    it 'fails to create a company with a parent' do
      post url, params: {
        department: { name: 'Invalid Company', level: 'company', parent_id: board.id }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to include('cannot have a parent')
    end
  end

  describe 'UPDATE /api/v1/departments/:id' do
    it 'updates department successfully' do
      put "#{url}#{board.id}", params: {
        department: { name: 'Updated Board' }
      }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['name']).to eq('Updated Board')
    end

    it 'fails to update level company with parent' do
      put "#{url}#{board.id}", params: {
        department: { level: 'company', parent_id: company.id }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns not found if department does not exist' do
      put "#{url}/999999", params: {
        department: { name: 'Non-existent' }
      }
      expect(response).to have_http_status(:not_found)
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
