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

ActiveRecord::Schema[8.1].define(version: 2026_03_04_100000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "future_interest_type", ["yes", "no", "unknown"]
  create_enum "trigger_type", ["provider", "trainee"]

  create_table "academic_cycles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false

    t.exclusion_constraint "tsrange((start_date)::timestamp without time zone, (end_date)::timestamp without time zone) WITH &&", using: :gist, name: "academic_cycles_date_range"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "action_name"
    t.string "controller_name"
    t.datetime "created_at", null: false
    t.jsonb "metadata"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "allocation_subjects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "deprecated_on"
    t.string "dttp_id"
    t.citext "name", null: false
    t.datetime "updated_at", null: false
    t.index ["dttp_id"], name: "index_allocation_subjects_on_dttp_id", unique: true
    t.index ["name"], name: "index_allocation_subjects_on_name", unique: true
  end

  create_table "apply_application_sync_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "recruitment_cycle_year"
    t.integer "response_code"
    t.boolean "successful"
    t.datetime "updated_at", null: false
    t.index ["recruitment_cycle_year"], name: "index_apply_application_sync_requests_on_recruitment_cycle_year"
  end

  create_table "apply_applications", force: :cascade do |t|
    t.string "accredited_body_code"
    t.jsonb "application"
    t.integer "apply_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "invalid_data"
    t.integer "recruitment_cycle_year"
    t.integer "state"
    t.datetime "updated_at", null: false
    t.index ["accredited_body_code"], name: "index_apply_applications_on_accredited_body_code"
    t.index ["apply_id"], name: "index_apply_applications_on_apply_id", unique: true
    t.index ["recruitment_cycle_year"], name: "index_apply_applications_on_recruitment_cycle_year"
  end

  create_table "audits", force: :cascade do |t|
    t.string "action"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.jsonb "audited_changes"
    t.string "comment"
    t.datetime "created_at", precision: nil
    t.string "remote_address"
    t.string "request_uuid"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.integer "version", default: 0
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "authentication_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.date "expires_at", null: false
    t.string "hashed_token"
    t.datetime "last_used_at"
    t.string "name", null: false
    t.bigint "provider_id", null: false
    t.datetime "revoked_at"
    t.bigint "revoked_by_id"
    t.string "status", default: "active"
    t.string "token_hash"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_authentication_tokens_on_created_by_id"
    t.index ["expires_at"], name: "index_authentication_tokens_on_expires_at"
    t.index ["hashed_token"], name: "index_authentication_tokens_on_hashed_token", unique: true
    t.index ["provider_id"], name: "index_authentication_tokens_on_provider_id"
    t.index ["revoked_by_id"], name: "index_authentication_tokens_on_revoked_by_id"
    t.index ["status", "last_used_at"], name: "index_authentication_tokens_on_status_and_last_used_at"
    t.index ["status"], name: "index_authentication_tokens_on_status"
    t.index ["token_hash"], name: "index_authentication_tokens_on_token_hash", unique: true
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "data_source"
    t.bigint "query_id"
    t.text "statement"
    t.bigint "user_id"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.string "check_type"
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.text "emails"
    t.datetime "last_run_at", precision: nil
    t.text "message"
    t.bigint "query_id"
    t.string "schedule"
    t.text "slack_channels"
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "dashboard_id"
    t.integer "position"
    t.bigint "query_id"
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.string "data_source"
    t.text "description"
    t.string "name"
    t.text "statement"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "bulk_update_placement_rows", force: :cascade do |t|
    t.bigint "bulk_update_placement_id", null: false
    t.datetime "created_at", null: false
    t.integer "csv_row_number", null: false
    t.bigint "school_id"
    t.integer "state", default: 0, null: false
    t.string "trn", null: false
    t.datetime "updated_at", null: false
    t.string "urn", null: false
    t.index ["bulk_update_placement_id"], name: "index_bulk_update_placement_rows_on_bulk_update_placement_id"
    t.index ["school_id"], name: "index_bulk_update_placement_rows_on_school_id"
  end

  create_table "bulk_update_placements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "provider_id", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_bulk_update_placements_on_provider_id"
  end

  create_table "bulk_update_recommendations_upload_rows", force: :cascade do |t|
    t.string "age_range"
    t.bigint "bulk_update_recommendations_upload_id", null: false
    t.datetime "created_at", null: false
    t.integer "csv_row_number"
    t.string "first_names"
    t.string "hesa_id"
    t.string "last_names"
    t.bigint "matched_trainee_id"
    t.string "phase"
    t.string "provider_trainee_id"
    t.string "qts_or_eyts"
    t.string "route"
    t.date "standards_met_at"
    t.string "subject"
    t.string "training_partner"
    t.string "trn"
    t.datetime "updated_at", null: false
    t.index ["bulk_update_recommendations_upload_id"], name: "idx_bu_ru_rows_on_bu_recommendations_upload_id"
    t.index ["matched_trainee_id"], name: "idx_bu_recommendations_upload_rows_on_matched_trainee_id"
  end

  create_table "bulk_update_recommendations_uploads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "provider_id", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_bulk_update_recommendations_uploads_on_provider_id"
  end

  create_table "bulk_update_row_errors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_type", default: "validation", null: false
    t.bigint "errored_on_id"
    t.string "errored_on_type"
    t.string "message"
    t.datetime "updated_at", null: false
    t.index ["error_type"], name: "index_bulk_update_row_errors_on_error_type"
    t.index ["errored_on_id", "errored_on_type"], name: "idx_on_errored_on_id_errored_on_type_492045ed60"
  end

  create_table "bulk_update_trainee_upload_rows", force: :cascade do |t|
    t.bigint "bulk_update_trainee_upload_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "data", null: false
    t.integer "row_number", null: false
    t.datetime "updated_at", null: false
    t.index ["bulk_update_trainee_upload_id", "row_number"], name: "index_bulk_update_trainee_upload_rows_on_upload_and_row_number", unique: true
    t.index ["bulk_update_trainee_upload_id"], name: "idx_on_bulk_update_trainee_upload_id_21ca71cc91"
  end

  create_table "bulk_update_trainee_uploads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "number_of_trainees", default: 0, null: false
    t.bigint "provider_id", null: false
    t.string "status", default: "uploaded"
    t.datetime "submitted_at"
    t.bigint "submitted_by_id"
    t.datetime "updated_at", null: false
    t.string "version", null: false
    t.index ["provider_id"], name: "index_bulk_update_trainee_uploads_on_provider_id"
    t.index ["status"], name: "index_bulk_update_trainee_uploads_on_status"
    t.index ["submitted_by_id"], name: "index_bulk_update_trainee_uploads_on_submitted_by_id"
  end

  create_table "course_subjects", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "subject_id"], name: "index_course_subjects_on_course_id_and_subject_id", unique: true
    t.index ["course_id"], name: "index_course_subjects_on_course_id"
    t.index ["subject_id"], name: "index_course_subjects_on_subject_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "accredited_body_code", null: false
    t.string "code", null: false
    t.string "course_length"
    t.datetime "created_at", null: false
    t.integer "duration_in_years", null: false
    t.date "full_time_end_date"
    t.date "full_time_start_date"
    t.integer "level", null: false
    t.integer "max_age"
    t.integer "min_age"
    t.string "name", null: false
    t.date "part_time_end_date"
    t.date "part_time_start_date"
    t.date "published_start_date", null: false
    t.integer "qualification", null: false
    t.integer "recruitment_cycle_year"
    t.integer "route", null: false
    t.integer "study_mode"
    t.string "summary", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.index ["code", "accredited_body_code"], name: "index_courses_on_code_and_accredited_body_code"
    t.index ["recruitment_cycle_year"], name: "index_courses_on_recruitment_cycle_year"
    t.index ["uuid"], name: "index_courses_on_uuid", unique: true
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "degrees", force: :cascade do |t|
    t.string "country"
    t.datetime "created_at", null: false
    t.uuid "dttp_id"
    t.string "grade"
    t.uuid "grade_uuid"
    t.integer "graduation_year"
    t.string "institution"
    t.uuid "institution_uuid"
    t.integer "locale_code", null: false
    t.string "non_uk_degree"
    t.text "other_grade"
    t.citext "slug", null: false
    t.string "subject"
    t.uuid "subject_uuid"
    t.bigint "trainee_id", null: false
    t.string "uk_degree"
    t.uuid "uk_degree_uuid"
    t.datetime "updated_at", null: false
    t.index ["dttp_id"], name: "index_degrees_on_dttp_id"
    t.index ["locale_code"], name: "index_degrees_on_locale_code"
    t.index ["slug"], name: "index_degrees_on_slug", unique: true
    t.index ["trainee_id"], name: "index_degrees_on_trainee_id"
  end

  create_table "disabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.index ["name"], name: "index_disabilities_on_name", unique: true
  end

  create_table "dttp_accounts", force: :cascade do |t|
    t.string "accreditation_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "dttp_id"
    t.string "name"
    t.jsonb "response"
    t.string "ukprn"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "urn"
    t.index ["accreditation_id"], name: "index_dttp_accounts_on_accreditation_id"
    t.index ["dttp_id"], name: "index_dttp_accounts_on_dttp_id", unique: true
    t.index ["ukprn"], name: "index_dttp_accounts_on_ukprn"
    t.index ["urn"], name: "index_dttp_accounts_on_urn"
  end

  create_table "dttp_bursary_details", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "dttp_id", null: false
    t.jsonb "response"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_bursary_details_on_dttp_id", unique: true
  end

  create_table "dttp_degree_qualifications", force: :cascade do |t|
    t.uuid "contact_dttp_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "dttp_id", null: false
    t.jsonb "response"
    t.integer "state", default: 0
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_degree_qualifications_on_dttp_id", unique: true
  end

  create_table "dttp_dormant_periods", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "dttp_id", null: false
    t.uuid "placement_assignment_dttp_id"
    t.jsonb "response"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_dormant_periods_on_dttp_id", unique: true
  end

  create_table "dttp_placement_assignments", force: :cascade do |t|
    t.uuid "academic_year"
    t.uuid "contact_dttp_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "dttp_id", null: false
    t.date "programme_end_date"
    t.date "programme_start_date"
    t.uuid "provider_dttp_id"
    t.jsonb "response"
    t.uuid "trainee_status"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_placement_assignments_on_dttp_id", unique: true
  end

  create_table "dttp_providers", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "dttp_id"
    t.string "name"
    t.jsonb "response"
    t.string "ukprn"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_providers_on_dttp_id", unique: true
  end

  create_table "dttp_schools", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "dttp_id"
    t.string "name"
    t.integer "status_code"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "urn"
    t.index ["dttp_id"], name: "index_dttp_schools_on_dttp_id", unique: true
  end

  create_table "dttp_trainees", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "dttp_id", null: false
    t.uuid "provider_dttp_id"
    t.jsonb "response"
    t.integer "state", default: 0
    t.uuid "status"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_trainees_on_dttp_id", unique: true
  end

  create_table "dttp_training_initiatives", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "dttp_id", null: false
    t.jsonb "response"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_training_initiatives_on_dttp_id", unique: true
  end

  create_table "dttp_users", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "dttp_id"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "provider_dttp_id"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_users_on_dttp_id", unique: true
  end

  create_table "feedback_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "improvement_suggestion", null: false
    t.string "name"
    t.string "satisfaction_level", null: false
    t.datetime "updated_at", null: false
  end

  create_table "funding_method_subjects", force: :cascade do |t|
    t.bigint "allocation_subject_id"
    t.datetime "created_at", null: false
    t.bigint "funding_method_id"
    t.datetime "updated_at", null: false
    t.index ["allocation_subject_id", "funding_method_id"], name: "index_funding_methods_subjects_on_ids", unique: true
    t.index ["allocation_subject_id"], name: "index_funding_method_subjects_on_allocation_subject_id"
    t.index ["funding_method_id"], name: "index_funding_method_subjects_on_funding_method_id"
  end

  create_table "funding_methods", force: :cascade do |t|
    t.bigint "academic_cycle_id"
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.integer "funding_type"
    t.string "training_route", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_cycle_id"], name: "index_funding_methods_on_academic_cycle_id"
  end

  create_table "funding_payment_schedule_row_amounts", force: :cascade do |t|
    t.integer "amount_in_pence"
    t.datetime "created_at", null: false
    t.integer "funding_payment_schedule_row_id"
    t.integer "month"
    t.boolean "predicted"
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["funding_payment_schedule_row_id"], name: "index_payment_schedule_row_amounts_on_payment_schedule_row_id"
  end

  create_table "funding_payment_schedule_rows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "funding_payment_schedule_id"
    t.datetime "updated_at", null: false
    t.index ["funding_payment_schedule_id"], name: "index_payment_schedule_rows_on_funding_payment_schedule_id"
  end

  create_table "funding_payment_schedules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "payable_id"
    t.string "payable_type"
    t.datetime "updated_at", null: false
    t.index ["payable_id", "payable_type"], name: "index_funding_payment_schedules_on_payable_id_and_payable_type"
  end

  create_table "funding_trainee_summaries", force: :cascade do |t|
    t.string "academic_year"
    t.datetime "created_at", null: false
    t.integer "payable_id"
    t.string "payable_type"
    t.datetime "updated_at", null: false
    t.index ["payable_id", "payable_type"], name: "index_funding_trainee_summaries_on_payable_id_and_payable_type"
  end

  create_table "funding_trainee_summary_row_amounts", force: :cascade do |t|
    t.integer "amount_in_pence"
    t.datetime "created_at", null: false
    t.integer "funding_trainee_summary_row_id"
    t.integer "number_of_trainees"
    t.integer "payment_type"
    t.integer "tier"
    t.datetime "updated_at", null: false
    t.index ["funding_trainee_summary_row_id"], name: "index_trainee_summary_row_amounts_on_trainee_summary_row_id"
  end

  create_table "funding_trainee_summary_rows", force: :cascade do |t|
    t.string "cohort_level"
    t.datetime "created_at", null: false
    t.integer "funding_trainee_summary_id"
    t.string "lead_school_name"
    t.string "lead_school_urn"
    t.string "route"
    t.string "subject"
    t.string "training_partner_name"
    t.string "training_partner_urn"
    t.string "training_route"
    t.datetime "updated_at", null: false
    t.index ["funding_trainee_summary_id"], name: "index_trainee_summary_rows_on_trainee_summary_id"
  end

  create_table "funding_uploads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "csv_data"
    t.integer "funding_type"
    t.integer "month"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["funding_type"], name: "index_funding_uploads_on_funding_type"
    t.index ["month"], name: "index_funding_uploads_on_month"
    t.index ["status"], name: "index_funding_uploads_on_status"
  end

  create_table "hesa_metadata", force: :cascade do |t|
    t.string "course_programme_title"
    t.datetime "created_at", null: false
    t.string "fundability"
    t.string "itt_aim"
    t.string "itt_qualification_aim"
    t.date "pg_apprenticeship_start_date"
    t.integer "placement_school_urn"
    t.string "service_leaver"
    t.integer "study_length"
    t.string "study_length_unit"
    t.bigint "trainee_id"
    t.datetime "updated_at", null: false
    t.string "year_of_course"
    t.index ["trainee_id"], name: "index_hesa_metadata_on_trainee_id"
  end

  create_table "hesa_students", force: :cascade do |t|
    t.string "allocated_place"
    t.string "application_choice_id"
    t.string "bursary_level"
    t.string "collection_reference"
    t.string "commencement_date"
    t.string "course_age_range"
    t.string "course_programme_title"
    t.string "course_subject_one"
    t.string "course_subject_three"
    t.string "course_subject_two"
    t.datetime "created_at", null: false
    t.string "date_of_birth"
    t.json "degrees"
    t.string "disability1"
    t.string "disability2"
    t.string "disability3"
    t.string "disability4"
    t.string "disability5"
    t.string "disability6"
    t.string "disability7"
    t.string "disability8"
    t.string "disability9"
    t.string "email"
    t.string "employing_school_urn"
    t.string "end_date"
    t.string "ethnic_background"
    t.string "first_names"
    t.string "fund_code"
    t.string "hesa_committed_at"
    t.string "hesa_id"
    t.string "hesa_updated_at"
    t.string "initiatives_two"
    t.string "itt_aim"
    t.string "itt_commencement_date"
    t.string "itt_end_date"
    t.string "itt_key"
    t.string "itt_qualification_aim"
    t.string "itt_start_date"
    t.string "last_name"
    t.string "mode"
    t.string "nationality"
    t.string "ni_number"
    t.string "numhus"
    t.string "pg_apprenticeship_start_date"
    t.json "placements"
    t.string "previous_hesa_id"
    t.string "previous_surname"
    t.string "provider_course_id"
    t.string "provider_trainee_id"
    t.string "reason_for_leaving"
    t.string "rec_id"
    t.string "service_leaver"
    t.string "sex"
    t.string "status"
    t.string "study_length"
    t.string "study_length_unit"
    t.string "surname16"
    t.string "trainee_start_date"
    t.string "training_initiative"
    t.string "training_partner_urn"
    t.string "training_route"
    t.string "trn"
    t.string "ttcid"
    t.string "ukprn"
    t.datetime "updated_at", null: false
    t.string "year_of_course"
    t.index ["hesa_id", "rec_id"], name: "index_hesa_students_on_hesa_id_and_rec_id", unique: true
  end

  create_table "hesa_trainee_details", force: :cascade do |t|
    t.string "additional_training_initiative"
    t.string "course_age_range"
    t.string "course_study_mode"
    t.integer "course_year"
    t.datetime "created_at", null: false
    t.string "funding_method"
    t.jsonb "hesa_disabilities", default: {}
    t.string "itt_aim"
    t.string "itt_qualification_aim"
    t.string "ni_number"
    t.date "pg_apprenticeship_start_date"
    t.string "previous_last_name"
    t.bigint "trainee_id", null: false
    t.datetime "updated_at", null: false
    t.index ["trainee_id"], name: "index_hesa_trainee_details_on_trainee_id"
  end

  create_table "nationalisations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "nationality_id", null: false
    t.bigint "trainee_id", null: false
    t.datetime "updated_at", null: false
    t.index ["nationality_id"], name: "index_nationalisations_on_nationality_id"
    t.index ["trainee_id"], name: "index_nationalisations_on_trainee_id"
  end

  create_table "nationalities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_nationalities_on_name", unique: true
  end

  create_table "placements", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "postcode"
    t.bigint "school_id"
    t.citext "slug"
    t.bigint "trainee_id"
    t.datetime "updated_at", null: false
    t.string "urn"
    t.index ["school_id"], name: "index_placements_on_school_id"
    t.index ["slug", "trainee_id"], name: "index_placements_on_slug_and_trainee_id", unique: true
    t.index ["trainee_id"], name: "index_placements_on_trainee_id"
  end

  create_table "provider_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "provider_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["provider_id", "user_id"], name: "index_provider_users_on_provider_id_and_user_id", unique: true
    t.index ["provider_id"], name: "index_provider_users_on_provider_id"
    t.index ["user_id"], name: "index_provider_users_on_user_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "accreditation_id"
    t.boolean "accredited", default: true, null: false
    t.boolean "apply_sync_enabled", default: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.uuid "dttp_id"
    t.string "name", null: false
    t.tsvector "searchable"
    t.string "ukprn"
    t.datetime "updated_at", null: false
    t.index ["accreditation_id"], name: "index_providers_on_accreditation_id", unique: true
    t.index ["discarded_at"], name: "index_providers_on_discarded_at"
    t.index ["dttp_id"], name: "index_providers_on_dttp_id", unique: true
    t.index ["searchable"], name: "index_providers_on_searchable", using: :gin
  end

  create_table "school_data_downloads", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "schools_created"
    t.integer "schools_deleted"
    t.integer "schools_updated"
    t.datetime "started_at", null: false
    t.string "status", null: false
    t.integer "training_partners_updated"
    t.datetime "updated_at", null: false
    t.index ["started_at"], name: "index_school_data_downloads_on_started_at"
    t.index ["status"], name: "index_school_data_downloads_on_status"
  end

  create_table "schools", force: :cascade do |t|
    t.date "close_date"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.date "open_date"
    t.string "postcode"
    t.tsvector "searchable"
    t.string "town"
    t.datetime "updated_at", null: false
    t.string "urn", null: false
    t.index ["close_date"], name: "index_schools_on_close_date", where: "(close_date IS NULL)"
    t.index ["searchable"], name: "index_schools_on_searchable", using: :gin
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sign_offs", force: :cascade do |t|
    t.bigint "academic_cycle_id", null: false
    t.datetime "created_at", null: false
    t.bigint "provider_id", null: false
    t.string "sign_off_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["academic_cycle_id"], name: "index_sign_offs_on_academic_cycle_id"
    t.index ["provider_id", "academic_cycle_id", "sign_off_type"], name: "idx_on_provider_id_academic_cycle_id_sign_off_type_fc3b6ade67", unique: true
    t.index ["provider_id"], name: "index_sign_offs_on_provider_id"
    t.index ["user_id"], name: "index_sign_offs_on_user_id"
  end

  create_table "subject_specialisms", force: :cascade do |t|
    t.bigint "allocation_subject_id", null: false
    t.datetime "created_at", null: false
    t.string "hecos_code"
    t.citext "name", null: false
    t.datetime "updated_at", null: false
    t.index ["allocation_subject_id"], name: "index_subject_specialisms_on_allocation_subject_id"
    t.index ["name"], name: "index_subject_specialisms_on_name", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_subjects_on_code", unique: true
  end

  create_table "trainee_disabilities", force: :cascade do |t|
    t.text "additional_disability"
    t.datetime "created_at", null: false
    t.bigint "disability_id", null: false
    t.bigint "trainee_id", null: false
    t.datetime "updated_at", null: false
    t.index ["disability_id", "trainee_id"], name: "index_trainee_disabilities_on_disability_id_and_trainee_id", unique: true
    t.index ["disability_id"], name: "index_trainee_disabilities_on_disability_id"
    t.index ["trainee_id"], name: "index_trainee_disabilities_on_trainee_id"
  end

  create_table "trainee_withdrawal_reasons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "trainee_id"
    t.bigint "trainee_withdrawal_id"
    t.datetime "updated_at", null: false
    t.bigint "withdrawal_reason_id", null: false
    t.index ["trainee_id", "withdrawal_reason_id"], name: "uniq_idx_trainee_withdawal_reasons", unique: true
    t.index ["trainee_id"], name: "index_trainee_withdrawal_reasons_on_trainee_id"
    t.index ["trainee_withdrawal_id", "withdrawal_reason_id"], name: "uniq_idx_trainee_withdrawal_id_withdrawal_reason_id", unique: true
    t.index ["withdrawal_reason_id"], name: "index_trainee_withdrawal_reasons_on_withdrawal_reason_id"
  end

  create_table "trainee_withdrawals", force: :cascade do |t|
    t.string "another_reason"
    t.datetime "created_at", null: false
    t.date "date"
    t.datetime "discarded_at"
    t.enum "future_interest", enum_type: "future_interest_type"
    t.string "safeguarding_concern_reasons"
    t.bigint "trainee_id", null: false
    t.enum "trigger", enum_type: "trigger_type"
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_trainee_withdrawals_on_discarded_at"
    t.index ["trainee_id"], name: "index_trainee_withdrawals_on_trainee_id"
  end

  create_table "trainees", force: :cascade do |t|
    t.jsonb "additional_dttp_data"
    t.text "additional_ethnic_background"
    t.integer "application_choice_id"
    t.bigint "apply_application_id"
    t.boolean "applying_for_bursary"
    t.boolean "applying_for_grant"
    t.boolean "applying_for_scholarship"
    t.datetime "awarded_at", precision: nil
    t.integer "bursary_tier"
    t.integer "commencement_status"
    t.bigint "course_allocation_subject_id"
    t.integer "course_education_phase"
    t.integer "course_max_age"
    t.integer "course_min_age"
    t.text "course_subject_one"
    t.text "course_subject_three"
    t.text "course_subject_two"
    t.uuid "course_uuid"
    t.datetime "created_at", null: false
    t.boolean "created_from_dttp", default: false, null: false
    t.boolean "created_from_hesa", default: false, null: false
    t.date "date_of_birth"
    t.date "defer_date"
    t.string "defer_reason"
    t.integer "disability_disclosure"
    t.datetime "discarded_at", precision: nil
    t.integer "diversity_disclosure"
    t.uuid "dormancy_dttp_id"
    t.uuid "dttp_id"
    t.string "dttp_update_sha"
    t.boolean "ebacc", default: false
    t.text "email"
    t.bigint "employing_school_id"
    t.boolean "employing_school_not_applicable", default: false
    t.bigint "end_academic_cycle_id"
    t.text "ethnic_background"
    t.integer "ethnic_group"
    t.text "first_names"
    t.string "funding_eligibility"
    t.boolean "hesa_editable", default: false
    t.string "hesa_id"
    t.datetime "hesa_updated_at", precision: nil
    t.string "iqts_country"
    t.date "itt_end_date"
    t.date "itt_start_date"
    t.text "last_name"
    t.text "middle_names"
    t.date "outcome_date"
    t.uuid "placement_assignment_dttp_id"
    t.integer "placement_detail"
    t.jsonb "progress", default: {}
    t.bigint "provider_id", null: false
    t.text "provider_trainee_id"
    t.datetime "recommended_for_award_at", precision: nil
    t.string "record_source"
    t.string "region"
    t.date "reinstate_date"
    t.tsvector "searchable"
    t.integer "sex"
    t.citext "slug", null: false
    t.datetime "slug_sent_to_trs_at"
    t.bigint "start_academic_cycle_id"
    t.integer "state", default: 0
    t.integer "study_mode"
    t.boolean "submission_ready", default: false
    t.datetime "submitted_for_trn_at", precision: nil
    t.date "trainee_start_date"
    t.integer "training_initiative"
    t.bigint "training_partner_id"
    t.boolean "training_partner_not_applicable", default: false
    t.integer "training_route"
    t.string "trn"
    t.datetime "updated_at", null: false
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
    t.index ["placement_detail"], name: "index_trainees_on_placement_detail"
    t.index ["progress"], name: "index_trainees_on_progress", using: :gin
    t.index ["provider_id"], name: "index_trainees_on_provider_id"
    t.index ["searchable"], name: "index_trainees_on_searchable", using: :gin
    t.index ["sex"], name: "index_trainees_on_sex"
    t.index ["slug"], name: "index_trainees_on_slug", unique: true
    t.index ["start_academic_cycle_id"], name: "index_trainees_on_start_academic_cycle_id"
    t.index ["state"], name: "index_trainees_on_state"
    t.index ["submission_ready"], name: "index_trainees_on_submission_ready"
    t.index ["training_partner_id"], name: "index_trainees_on_training_partner_id"
    t.index ["training_route"], name: "index_trainees_on_training_route"
    t.index ["trn"], name: "index_trainees_on_trn"
  end

  create_table "training_partner_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "training_partner_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["training_partner_id"], name: "index_training_partner_users_on_training_partner_id"
    t.index ["user_id"], name: "index_training_partner_users_on_user_id"
  end

  create_table "training_partners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "name"
    t.bigint "provider_id"
    t.string "record_type", null: false
    t.bigint "school_id"
    t.citext "ukprn"
    t.datetime "updated_at", null: false
    t.citext "urn"
    t.index ["discarded_at"], name: "index_training_partners_on_discarded_at"
    t.index ["name"], name: "index_training_partners_on_name"
    t.index ["provider_id"], name: "index_training_partners_on_provider_id", unique: true
    t.index ["school_id"], name: "index_training_partners_on_school_id", unique: true
    t.index ["ukprn"], name: "index_training_partners_on_ukprn", unique: true
    t.index ["urn"], name: "index_training_partners_on_urn", unique: true
  end

  create_table "trs_trn_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "request_id", null: false
    t.jsonb "response"
    t.integer "state", default: 0
    t.bigint "trainee_id", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_trs_trn_requests_on_request_id", unique: true
    t.index ["trainee_id"], name: "index_trs_trn_requests_on_trainee_id"
  end

  create_table "uploads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "malware_scan_result", default: 0
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_uploads_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dfe_sign_in_uid"
    t.datetime "discarded_at", precision: nil
    t.uuid "dttp_id"
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "last_signed_in_at", precision: nil
    t.string "otp_secret"
    t.boolean "read_only", default: false
    t.boolean "system_admin", default: false
    t.datetime "updated_at", null: false
    t.datetime "welcome_email_sent_at", precision: nil
    t.index ["dfe_sign_in_uid"], name: "index_users_on_dfe_sign_in_uid", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["dttp_id"], name: "index_unique_active_dttp_users", unique: true, where: "(discarded_at IS NULL)"
    t.index ["email"], name: "index_unique_active_users", unique: true, where: "(discarded_at IS NULL)"
  end

  create_table "validation_errors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "details"
    t.string "form_object"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_validation_errors_on_user_id"
  end

  create_table "withdrawal_reasons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
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
  add_foreign_key "funding_methods", "academic_cycles"
  add_foreign_key "hesa_trainee_details", "trainees"
  add_foreign_key "nationalisations", "nationalities"
  add_foreign_key "nationalisations", "trainees"
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
  add_foreign_key "trainees", "providers"
  add_foreign_key "trainees", "schools", column: "employing_school_id"
  add_foreign_key "trainees", "training_partners"
  add_foreign_key "training_partner_users", "training_partners"
  add_foreign_key "training_partner_users", "users"
  add_foreign_key "training_partners", "providers"
  add_foreign_key "training_partners", "schools"
  add_foreign_key "trs_trn_requests", "trainees"
  add_foreign_key "uploads", "users"
end
