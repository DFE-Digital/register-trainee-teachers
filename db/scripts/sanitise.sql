DELETE FROM "sessions";
DELETE FROM "audits";
DELETE FROM "blazer_audits";
DELETE FROM "validation_errors";
DELETE FROM "apply_application_sync_requests";

-- Users
UPDATE "users"
SET
  first_name = 'User',
  last_name = concat('RegisterUser', id),
  email = concat('register_test_user_', id, '@example.com')
WHERE email NOT LIKE '%@digital.education.gov.uk'
      AND email NOT LIKE '%@education.gov.uk';

-- Trainees
UPDATE "trainees"
SET
  date_of_birth = '2000-01-01',
  first_name = 'Trainee',
  middle_names = null,
  last_name = concat('TraineeUser', id),
  email = concat('trainee_', id, '@example.com'),
  address_line_one = CASE WHEN address_line_one IS NULL THEN NULL ELSE 'DfE Building' END,
  address_line_two = CASE WHEN address_line_two IS NULL THEN NULL ELSE 'Great Smith Street' END,
  town_city = CASE WHEN town_city IS NULL THEN NULL ELSE 'London' END,
  postcode = CASE WHEN postcode IS NULL THEN NULL ELSE 'SW1P 3BT' END,
  international_address = CASE WHEN international_address IS NULL THEN NULL ELSE 'International Address' END;

-- Dttp Users
UPDATE "dttp_users"
SET
  email = concat('test_dttp_user', id, '@example.org'),
  first_name = 'Dttp',
  last_name = concat('DttpUser', id)
WHERE email NOT LIKE '%@digital.education.gov.uk'
      AND email NOT LIKE '%@education.gov.uk';
