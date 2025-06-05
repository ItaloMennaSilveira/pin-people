require 'rails_helper'

RSpec.describe Department, type: :model do
  it { should define_enum_for(:level).with_values(%i[company board management coordination area]) }

  it { should have_many(:sub_departments).with_foreign_key('parent_id') }
  it { should belong_to(:parent).optional }
  it { should have_many(:department_users).with_foreign_key('department_id') }

  describe 'scopes' do
    describe '.by_level' do
      let!(:company) { create(:department, :company) }
      let!(:board)   { create(:department, :board, parent: company) }

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
      company = create(:department, :company)
      expect(company).to be_valid
      expect(company.level).to eq('company')
      expect(company.parent).to be_nil
    end

    it 'creates a full hierarchy down to the lowest level (area)' do
      company = create(:department, :company)
      board = create(:department, :board, parent: company)
      management = create(:department, :management, parent: board)
      coordination = create(:department, :coordination, parent: management)
      area = create(:department, :area, parent: coordination)

      expect(area.parent).to eq(coordination)
      expect(coordination.parent).to eq(management)
      expect(management.parent).to eq(board)
      expect(board.parent).to eq(company)

      expect(company.sub_departments).to include(board)
      expect(board.sub_departments).to include(management)
      expect(management.sub_departments).to include(coordination)
      expect(coordination.sub_departments).to include(area)
    end
  end

  describe '#root_department' do
    it 'returns the root company department' do
      company = create(:department, :company)
      department = create(:department, :board, parent: company)
      expect(department.root_department).to eq(company)
    end

    it 'returns self if it is a company' do
      company = create(:department, :company)
      expect(company.root_department).to eq(company)
    end
  end

  describe '#sub_departments_ids' do
    it 'returns the ids of all nested sub_departments recursively' do
      company = create(:department, :company)
      parent = create(:department, :board, parent: company)
      child1 = create(:department, :management, parent: parent)
      child2 = create(:department, :area, parent: child1)

      expect(parent.sub_departments_ids).to match_array([child1.id, child2.id])
    end
  end

  describe 'callbacks' do
    describe 'before_destroy' do
      it 'destroys sub_departments recursively' do
        company = create(:department, :company)
        board = create(:department, :board, parent: company)
        management = create(:department, :management, parent: board)

        company.destroy

        expect(Department.exists?(id: board.id)).to be_falsey
        expect(Department.exists?(id: management.id)).to be_falsey
      end

      it 'nullifies department_id of users from self and all descendants' do
        company = create(:department, :company)
        board = create(:department, :board, parent: company)
        user1 = create(:user, department: company)
        user2 = create(:user, department: board)

        company.destroy

        expect(user1.reload.department_id).to be_nil
        expect(user2.reload.department_id).to be_nil
      end
    end
  end

  describe 'before_save' do
    it 'does not set company_id when creating a company-level department' do
      department = create(:department, :company)
      expect(department.company_id).to be_nil
    end

    it 'sets company_id from parent recursively' do
      company = create(:department, :company)
      board = create(:department, :board, parent: company)
      expect(board.company_id).to eq(company.id)
    end
  end

  describe 'validations' do
    it 'is invalid if company-level has a parent' do
      parent = create(:department, :company)
      invalid_company = build(:department, :company, parent: parent)

      expect(invalid_company).to be_invalid
      expect(invalid_company.errors[:parent_id]).to include('must be blank for company-level departments')
    end

    it 'is invalid if non-company-level has no parent' do
      invalid_department = build(:department, :board, parent: nil)

      expect(invalid_department).to be_invalid
      expect(invalid_department.errors[:parent_id]).to include('must be present for non-company departments')
    end

    it 'is invalid if parent level is not higher (numerically lower)' do
      invalid_parent = create(:department, :area)
      invalid_child = build(:department, :board, parent: invalid_parent)

      expect(invalid_child).to be_invalid
      expect(invalid_child.errors[:parent_id]).to include('must be of higher level than the current department')
    end

    it 'is valid if parent level is higher (numerically lower)' do
      company = create(:department, :company)
      board = create(:department, :board, parent: company)
      management = build(:department, :management, parent: board)

      expect(management).to be_valid
    end

    context 'immutability on update' do
      let(:company) { create(:department, :company) }
      let(:department) { create(:department, :board, parent: company) }

      it 'prevents changing level' do
        department.level = :management
        expect(department.save).to be_falsey
        expect(department.errors[:level]).to include('cannot be changed after creation')
      end

      it 'prevents changing parent_id' do
        other = create(:department, :company)
        department.parent = other
        expect(department.save).to be_falsey
        expect(department.errors[:parent_id]).to include('cannot be changed after creation')
      end

      it 'prevents changing company_id manually' do
        department.company_id = 999
        expect(department.save).to be_falsey
        expect(department.errors[:company_id]).to include('cannot be changed after creation')
      end
    end
  end
end
