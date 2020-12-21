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

ActiveRecord::Schema.define(version: 2020_12_21_194423) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "degrees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trainee_id", null: false
    t.integer "locale_code", null: false
    t.string "uk_degree"
    t.string "non_uk_degree"
    t.string "subject", null: false
    t.string "institution"
    t.integer "graduation_year", null: false
    t.string "grade"
    t.string "country"
    t.text "other_grade"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["locale_code"], name: "index_degrees_on_locale_code"
    t.index ["trainee_id"], name: "index_degrees_on_trainee_id"
  end

  create_table "disabilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_disabilities_on_name", unique: true
  end

  create_table "nationalisations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trainee_id", null: false
    t.uuid "nationality_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nationality_id"], name: "index_nationalisations_on_nationality_id"
    t.index ["trainee_id"], name: "index_nationalisations_on_trainee_id"
  end

  create_table "nationalities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_nationalities_on_name", unique: true
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "dttp_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trainee_disabilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trainee_id", null: false
    t.uuid "disability_id", null: false
    t.text "additional_disability"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disability_id"], name: "index_trainee_disabilities_on_disability_id"
    t.index ["trainee_id"], name: "index_trainee_disabilities_on_trainee_id"
  end

  create_table "trainees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "provider_id", null: false
    t.uuid "dttp_id"
    t.uuid "placement_assignment_dttp_id"
    t.text "trainee_id"
    t.text "first_names"
    t.text "middle_names"
    t.text "last_name"
    t.integer "gender"
    t.date "date_of_birth"
    t.text "nationality"
    t.text "address_line_one"
    t.text "address_line_two"
    t.text "town_city"
    t.text "postcode"
    t.text "international_address"
    t.text "email"
    t.integer "ethnic_group"
    t.text "ethnic_background"
    t.text "additional_ethnic_background"
    t.text "subject"
    t.text "age_range"
    t.integer "record_type"
    t.integer "locale_code"
    t.integer "diversity_disclosure"
    t.text "ethnicity"
    t.text "disability"
    t.integer "disability_disclosure"
    t.date "outcome_date"
    t.date "programme_start_date"
    t.date "programme_end_date"
    t.string "trn"
    t.datetime "submitted_for_trn_at"
    t.integer "withdraw_reason"
    t.date "withdraw_date"
    t.date "defer_date"
    t.string "additional_withdraw_reason"
    t.integer "state", default: 0
    t.jsonb "progress", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disability_disclosure"], name: "index_trainees_on_disability_disclosure"
    t.index ["diversity_disclosure"], name: "index_trainees_on_diversity_disclosure"
    t.index ["dttp_id"], name: "index_trainees_on_dttp_id"
    t.index ["ethnic_group"], name: "index_trainees_on_ethnic_group"
    t.index ["gender"], name: "index_trainees_on_gender"
    t.index ["locale_code"], name: "index_trainees_on_locale_code"
    t.index ["progress"], name: "index_trainees_on_progress", using: :gin
    t.index ["provider_id"], name: "index_trainees_on_provider_id"
    t.index ["record_type"], name: "index_trainees_on_record_type"
    t.index ["state"], name: "index_trainees_on_state"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "provider_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "dfe_sign_in_uid"
    t.datetime "last_signed_in_at"
    t.uuid "dttp_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dfe_sign_in_uid"], name: "index_users_on_dfe_sign_in_uid", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["provider_id"], name: "index_users_on_provider_id"
  end

  add_foreign_key "degrees", "trainees"
  add_foreign_key "nationalisations", "nationalities"
  add_foreign_key "nationalisations", "trainees"
  add_foreign_key "trainee_disabilities", "disabilities"
  add_foreign_key "trainee_disabilities", "trainees"
  add_foreign_key "trainees", "providers"
  add_foreign_key "users", "providers"
end
