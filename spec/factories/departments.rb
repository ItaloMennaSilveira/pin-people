FactoryBot.define do
  factory :department do
    name { Faker::Company.name }
    level { :area }

    trait :company do
      level { :company }
      parent { nil }
    end

    trait :board do
      level { :board }
      association :parent, factory: %i[department company]
    end

    trait :management do
      level { :management }
      association :parent, factory: %i[department board]
    end

    trait :coordination do
      level { :coordination }
      association :parent, factory: %i[department management]
    end

    trait :area do
      level { :area }
      association :parent, factory: %i[department coordination]
    end

    trait :full_hierarchy do
      after(:create) do |area|
        company = create(:department, :company)
        board = create(:department, :board, parent: company)
        management = create(:department, :management, parent: board)
        coordination = create(:department, :coordination, parent: management)
        area.update(parent: coordination)
      end
    end
  end
end
