class User < ApplicationRecord
    enum :company_tenure, {
    less_than_one_year: 0,
    between_one_and_two_years: 1,
    between_two_and_five_years: 2,
    more_than_five_years: 3
  }

  enum :generation, {
    boomer: 0,
    gen_x: 1,
    gen_y: 2,
    gen_z: 3,
    gen_alpha: 4
  }

  enum :genre, { male: 0, female: 1, other: 2 }

  belongs_to :department
  has_many :survey_responses

  validates :company_email, presence: true, uniqueness: true
end
