require 'rails_helper'

RSpec.describe User, type: :model do
  subject do
    FactoryBot.create(:user, department: FactoryBot.create(:department))
  end

  it { should validate_presence_of(:company_email) }
  it { should validate_uniqueness_of(:company_email) }

  it { should belong_to(:department) }
  it { should have_many(:survey_responses).dependent(:destroy) }

  it { should define_enum_for(:company_tenure) }
  it { should define_enum_for(:genre) }
  it { should define_enum_for(:generation) }

  describe "scopes" do
    let(:department_1) { create(:department) }
    let(:department_2) { create(:department) }

    let!(:user_1) do
      create(:user,
        department: department_1,
        function: "Developer",
        position: "Senior",
        company_tenure: User.company_tenures['more_than_five_years'],
        genre: User.genres['male'],
        generation: User.generations['gen_y']
      )
    end

    let!(:user_2) do
      create(:user,
        department: department_2,
        function: "Designer",
        position: "Junior",
        company_tenure: User.company_tenures['less_than_one_year'],
        genre: User.genres['female'],
        generation: User.generations['gen_z']
      )
    end

    it "filters by department" do
      expect(User.by_department(department_1.id)).to include(user_1)
      expect(User.by_department(department_1.id)).not_to include(user_2)
    end

    it "filters by function" do
      expect(User.by_function("Developer")).to include(user_1)
      expect(User.by_function("Developer")).not_to include(user_2)
    end

    it "filters by position" do
      expect(User.by_position("Senior")).to include(user_1)
      expect(User.by_position("Senior")).not_to include(user_2)
    end

    it "filters by company_tenure" do
      expect(User.by_company_tenure("more_than_five_years")).to include(user_1)
      expect(User.by_company_tenure("more_than_five_years")).not_to include(user_2)
    end

    it "filters by genre" do
      expect(User.by_genre("male")).to include(user_1)
      expect(User.by_genre("male")).not_to include(user_2)
    end

    it "filters by generation" do
      expect(User.by_generation("gen_y")).to include(user_1)
      expect(User.by_generation("gen_y")).not_to include(user_2)
    end
  end

  describe "destroying user" do
    it "destroys associated survey responses" do
      user = create(:user)
      create_list(:survey_response, 3, user: user)

      expect { user.destroy }.to change { SurveyResponse.count }.by(-3)
    end
  end
end
