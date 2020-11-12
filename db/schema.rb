# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_09_135332) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "degrees", force: :cascade do |t|
    t.integer "locale_code", null: false
    t.string "uk_degree"
    t.string "non_uk_degree"
    t.bigint "trainee_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "subject"
    t.string "institution"
    t.integer "graduation_year"
    t.string "grade"
    t.string "country"
    t.index ["locale_code"], name: "index_degrees_on_locale_code"
    t.index ["trainee_id"], name: "index_degrees_on_trainee_id"
  end

  create_table "disabilities", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_disabilities_on_name", unique: true
  end

  create_table "nationalisations", force: :cascade do |t|
    t.bigint "trainee_id", null: false
    t.bigint "nationality_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nationality_id"], name: "index_nationalisations_on_nationality_id"
    t.index ["trainee_id"], name: "index_nationalisations_on_trainee_id"
  end

  create_table "nationalities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_nationalities_on_name", unique: true
  end

  create_table "providers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trainee_disabilities", force: :cascade do |t|
    t.bigint "trainee_id", null: false
    t.bigint "disability_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disability_id"], name: "index_trainee_disabilities_on_disability_id"
    t.index ["trainee_id"], name: "index_trainee_disabilities_on_trainee_id"
  end

  create_table "trainees", force: :cascade do |t|
    t.text "trainee_id"
    t.text "first_names"
    t.text "last_name"
    t.date "date_of_birth"
    t.text "ethnicity"
    t.text "disability"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "address_line_one"
    t.text "address_line_two"
    t.text "town_city"
    t.text "county"
    t.text "postcode"
    t.text "phone_number"
    t.text "email"
    t.date "start_date"
    t.text "full_time_part_time"
    t.boolean "teaching_scholars"
    t.uuid "dttp_id"
    t.text "middle_names"
    t.integer "record_type"
    t.text "international_address"
    t.integer "locale_code"
    t.integer "gender"
    t.integer "diversity_disclosure"
    t.integer "ethnic_group"
    t.text "ethnic_background"
    t.text "additional_ethnic_background"
    t.integer "disability_disclosure"
    t.text "subject"
    t.text "age_range"
    t.date "programme_start_date"
    t.jsonb "progress", default: {}
    t.index ["disability_disclosure"], name: "index_trainees_on_disability_disclosure"
    t.index ["diversity_disclosure"], name: "index_trainees_on_diversity_disclosure"
    t.index ["dttp_id"], name: "index_trainees_on_dttp_id"
    t.index ["ethnic_group"], name: "index_trainees_on_ethnic_group"
    t.index ["gender"], name: "index_trainees_on_gender"
    t.index ["locale_code"], name: "index_trainees_on_locale_code"
    t.index ["progress"], name: "index_trainees_on_progress", using: :gin
    t.index ["record_type"], name: "index_trainees_on_record_type"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.bigint "provider_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["provider_id"], name: "index_users_on_provider_id"
  end

  add_foreign_key "degrees", "trainees"
  add_foreign_key "nationalisations", "nationalities"
  add_foreign_key "nationalisations", "trainees"
  add_foreign_key "trainee_disabilities", "disabilities"
  add_foreign_key "trainee_disabilities", "trainees"
  add_foreign_key "users", "providers"
end
