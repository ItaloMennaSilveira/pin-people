require 'rails_helper'

RSpec.describe SurveyResponse, type: :model do
  it { should belong_to(:user) }

  %i[
    interest_in_position contribution learning_and_development
    feedback manager_interaction career_clarity permanence_expectation enps
  ].each do |attr|
    it { should validate_numericality_of(attr).only_integer.is_greater_than(0).is_less_than_or_equal_to(10) }
    it { should validate_presence_of(attr) }
  end
end
