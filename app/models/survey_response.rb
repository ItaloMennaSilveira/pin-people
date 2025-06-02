class SurveyResponse < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :interest_in_position, :contribution, :learning_and_development,
            :feedback, :manager_interaction, :career_clarity,
            :permanence_expectation, :enps,
            presence: true,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10 }

  scope :by_user_id, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_response_date_range, ->(start_date, end_date) {
    if start_date.present? && end_date.present?
      where(response_date: start_date..end_date)
    elsif start_date.present?
      where(response_date: start_date..Date.current)
    elsif end_date.present?
      where(response_date: (end_date.to_date - 1.year)..end_date)
    else
      all
    end
  }
end
