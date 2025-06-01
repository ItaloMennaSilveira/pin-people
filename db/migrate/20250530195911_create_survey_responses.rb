class CreateSurveyResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :survey_responses do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.date :response_date, index: true
      t.integer :interest_in_position
      t.text :comments_interest
      t.integer :contribution
      t.text :comments_contribution
      t.integer :learning_and_development
      t.text :comments_learning
      t.integer :feedback
      t.text :comments_feedback
      t.integer :manager_interaction
      t.text :comments_manager_interaction
      t.integer :career_clarity
      t.text :comments_career_clarity
      t.integer :permanence_expectation
      t.text :comments_permanence
      t.integer :enps
      t.text :comments_enps

      t.timestamps
    end
  end
end
