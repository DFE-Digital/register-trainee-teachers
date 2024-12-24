# frozen_string_literal: true

desc "Generate some valid fake CSV data."
task generate_trainee_test_csv: :environment do
  BulkUpdate::SampleTraineeDataGenerator.call(
    file_name: "tmp/trainees_5.csv",
    count: 5,
  )
end

desc "Generate some fake CSV data with incomplete data."
task generate_trainee_test_csv_with_incomplete_data: :environment do
  BulkUpdate::SampleTraineeDataGenerator.call(
    file_name: "tmp/trainees_with_incomplete_data_5.csv",
    count: 5,
    with_incomplete_records: true,
  )
end

desc "Generate some fake CSV data with invalid data values."
task generate_trainee_test_csv_with_invalid_data: :environment do
  BulkUpdate::SampleTraineeDataGenerator.call(
    file_name: "tmp/trainees_with_invalid_data_5.csv",
    count: 5,
    with_invalid_records: true,
  )
end
