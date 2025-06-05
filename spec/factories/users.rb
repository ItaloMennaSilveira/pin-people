FactoryBot.define do
  factory :user do
    sequence(:name)  { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    company_email { |n| "user#{n}@company.com" }
    genre { :male }
    generation { :gen_z }
    company_tenure { :less_than_one_year }
    function { 'Employee' }
    position { 'Junior' }

    trait :with_department do
      after(:build) do |user|
        company = Department.find_by(level: :company) ||
                  Department.create!(name: 'Company Root', level: :company)

        department = Department.find_by(parent: company) ||
                     Department.create!(name: 'Departamento Filho', level: :department, parent: company)

        user.department = department
      end
    end
  end
end
