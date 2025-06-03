FactoryBot.define do
  factory :survey_response do
    association :user
    response_date { Faker::Date.backward(days: 365) }

    interest_in_position { Faker::Number.between(from: 0, to: 10) }
    comments_interest { Faker::Lorem.sentence }

    contribution { Faker::Number.between(from: 0, to: 10) }
    comments_contribution { Faker::Lorem.sentence }

    learning_and_development { Faker::Number.between(from: 0, to: 10) }
    comments_learning { Faker::Lorem.sentence }

    feedback { Faker::Number.between(from: 0, to: 10) }
    comments_feedback { Faker::Lorem.sentence }

    manager_interaction { Faker::Number.between(from: 0, to: 10) }
    comments_manager_interaction { Faker::Lorem.sentence }

    career_clarity { Faker::Number.between(from: 0, to: 10) }
    comments_career_clarity { Faker::Lorem.sentence }

    permanence_expectation { Faker::Number.between(from: 0, to: 10) }
    comments_permanence { Faker::Lorem.sentence }

    enps { Faker::Number.between(from: 0, to: 10) }
    comments_enps { Faker::Lorem.paragraph }
  end
end
