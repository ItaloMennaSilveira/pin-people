# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_02_172355) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.integer "level"
    t.bigint "parent_id"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_departments_on_company_id"
    t.index ["level"], name: "index_departments_on_level"
    t.index ["parent_id"], name: "index_departments_on_parent_id"
  end

  create_table "survey_responses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "response_date"
    t.integer "interest_in_position"
    t.text "comments_interest"
    t.integer "contribution"
    t.text "comments_contribution"
    t.integer "learning_and_development"
    t.text "comments_learning"
    t.integer "feedback"
    t.text "comments_feedback"
    t.integer "manager_interaction"
    t.text "comments_manager_interaction"
    t.integer "career_clarity"
    t.text "comments_career_clarity"
    t.integer "permanence_expectation"
    t.text "comments_permanence"
    t.integer "enps"
    t.text "comments_enps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["response_date"], name: "index_survey_responses_on_response_date"
    t.index ["user_id"], name: "index_survey_responses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "company_email"
    t.string "position"
    t.string "function"
    t.string "city"
    t.integer "company_tenure"
    t.integer "genre"
    t.integer "generation"
    t.bigint "department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_email"], name: "index_users_on_company_email", unique: true
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "departments", "departments", column: "company_id"
  add_foreign_key "departments", "departments", column: "parent_id"
  add_foreign_key "survey_responses", "users"
  add_foreign_key "users", "departments"
end
