require 'rails_helper'

RSpec.describe User, type: :model do
  subject do
    FactoryBot.create(:user, department: FactoryBot.create(:department))
  end

  it { should validate_presence_of(:company_email) }
  it { should validate_uniqueness_of(:company_email) }

  it { should belong_to(:department) }
  it { should have_many(:survey_responses) }

  it { should define_enum_for(:company_tenure) }
  it { should define_enum_for(:genre) }
  it { should define_enum_for(:generation) }
end
