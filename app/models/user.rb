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

  belongs_to :department, optional: true
  has_many :survey_responses, dependent: :destroy

  validates :company_email, presence: true, uniqueness: true
  validate :department_must_exist_if_provided

  scope :by_department, ->(id) { where(department_id: id) if id.present? }
  scope :by_function, ->(function) { where(function: function) if function.present? }
  scope :by_position, ->(position) { where(position: position) if position.present? }
  scope :by_company_tenure, ->(tenure) { where(company_tenure: tenure) if tenure.present? }
  scope :by_genre, ->(genre) { where(genre: genre) if genre.present? }
  scope :by_generation, ->(generation) { where(generation: generation) if generation.present? }

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id company_tenure function genre generation department_id
      company_email city created_at updated_at name position id_value
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.average_interest_distribution
    averages = SurveyResponse.group(:user_id).average(:interest_in_position)

    distribution = {
      '1-2' => 0,
      '3-4' => 0,
      '5-6' => 0,
      '7-8' => 0,
      '9-10' => 0
    }

    averages.each_value do |score|
      case score
      when 1..2 then distribution['1-2'] += 1
      when 3..4 then distribution['3-4'] += 1
      when 5..6 then distribution['5-6'] += 1
      when 7..8 then distribution['7-8'] += 1
      when 9..10 then distribution['9-10'] += 1
      end
    end

    distribution
  end

  def department_must_exist_if_provided
    return if department_id.blank?

    return if Department.exists?(department_id)

    errors.add(:department_id, 'must reference a valid department')
  end
end
