require 'rails_helper'

RSpec.describe Department, type: :model do
  it { should define_enum_for(:level) }

  it { should have_many(:sub_departments) }
  it { should belong_to(:parent).optional }
  it { should have_many(:department_users) }

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
end
