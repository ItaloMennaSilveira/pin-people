class SurveyResponse < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :interest_in_position, :contribution, :learning_and_development,
            :feedback, :manager_interaction, :career_clarity,
            :permanence_expectation, :enps,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  validate :response_date_cannot_be_in_future

  scope :by_user_id, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_response_date_range, lambda { |start_date, end_date|
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

  private

  def response_date_cannot_be_in_future
    if response_date.present? && response_date > Date.today
      errors.add(:response_date, "must not be in the future")
    end
  end
end
