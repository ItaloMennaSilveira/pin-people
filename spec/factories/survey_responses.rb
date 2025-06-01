FactoryBot.define do
  factory :survey_response do
    association :user
    response_date { Faker::Date.backward(days: 365) }

    interest_in_position { rand(1..10) }
    comments_interest { Faker::Lorem.sentence }

    contribution { rand(1..10) }
    comments_contribution { Faker::Lorem.sentence }

    learning_and_development { rand(1..10) }
    comments_learning { Faker::Lorem.sentence }

    feedback { rand(1..10) }
    comments_feedback { Faker::Lorem.sentence }

    manager_interaction { rand(1..10) }
    comments_manager_interaction { Faker::Lorem.sentence }

    career_clarity { rand(1..10) }
    comments_career_clarity { Faker::Lorem.sentence }

    permanence_expectation { rand(1..10) }
    comments_permanence { Faker::Lorem.sentence }

    enps { rand(0..10) }
    comments_enps { Faker::Lorem.paragraph }
  end
end
