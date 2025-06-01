FactoryBot.define do
  factory :department do
    name { Faker::Company.industry }
    level { rand(0..4) }
    parent { nil }

    trait :with_parent do
      association :parent, factory: :department
    end
  end
end
