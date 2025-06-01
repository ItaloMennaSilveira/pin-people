class SurveyResponse < ApplicationRecord
  belongs_to :user

  validates :interest_in_position, :contribution, :learning_and_development,
            :feedback, :manager_interaction, :career_clarity,
            :permanence_expectation, :enps,
            presence: true,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10 }
end
