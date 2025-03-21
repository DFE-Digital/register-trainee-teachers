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

ActiveRecord::Schema[7.2].define(version: 2025_03_21_143706) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "future_interest_type", ["yes", "no", "unknown"]
  create_enum "trigger_type", ["provider", "trainee"]

  create_table "academic_cycles", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "tsrange((start_date)::timestamp without time zone, (end_date)::timestamp without time zone)", name: "academic_cycles_date_range", using: :gist
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "controller_name"
    t.string "action_name"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "allocation_subjects", force: :cascade do |t|
    t.citext "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dttp_id"
    t.date "deprecated_on"
    t.index ["dttp_id"], name: "index_allocation_subjects_on_dttp_id", unique: true
    t.index ["name"], name: "index_allocation_subjects_on_name", unique: true
  end

  create_table "apply_application_sync_requests", force: :cascade do |t|
    t.integer "response_code"
    t.boolean "successful"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recruitment_cycle_year"
    t.index ["recruitment_cycle_year"], name: "index_apply_application_sync_requests_on_recruitment_cycle_year"
  end

  create_table "apply_applications", force: :cascade do |t|
    t.integer "apply_id", null: false
    t.jsonb "application"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "invalid_data"
    t.integer "state"
    t.string "accredited_body_code"
    t.integer "recruitment_cycle_year"
    t.index ["accredited_body_code"], name: "index_apply_applications_on_accredited_body_code"
    t.index ["apply_id"], name: "index_apply_applications_on_apply_id", unique: true
    t.index ["recruitment_cycle_year"], name: "index_apply_applications_on_recruitment_cycle_year"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at", precision: nil
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "authentication_tokens", force: :cascade do |t|
    t.string "hashed_token", null: false
    t.boolean "enabled", default: true, null: false
    t.bigint "provider_id", null: false
    t.date "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.datetime "revoked_at"
    t.datetime "last_used_at"
    t.bigint "created_by_id"
    t.bigint "revoked_by_id"
    t.string "status", default: "active"
    t.index ["created_by_id"], name: "index_authentication_tokens_on_created_by_id"
    t.index ["hashed_token"], name: "index_authentication_tokens_on_hashed_token", unique: true
    t.index ["provider_id"], name: "index_authentication_tokens_on_provider_id"
    t.index ["revoked_by_id"], name: "index_authentication_tokens_on_revoked_by_id"
    t.index ["status", "last_used_at"], name: "index_authentication_tokens_on_status_and_last_used_at"
    t.index ["status"], name: "index_authentication_tokens_on_status"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at", precision: nil
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "bulk_update_placement_rows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state", default: 0, null: false
    t.bigint "bulk_update_placement_id", null: false
    t.integer "csv_row_number", null: false
    t.string "urn", null: false
    t.string "trn", null: false
    t.bigint "school_id"
    t.index ["bulk_update_placement_id"], name: "index_bulk_update_placement_rows_on_bulk_update_placement_id"
    t.index ["school_id"], name: "index_bulk_update_placement_rows_on_school_id"
  end

  create_table "bulk_update_placements", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_bulk_update_placements_on_provider_id"
  end

  create_table "bulk_update_recommendations_upload_rows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bulk_update_recommendations_upload_id", null: false
    t.integer "csv_row_number"
    t.string "trn"
    t.string "hesa_id"
    t.date "standards_met_at"
    t.string "provider_trainee_id"
    t.string "last_names"
    t.string "first_names"
    t.string "qts_or_eyts"
    t.string "route"
    t.string "phase"
    t.string "age_range"
    t.string "subject"
    t.bigint "matched_trainee_id"
    t.string "lead_partner"
    t.index ["bulk_update_recommendations_upload_id"], name: "idx_bu_ru_rows_on_bu_recommendations_upload_id"
    t.index ["matched_trainee_id"], name: "idx_bu_recommendations_upload_rows_on_matched_trainee_id"
  end

  create_table "bulk_update_recommendations_uploads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "provider_id", null: false
    t.index ["provider_id"], name: "index_bulk_update_recommendations_uploads_on_provider_id"
  end

  create_table "bulk_update_row_errors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "errored_on_id"
    t.string "errored_on_type"
    t.string "message"
    t.string "error_type", default: "validation", null: false
    t.index ["error_type"], name: "index_bulk_update_row_errors_on_error_type"
    t.index ["errored_on_id", "errored_on_type"], name: "idx_on_errored_on_id_errored_on_type_492045ed60"
  end

  create_table "bulk_update_trainee_upload_rows", force: :cascade do |t|
    t.bigint "bulk_update_trainee_upload_id", null: false
    t.integer "row_number", null: false
    t.jsonb "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bulk_update_trainee_upload_id", "row_number"], name: "index_bulk_update_trainee_upload_rows_on_upload_and_row_number", unique: true
    t.index ["bulk_update_trainee_upload_id"], name: "idx_on_bulk_update_trainee_upload_id_21ca71cc91"
  end

  create_table "bulk_update_trainee_uploads", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "status", default: "uploaded"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
    t.bigint "submitted_by_id"
    t.integer "number_of_trainees", default: 0, null: false
    t.index ["provider_id"], name: "index_bulk_update_trainee_uploads_on_provider_id"
    t.index ["status"], name: "index_bulk_update_trainee_uploads_on_status"
    t.index ["submitted_by_id"], name: "index_bulk_update_trainee_uploads_on_submitted_by_id"
  end

  create_table "course_subjects", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "subject_id"], name: "index_course_subjects_on_course_id_and_subject_id", unique: true
    t.index ["course_id"], name: "index_course_subjects_on_course_id"
    t.index ["subject_id"], name: "index_course_subjects_on_subject_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "published_start_date", null: false
    t.integer "duration_in_years", null: false
    t.string "course_length"
    t.integer "qualification", null: false
    t.integer "route", null: false
    t.string "summary", null: false
    t.integer "level", null: false
    t.string "accredited_body_code", null: false
    t.integer "min_age"
    t.integer "max_age"
    t.integer "study_mode"
    t.uuid "uuid"
    t.integer "recruitment_cycle_year"
    t.date "full_time_start_date"
    t.date "full_time_end_date"
    t.date "part_time_start_date"
    t.date "part_time_end_date"
    t.index ["code", "accredited_body_code"], name: "index_courses_on_code_and_accredited_body_code"
    t.index ["recruitment_cycle_year"], name: "index_courses_on_recruitment_cycle_year"
    t.index ["uuid"], name: "index_courses_on_uuid", unique: true
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "degrees", force: :cascade do |t|
    t.integer "locale_code", null: false
    t.string "uk_degree"
    t.string "non_uk_degree"
    t.bigint "trainee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject"
    t.string "institution"
    t.integer "graduation_year"
    t.string "grade"
    t.string "country"
    t.text "other_grade"
    t.citext "slug", null: false
    t.uuid "dttp_id"
    t.uuid "institution_uuid"
    t.uuid "uk_degree_uuid"
    t.uuid "subject_uuid"
    t.uuid "grade_uuid"
    t.index ["dttp_id"], name: "index_degrees_on_dttp_id"
    t.index ["locale_code"], name: "index_degrees_on_locale_code"
    t.index ["slug"], name: "index_degrees_on_slug", unique: true
    t.index ["trainee_id"], name: "index_degrees_on_trainee_id"
  end

  create_table "disabilities", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.index ["name"], name: "index_disabilities_on_name", unique: true
  end

  create_table "dqt_teacher_trainings", force: :cascade do |t|
    t.bigint "dqt_teacher_id"
    t.string "programme_start_date"
    t.string "programme_end_date"
    t.string "programme_type"
    t.string "result"
    t.string "provider_ukprn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hesa_id"
    t.boolean "active"
    t.index ["dqt_teacher_id"], name: "index_dqt_teacher_trainings_on_dqt_teacher_id"
  end

  create_table "dqt_teachers", force: :cascade do |t|
    t.string "trn"
    t.string "first_name"
    t.string "last_name"
    t.string "date_of_birth"
    t.string "qts_date"
    t.string "eyts_date"
    t.string "early_years_status_name"
    t.string "early_years_status_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hesa_id"
    t.boolean "allowed_pii_updates", default: false, null: false
    t.index ["allowed_pii_updates"], name: "index_dqt_teachers_on_allowed_pii_updates"
  end

  create_table "dqt_trn_requests", force: :cascade do |t|
    t.bigint "trainee_id", null: false
    t.uuid "request_id", null: false
    t.jsonb "response"
    t.integer "state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_dqt_trn_requests_on_request_id", unique: true
    t.index ["trainee_id"], name: "index_dqt_trn_requests_on_trainee_id"
  end

  create_table "dttp_accounts", force: :cascade do |t|
    t.uuid "dttp_id"
    t.string "ukprn"
    t.string "name"
    t.jsonb "response"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "urn"
    t.string "accreditation_id"
    t.index ["accreditation_id"], name: "index_dttp_accounts_on_accreditation_id"
    t.index ["dttp_id"], name: "index_dttp_accounts_on_dttp_id", unique: true
    t.index ["ukprn"], name: "index_dttp_accounts_on_ukprn"
    t.index ["urn"], name: "index_dttp_accounts_on_urn"
  end

  create_table "dttp_bursary_details", force: :cascade do |t|
    t.jsonb "response"
    t.uuid "dttp_id", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_bursary_details_on_dttp_id", unique: true
  end

  create_table "dttp_degree_qualifications", force: :cascade do |t|
    t.jsonb "response"
    t.integer "state", default: 0
    t.uuid "dttp_id", null: false
    t.uuid "contact_dttp_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_degree_qualifications_on_dttp_id", unique: true
  end

  create_table "dttp_dormant_periods", force: :cascade do |t|
    t.jsonb "response"
    t.uuid "dttp_id", null: false
    t.uuid "placement_assignment_dttp_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_dormant_periods_on_dttp_id", unique: true
  end

  create_table "dttp_placement_assignments", force: :cascade do |t|
    t.jsonb "response"
    t.uuid "dttp_id", null: false
    t.uuid "contact_dttp_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "provider_dttp_id"
    t.uuid "academic_year"
    t.date "programme_start_date"
    t.date "programme_end_date"
    t.uuid "trainee_status"
    t.index ["dttp_id"], name: "index_dttp_placement_assignments_on_dttp_id", unique: true
  end

  create_table "dttp_providers", force: :cascade do |t|
    t.string "name"
    t.uuid "dttp_id"
    t.string "ukprn"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "response"
    t.index ["dttp_id"], name: "index_dttp_providers_on_dttp_id", unique: true
  end

  create_table "dttp_schools", force: :cascade do |t|
    t.string "name"
    t.string "dttp_id"
    t.string "urn"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "status_code"
    t.index ["dttp_id"], name: "index_dttp_schools_on_dttp_id", unique: true
  end

  create_table "dttp_trainees", force: :cascade do |t|
    t.jsonb "response"
    t.integer "state", default: 0
    t.uuid "dttp_id", null: false
    t.uuid "provider_dttp_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "status"
    t.index ["dttp_id"], name: "index_dttp_trainees_on_dttp_id", unique: true
  end

  create_table "dttp_training_initiatives", force: :cascade do |t|
    t.jsonb "response"
    t.uuid "dttp_id", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_training_initiatives_on_dttp_id", unique: true
  end

  create_table "dttp_users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "dttp_id"
    t.string "provider_dttp_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_users_on_dttp_id", unique: true
  end

  create_table "funding_method_subjects", force: :cascade do |t|
    t.bigint "funding_method_id"
    t.bigint "allocation_subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allocation_subject_id", "funding_method_id"], name: "index_funding_methods_subjects_on_ids", unique: true
    t.index ["allocation_subject_id"], name: "index_funding_method_subjects_on_allocation_subject_id"
    t.index ["funding_method_id"], name: "index_funding_method_subjects_on_funding_method_id"
  end

  create_table "funding_methods", force: :cascade do |t|
    t.string "training_route", null: false
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "funding_type"
    t.bigint "academic_cycle_id"
    t.index ["academic_cycle_id"], name: "index_funding_methods_on_academic_cycle_id"
  end

  create_table "funding_payment_schedule_row_amounts", force: :cascade do |t|
    t.integer "funding_payment_schedule_row_id"
    t.integer "month"
    t.integer "year"
    t.integer "amount_in_pence"
    t.boolean "predicted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["funding_payment_schedule_row_id"], name: "index_payment_schedule_row_amounts_on_payment_schedule_row_id"
  end

  create_table "funding_payment_schedule_rows", force: :cascade do |t|
    t.integer "funding_payment_schedule_id"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["funding_payment_schedule_id"], name: "index_payment_schedule_rows_on_funding_payment_schedule_id"
  end

  create_table "funding_payment_schedules", force: :cascade do |t|
    t.integer "payable_id"
    t.string "payable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payable_id", "payable_type"], name: "index_funding_payment_schedules_on_payable_id_and_payable_type"
  end

  create_table "funding_trainee_summaries", force: :cascade do |t|
    t.integer "payable_id"
    t.string "payable_type"
    t.string "academic_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payable_id", "payable_type"], name: "index_funding_trainee_summaries_on_payable_id_and_payable_type"
  end

  create_table "funding_trainee_summary_row_amounts", force: :cascade do |t|
    t.integer "funding_trainee_summary_row_id"
    t.integer "payment_type"
    t.integer "tier"
    t.integer "amount_in_pence"
    t.integer "number_of_trainees"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["funding_trainee_summary_row_id"], name: "index_trainee_summary_row_amounts_on_trainee_summary_row_id"
  end

  create_table "funding_trainee_summary_rows", force: :cascade do |t|
    t.integer "funding_trainee_summary_id"
    t.string "subject"
    t.string "route"
    t.string "lead_school_name"
    t.string "lead_school_urn"
    t.string "cohort_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lead_partner_urn"
    t.string "training_route"
    t.string "lead_partner_name"
    t.index ["funding_trainee_summary_id"], name: "index_trainee_summary_rows_on_trainee_summary_id"
  end

  create_table "funding_uploads", force: :cascade do |t|
    t.integer "month"
    t.integer "funding_type"
    t.integer "status", default: 0
    t.text "csv_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["funding_type"], name: "index_funding_uploads_on_funding_type"
    t.index ["month"], name: "index_funding_uploads_on_month"
    t.index ["status"], name: "index_funding_uploads_on_status"
  end

  create_table "hesa_collection_requests", force: :cascade do |t|
    t.string "collection_reference"
    t.datetime "requested_at", precision: nil
    t.text "response_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state"
    t.index ["state"], name: "index_hesa_collection_requests_on_state"
  end

  create_table "hesa_metadata", force: :cascade do |t|
    t.bigint "trainee_id"
    t.integer "study_length"
    t.string "study_length_unit"
    t.string "itt_aim"
    t.string "itt_qualification_aim"
    t.string "fundability"
    t.string "service_leaver"
    t.string "course_programme_title"
    t.integer "placement_school_urn"
    t.date "pg_apprenticeship_start_date"
    t.string "year_of_course"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trainee_id"], name: "index_hesa_metadata_on_trainee_id"
  end

  create_table "hesa_students", force: :cascade do |t|
    t.string "hesa_id"
    t.string "first_names"
    t.string "last_name"
    t.string "email"
    t.string "date_of_birth"
    t.string "ethnic_background"
    t.string "sex"
    t.string "ukprn"
    t.string "course_subject_one"
    t.string "course_subject_two"
    t.string "course_subject_three"
    t.string "itt_end_date"
    t.string "employing_school_urn"
    t.string "mode"
    t.string "course_age_range"
    t.string "training_initiative"
    t.string "disability1"
    t.string "end_date"
    t.string "reason_for_leaving"
    t.string "bursary_level"
    t.string "trn"
    t.string "training_route"
    t.string "nationality"
    t.string "hesa_updated_at"
    t.string "itt_aim"
    t.string "itt_qualification_aim"
    t.string "fund_code"
    t.string "study_length"
    t.string "study_length_unit"
    t.string "service_leaver"
    t.string "course_programme_title"
    t.string "pg_apprenticeship_start_date"
    t.string "year_of_course"
    t.json "degrees"
    t.json "placements"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "collection_reference"
    t.string "commencement_date"
    t.string "itt_commencement_date"
    t.string "disability2"
    t.string "disability3"
    t.string "disability4"
    t.string "disability5"
    t.string "disability6"
    t.string "disability7"
    t.string "disability8"
    t.string "disability9"
    t.string "itt_key"
    t.string "rec_id"
    t.string "status"
    t.string "allocated_place"
    t.string "provider_course_id"
    t.string "initiatives_two"
    t.string "ni_number"
    t.string "numhus"
    t.string "previous_surname"
    t.string "surname16"
    t.string "ttcid"
    t.string "hesa_committed_at"
    t.string "application_choice_id"
    t.string "itt_start_date"
    t.string "trainee_start_date"
    t.string "previous_hesa_id"
    t.string "provider_trainee_id"
    t.string "lead_partner_urn"
    t.index ["hesa_id", "rec_id"], name: "index_hesa_students_on_hesa_id_and_rec_id", unique: true
  end

  create_table "hesa_trainee_details", force: :cascade do |t|
    t.bigint "trainee_id", null: false
    t.string "previous_last_name"
    t.string "itt_aim"
    t.string "course_study_mode"
    t.integer "course_year"
    t.string "course_age_range"
    t.date "pg_apprenticeship_start_date"
    t.string "funding_method"
    t.string "ni_number"
    t.string "additional_training_initiative"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "itt_qualification_aim"
    t.string "fund_code"
    t.jsonb "hesa_disabilities", default: {}
    t.index ["trainee_id"], name: "index_hesa_trainee_details_on_trainee_id"
  end

  create_table "hesa_trn_requests", force: :cascade do |t|
    t.string "collection_reference"
    t.integer "state"
    t.text "response_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hesa_trn_submissions", force: :cascade do |t|
    t.text "payload"
    t.datetime "submitted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lead_partner_users", force: :cascade do |t|
    t.bigint "lead_partner_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_partner_id"], name: "index_lead_partner_users_on_lead_partner_id"
    t.index ["user_id"], name: "index_lead_partner_users_on_user_id"
  end

  create_table "lead_partners", force: :cascade do |t|
    t.citext "urn"
    t.string "record_type", null: false
    t.string "name"
    t.citext "ukprn"
    t.bigint "school_id"
    t.bigint "provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_lead_partners_on_discarded_at"
    t.index ["name"], name: "index_lead_partners_on_name"
    t.index ["provider_id"], name: "index_lead_partners_on_provider_id", unique: true
    t.index ["school_id"], name: "index_lead_partners_on_school_id", unique: true
    t.index ["ukprn"], name: "index_lead_partners_on_ukprn", unique: true
    t.index ["urn"], name: "index_lead_partners_on_urn", unique: true
  end

  create_table "nationalisations", force: :cascade do |t|
    t.bigint "trainee_id", null: false
    t.bigint "nationality_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nationality_id"], name: "index_nationalisations_on_nationality_id"
    t.index ["trainee_id"], name: "index_nationalisations_on_trainee_id"
  end

  create_table "nationalities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_nationalities_on_name", unique: true
  end

  create_table "placements", force: :cascade do |t|
    t.bigint "trainee_id"
    t.bigint "school_id"
    t.string "urn"
    t.string "name"
    t.text "address"
    t.string "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "slug"
    t.index ["school_id"], name: "index_placements_on_school_id"
    t.index ["slug", "trainee_id"], name: "index_placements_on_slug_and_trainee_id", unique: true
    t.index ["trainee_id"], name: "index_placements_on_trainee_id"
  end

  create_table "potential_duplicate_trainees", force: :cascade do |t|
    t.uuid "group_id", null: false
    t.bigint "trainee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_potential_duplicate_trainees_on_group_id"
    t.index ["trainee_id"], name: "index_potential_duplicate_trainees_on_trainee_id"
  end

  create_table "provider_users", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id", "user_id"], name: "index_provider_users_on_provider_id_and_user_id", unique: true
    t.index ["provider_id"], name: "index_provider_users_on_provider_id"
    t.index ["user_id"], name: "index_provider_users_on_user_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "dttp_id"
    t.boolean "apply_sync_enabled", default: false
    t.string "code"
    t.string "ukprn"
    t.string "accreditation_id"
    t.datetime "discarded_at"
    t.tsvector "searchable"
    t.boolean "accredited", default: true, null: false
    t.index ["accreditation_id"], name: "index_providers_on_accreditation_id", unique: true
    t.index ["discarded_at"], name: "index_providers_on_discarded_at"
    t.index ["dttp_id"], name: "index_providers_on_dttp_id", unique: true
    t.index ["searchable"], name: "index_providers_on_searchable", using: :gin
  end

  create_table "schools", force: :cascade do |t|
    t.string "urn", null: false
    t.string "name", null: false
    t.string "postcode"
    t.string "town"
    t.date "open_date"
    t.date "close_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "searchable"
    t.index ["close_date"], name: "index_schools_on_close_date", where: "(close_date IS NULL)"
    t.index ["searchable"], name: "index_schools_on_searchable", using: :gin
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sign_offs", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "academic_cycle_id", null: false
    t.bigint "user_id", null: false
    t.string "sign_off_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_cycle_id"], name: "index_sign_offs_on_academic_cycle_id"
    t.index ["provider_id", "academic_cycle_id", "sign_off_type"], name: "idx_on_provider_id_academic_cycle_id_sign_off_type_fc3b6ade67", unique: true
    t.index ["provider_id"], name: "index_sign_offs_on_provider_id"
    t.index ["user_id"], name: "index_sign_offs_on_user_id"
  end

  create_table "subject_specialisms", force: :cascade do |t|
    t.citext "name", null: false
    t.bigint "allocation_subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hecos_code"
    t.index ["allocation_subject_id"], name: "index_subject_specialisms_on_allocation_subject_id"
    t.index ["name"], name: "index_subject_specialisms_on_name", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_subjects_on_code", unique: true
  end

  create_table "trainee_disabilities", force: :cascade do |t|
    t.bigint "trainee_id", null: false
    t.bigint "disability_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "additional_disability"
    t.index ["disability_id", "trainee_id"], name: "index_trainee_disabilities_on_disability_id_and_trainee_id", unique: true
    t.index ["disability_id"], name: "index_trainee_disabilities_on_disability_id"
    t.index ["trainee_id"], name: "index_trainee_disabilities_on_trainee_id"
  end

  create_table "trainee_withdrawal_reasons", force: :cascade do |t|
    t.bigint "trainee_id"
    t.bigint "withdrawal_reason_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "trainee_withdrawal_id"
    t.index ["trainee_id", "withdrawal_reason_id"], name: "uniq_idx_trainee_withdawal_reasons", unique: true
    t.index ["trainee_id"], name: "index_trainee_withdrawal_reasons_on_trainee_id"
    t.index ["trainee_withdrawal_id", "withdrawal_reason_id"], name: "uniq_idx_trainee_withdrawal_id_withdrawal_reason_id", unique: true
    t.index ["withdrawal_reason_id"], name: "index_trainee_withdrawal_reasons_on_withdrawal_reason_id"
  end

  create_table "trainee_withdrawals", force: :cascade do |t|
    t.bigint "trainee_id", null: false
    t.date "date"
    t.enum "trigger", enum_type: "trigger_type"
    t.string "another_reason"
    t.enum "future_interest", enum_type: "future_interest_type"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_trainee_withdrawals_on_discarded_at"
    t.index ["trainee_id"], name: "index_trainee_withdrawals_on_trainee_id"
  end

  create_table "trainees", force: :cascade do |t|
    t.text "first_names"
    t.text "last_name"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "email"
    t.uuid "dttp_id"
    t.text "middle_names"
    t.integer "training_route"
    t.integer "sex"
    t.integer "diversity_disclosure"
    t.integer "ethnic_group"
    t.text "ethnic_background"
    t.text "additional_ethnic_background"
    t.integer "disability_disclosure"
    t.text "course_subject_one"
    t.date "itt_start_date"
    t.jsonb "progress", default: {}
    t.bigint "provider_id", null: false
    t.date "outcome_date"
    t.date "itt_end_date"
    t.uuid "placement_assignment_dttp_id"
    t.string "trn"
    t.datetime "submitted_for_trn_at", precision: nil
    t.integer "state", default: 0
    t.datetime "withdraw_date", precision: nil
    t.string "withdraw_reasons_details"
    t.date "defer_date"
    t.citext "slug", null: false
    t.datetime "recommended_for_award_at", precision: nil
    t.string "dttp_update_sha"
    t.date "trainee_start_date"
    t.date "reinstate_date"
    t.uuid "dormancy_dttp_id"
    t.bigint "employing_school_id"
    t.bigint "apply_application_id"
    t.integer "course_min_age"
    t.integer "course_max_age"
    t.text "course_subject_two"
    t.text "course_subject_three"
    t.datetime "awarded_at", precision: nil
    t.boolean "applying_for_bursary"
    t.integer "training_initiative"
    t.integer "bursary_tier"
    t.integer "study_mode"
    t.boolean "ebacc", default: false
    t.string "region"
    t.integer "course_education_phase"
    t.boolean "applying_for_scholarship"
    t.boolean "applying_for_grant"
    t.uuid "course_uuid"
    t.boolean "lead_partner_not_applicable", default: false
    t.boolean "employing_school_not_applicable", default: false
    t.boolean "submission_ready", default: false
    t.integer "commencement_status"
    t.datetime "discarded_at", precision: nil
    t.boolean "created_from_dttp", default: false, null: false
    t.string "hesa_id"
    t.jsonb "additional_dttp_data"
    t.boolean "created_from_hesa", default: false, null: false
    t.datetime "hesa_updated_at", precision: nil
    t.bigint "course_allocation_subject_id"
    t.bigint "start_academic_cycle_id"
    t.bigint "end_academic_cycle_id"
    t.string "record_source"
    t.bigint "hesa_trn_submission_id"
    t.string "iqts_country"
    t.boolean "hesa_editable", default: false
    t.string "withdraw_reasons_dfe_details"
    t.datetime "slug_sent_to_dqt_at"
    t.integer "placement_detail"
    t.integer "application_choice_id"
    t.text "provider_trainee_id"
    t.bigint "lead_partner_id"
    t.index ["apply_application_id"], name: "index_trainees_on_apply_application_id"
    t.index ["course_allocation_subject_id"], name: "index_trainees_on_course_allocation_subject_id"
    t.index ["course_uuid"], name: "index_trainees_on_course_uuid"
    t.index ["disability_disclosure"], name: "index_trainees_on_disability_disclosure"
    t.index ["discarded_at", "record_source", "provider_id", "state"], name: "index_trainees_on_discarded_at__record_source__provider__state"
    t.index ["discarded_at"], name: "index_trainees_on_discarded_at"
    t.index ["diversity_disclosure"], name: "index_trainees_on_diversity_disclosure"
    t.index ["dttp_id"], name: "index_trainees_on_dttp_id"
    t.index ["employing_school_id"], name: "index_trainees_on_employing_school_id"
    t.index ["end_academic_cycle_id"], name: "index_trainees_on_end_academic_cycle_id"
    t.index ["ethnic_group"], name: "index_trainees_on_ethnic_group"
    t.index ["hesa_id"], name: "index_trainees_on_hesa_id"
    t.index ["hesa_trn_submission_id"], name: "index_trainees_on_hesa_trn_submission_id"
    t.index ["lead_partner_id"], name: "index_trainees_on_lead_partner_id"
    t.index ["placement_detail"], name: "index_trainees_on_placement_detail"
    t.index ["progress"], name: "index_trainees_on_progress", using: :gin
    t.index ["provider_id"], name: "index_trainees_on_provider_id"
    t.index ["sex"], name: "index_trainees_on_sex"
    t.index ["slug"], name: "index_trainees_on_slug", unique: true
    t.index ["start_academic_cycle_id"], name: "index_trainees_on_start_academic_cycle_id"
    t.index ["state"], name: "index_trainees_on_state"
    t.index ["submission_ready"], name: "index_trainees_on_submission_ready"
    t.index ["training_route"], name: "index_trainees_on_training_route"
    t.index ["trn"], name: "index_trainees_on_trn"
  end

  create_table "uploads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.integer "malware_scan_result", default: 0
    t.index ["user_id"], name: "index_uploads_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dfe_sign_in_uid"
    t.datetime "last_signed_in_at", precision: nil
    t.uuid "dttp_id"
    t.boolean "system_admin", default: false
    t.datetime "welcome_email_sent_at", precision: nil
    t.datetime "discarded_at", precision: nil
    t.boolean "read_only", default: false
    t.string "otp_secret"
    t.index ["dfe_sign_in_uid"], name: "index_users_on_dfe_sign_in_uid", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["dttp_id"], name: "index_unique_active_dttp_users", unique: true, where: "(discarded_at IS NULL)"
    t.index ["email"], name: "index_unique_active_users", unique: true, where: "(discarded_at IS NULL)"
  end

  create_table "validation_errors", force: :cascade do |t|
    t.bigint "user_id"
    t.string "form_object"
    t.jsonb "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_validation_errors_on_user_id"
  end

  create_table "withdrawal_reasons", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_withdrawal_reasons_on_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "users"
  add_foreign_key "authentication_tokens", "providers"
  add_foreign_key "authentication_tokens", "users", column: "created_by_id"
  add_foreign_key "authentication_tokens", "users", column: "revoked_by_id"
  add_foreign_key "bulk_update_placement_rows", "bulk_update_placements"
  add_foreign_key "bulk_update_placement_rows", "schools"
  add_foreign_key "bulk_update_placements", "providers"
  add_foreign_key "bulk_update_recommendations_upload_rows", "bulk_update_recommendations_uploads"
  add_foreign_key "bulk_update_recommendations_upload_rows", "trainees", column: "matched_trainee_id"
  add_foreign_key "bulk_update_recommendations_uploads", "providers"
  add_foreign_key "bulk_update_trainee_upload_rows", "bulk_update_trainee_uploads"
  add_foreign_key "bulk_update_trainee_uploads", "providers"
  add_foreign_key "bulk_update_trainee_uploads", "users", column: "submitted_by_id"
  add_foreign_key "course_subjects", "courses"
  add_foreign_key "course_subjects", "subjects"
  add_foreign_key "degrees", "trainees"
  add_foreign_key "dqt_trn_requests", "trainees"
  add_foreign_key "funding_methods", "academic_cycles"
  add_foreign_key "hesa_trainee_details", "trainees"
  add_foreign_key "lead_partner_users", "lead_partners"
  add_foreign_key "lead_partner_users", "users"
  add_foreign_key "lead_partners", "providers"
  add_foreign_key "lead_partners", "schools"
  add_foreign_key "nationalisations", "nationalities"
  add_foreign_key "nationalisations", "trainees"
  add_foreign_key "potential_duplicate_trainees", "trainees"
  add_foreign_key "provider_users", "providers"
  add_foreign_key "provider_users", "users"
  add_foreign_key "sign_offs", "academic_cycles"
  add_foreign_key "sign_offs", "providers"
  add_foreign_key "sign_offs", "users"
  add_foreign_key "subject_specialisms", "allocation_subjects"
  add_foreign_key "trainee_disabilities", "disabilities"
  add_foreign_key "trainee_disabilities", "trainees"
  add_foreign_key "trainee_withdrawal_reasons", "trainee_withdrawals"
  add_foreign_key "trainee_withdrawal_reasons", "trainees"
  add_foreign_key "trainee_withdrawal_reasons", "withdrawal_reasons"
  add_foreign_key "trainee_withdrawals", "trainees"
  add_foreign_key "trainees", "academic_cycles", column: "end_academic_cycle_id"
  add_foreign_key "trainees", "academic_cycles", column: "start_academic_cycle_id"
  add_foreign_key "trainees", "allocation_subjects", column: "course_allocation_subject_id"
  add_foreign_key "trainees", "apply_applications"
  add_foreign_key "trainees", "hesa_trn_submissions"
  add_foreign_key "trainees", "lead_partners"
  add_foreign_key "trainees", "providers"
  add_foreign_key "trainees", "schools", column: "employing_school_id"
  add_foreign_key "uploads", "users"
end
