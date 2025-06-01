FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    company_email { Faker::Internet.unique.email(domain: 'empresa.com') }
    position { Faker::Job.position }
    function { Faker::Job.field }
    city { Faker::Address.city }
    company_tenure { User.company_tenures.keys.sample }
    genre { User.genres.keys.sample }
    generation { User.generations.keys.sample }

    association :department
  end
end
