require 'rails_helper'

RSpec.describe Department, type: :model do
  it { should define_enum_for(:level).with_values(%i[company board management coordination area]) }

  it { should have_many(:sub_departments).with_foreign_key('parent_id') }
  it { should belong_to(:parent).optional }
  it { should have_many(:department_users).with_foreign_key('department_id') }

  describe 'scopes' do
    describe '.by_level' do
      let!(:company) { create(:department, level: :company) }
      let!(:board)   { create(:department, level: :board) }

      it 'returns departments with given level' do
        expect(Department.by_level(:company)).to match_array([company])
      end

      it 'returns all departments if level is nil' do
        expect(Department.by_level(nil)).to match_array([company, board])
      end
    end
  end

  describe 'hierarchy levels' do
    it 'creates a department with the highest level (company)' do
      company = create(:department, name: 'Acme Corp', level: :company)
      expect(company).to be_valid
      expect(company.level).to eq('company')
    end

    it 'creates a full hierarchy down to the lowest level (area)' do
      company = create(:department, name: 'Company', level: :company)
      board = create(:department, name: 'Board', level: :board, parent: company)
      management = create(:department, name: 'Management', level: :management, parent: board)
      coordination = create(:department, name: 'Coordination', level: :coordination, parent: management)
      area = create(:department, name: 'Area', level: :area, parent: coordination)

      expect(area.parent).to eq(coordination)
      expect(coordination.parent).to eq(management)
      expect(management.parent).to eq(board)
      expect(board.parent).to eq(company)

      expect(company.sub_departments).to include(board)
      expect(board.sub_departments).to include(management)
    end
  end

  describe '#root_department' do
    it 'returns the root company department' do
      company = create(:department, level: :company)
      department = create(:department, level: :board, company_id: company.id, parent_id: company.id)
      expect(department.root_department).to eq(company)
    end

    it 'returns self if it is a company' do
      company = create(:department, level: :company)
      expect(company.root_department).to eq(company)
    end
  end

  describe '#sub_departments_ids' do
    it 'returns the ids of all nested sub_departments recursively' do
      parent = create(:department)
      child1 = create(:department, parent: parent)
      child2 = create(:department, parent: child1)
      expect(parent.sub_departments_ids).to match_array([child1.id, child2.id])
    end
  end

  describe 'callbacks' do
    describe 'before_destroy' do
      it 'destroys sub_departments' do
        parent = create(:department)
        child = create(:department, parent: parent)

        parent.destroy

        expect(Department.exists?(id: child.id)).to be_falsey
      end

      it 'nullifies department_id of users' do
        department = create(:department)
        user = create(:user, department: department)

        department.destroy

        expect(user.reload.department_id).to be_nil
      end
    end
  end

  describe 'before_save' do
    it 'does not set company_id when creating a company-level department' do
      department = create(:department, level: :company)
      expect(department.company_id).to be_nil
    end

    it 'sets company_id from parent recursively' do
      company = create(:department, level: :company)
      board = create(:department, level: :board, parent: company)
      expect(board.company_id).to eq(company.id)
    end
  end
end
