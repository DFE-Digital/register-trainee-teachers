DELETE FROM "active_storage_attachments";
DELETE FROM "active_storage_blobs";
DELETE FROM "active_storage_variant_records";
DELETE FROM "apply_application_sync_requests";
DELETE FROM "audits";
DELETE FROM "blazer_audits";
DELETE FROM "bulk_update_recommendations_uploads";
DELETE FROM "bulk_update_recommendations_upload_rows";
DELETE FROM "bulk_update_row_errors";
DELETE FROM "funding_payment_schedules";
DELETE FROM "funding_payment_schedule_rows";
DELETE FROM "funding_payment_schedule_row_amounts";
DELETE FROM "funding_trainee_summaries";
DELETE FROM "funding_trainee_summary_rows";
DELETE FROM "funding_trainee_summary_row_amounts";
DELETE FROM "hesa_students";
DELETE FROM "sessions";
DELETE FROM "uploads";
DELETE FROM "validation_errors";

-- Apply sync
UPDATE
  "apply_applications"
SET
  application = NULL;

-- Dttp Users
UPDATE
  "dttp_users"
SET
  email = concat('test_dttp_user', id, '@example.org'),
  first_name = 'Dttp',
  last_name = concat('DttpUser', id)
WHERE
  email NOT LIKE '%@digital.education.gov.uk'
  AND email NOT LIKE '%@education.gov.uk';

-- DTTP sync
UPDATE
  "dttp_dormant_periods"
SET
  response = NULL;

UPDATE
  "dttp_degree_qualifications"
SET
  response = NULL;

UPDATE
  "dttp_placement_assignments"
SET
  response = NULL;

UPDATE
  "dttp_trainees"
SET
  response = NULL;

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
  additional_dttp_data = NULL;

-- Users
UPDATE
  "users"
SET
  first_name = 'User',
  last_name = concat('RegisterUser', id),
  email = concat('register_test_user_', id, '@example.com')
WHERE
  email NOT LIKE '%@digital.education.gov.uk'
  AND email NOT LIKE '%@education.gov.uk';

UPDATE
  "users"
SET
  otp_secret = NULL;