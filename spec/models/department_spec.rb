require 'rails_helper'

RSpec.describe Department, type: :model do
  it { should define_enum_for(:level) }

  it { should have_many(:sub_departments) }
  it { should belong_to(:parent).optional }
  it { should have_many(:department_users) }
end
