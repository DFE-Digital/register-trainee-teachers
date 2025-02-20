# frozen_string_literal: true

desc "Generate some valid fake CSV data."
task generate_all_test_csvs: %i[generate_trainee_test_csv generate_trainee_test_csv_with_placement generate_trainee_test_csv_with_degree generate_trainee_test_csv_with_placement_and_degree generate_trainee_test_csv_with_incomplete_data generate_trainee_test_csv_with_invalid_data]

desc "Generate some valid fake CSV data."
task generate_trainee_test_csv: :environment do
  BulkUpdate::SampleTraineeDataGenerator.call(
    file_name: "tmp/trainees_5.csv",
    count: 5,
  )
end

desc "Generate some valid fake CSV data including a placement."
task generate_trainee_test_csv_with_placement: :environment do
  BulkUpdate::SampleTraineeDataGenerator.call(
    file_name: "tmp/trainees_and_placement_5.csv",
    count: 5,
    with_placement: true,
  )
end

desc "Generate some valid fake CSV data including a degree."
task generate_trainee_test_csv_with_degree: :environment do
  BulkUpdate::SampleTraineeDataGenerator.call(
    file_name: "tmp/trainees_degree_5.csv",
    count: 5,
    with_placement: false,
    with_degree: true,
  )
end

desc "Generate some valid fake CSV data including a placement and degree."
task generate_trainee_test_csv_with_placement_and_degree: :environment do
  BulkUpdate::SampleTraineeDataGenerator.call(
    file_name: "tmp/trainees_placement_and_degree_5.csv",
    count: 5,
    with_placement: true,
    with_degree: true,
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
