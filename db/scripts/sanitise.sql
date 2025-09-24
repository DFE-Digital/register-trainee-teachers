-- Delete all records from specific tables
DELETE FROM "active_storage_attachments";
DELETE FROM "active_storage_blobs";
DELETE FROM "active_storage_variant_records";
DELETE FROM "activities";
DELETE FROM "apply_application_sync_requests";
DELETE FROM "audits";
DELETE FROM "authentication_tokens";
DELETE FROM "blazer_audits";
DELETE FROM "bulk_update_placement_rows";
DELETE FROM "bulk_update_placements";
DELETE FROM "bulk_update_recommendations_upload_rows";
DELETE FROM "bulk_update_recommendations_uploads";
DELETE FROM "bulk_update_row_errors";
DELETE FROM "bulk_update_trainee_upload_rows";
DELETE FROM "bulk_update_trainee_uploads";
DELETE FROM "dqt_teachers";
DELETE FROM "dqt_teacher_trainings";
DELETE FROM "dqt_trn_requests";
DELETE FROM "funding_payment_schedules";
DELETE FROM "funding_payment_schedule_rows";
DELETE FROM "funding_payment_schedule_row_amounts";
DELETE FROM "funding_trainee_summaries";
DELETE FROM "funding_trainee_summary_rows";
DELETE FROM "funding_trainee_summary_row_amounts";
DELETE FROM "funding_uploads";
DELETE FROM "hesa_collection_requests";
DELETE FROM "hesa_students";
DELETE FROM "hesa_trn_requests";
DELETE FROM "sessions";
DELETE FROM "uploads";
DELETE FROM "validation_errors";

-- Apply applications
UPDATE
  "apply_applications"
SET
  application = NULL,
  invalid_data = NULL;

-- DTTP sync
UPDATE
  "dttp_degree_qualifications"
SET
  response = NULL;

UPDATE
  "dttp_dormant_periods"
SET
  response = NULL;

UPDATE
  "dttp_placement_assignments"
SET
  response = NULL;

UPDATE
  "dttp_providers"
SET
  response = NULL;

UPDATE
  "dttp_trainees"
SET
  response = NULL;

-- DTTP users
UPDATE
  "dttp_users"
SET
  email = concat('test_dttp_user', id, '@example.org'),
  first_name = 'Dttp',
  last_name = concat('DttpUser', id)
WHERE
  email IS NULL
  OR email !~ '@(digital.)?education.gov.uk$';

-- HESA TRN submissions
UPDATE
  "hesa_trn_submissions"
SET
  payload = NULL;

-- Trainees
UPDATE
  "trainees"
SET
  date_of_birth = '2000-01-01',
  first_names = 'Trainee',
  middle_names = NULL,
  last_name = concat('TraineeUser', id),
  email = concat('trainee_', id, '@example.com'),
  provider_trainee_id = concat('trainee-', id),
  trn = CASE
    WHEN trn IS NULL THEN NULL
    ELSE rpad(id :: text, 7, '0')
  END,
  additional_dttp_data = NULL,
  withdraw_reasons_details = NULL,
  defer_reason = NULL,
  hesa_id = CASE
    WHEN hesa_id IS NULL THEN NULL
    ELSE rpad(id :: text, 17, '0')
  END;

UPDATE
  "hesa_trainee_details"
SET
  previous_last_name = NULL,
  ni_number = NULL;

-- Users
UPDATE
  "users"
SET
  first_name = 'User',
  last_name = concat('RegisterUser', id),
  email = concat('register_test_user_', id, '@example.com'),
  dfe_sign_in_uid = NULL,
  otp_secret = NULL
WHERE
  email !~ '@(digital.)?education.gov.uk$';