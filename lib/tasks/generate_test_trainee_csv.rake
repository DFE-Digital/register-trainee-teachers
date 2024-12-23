# frozen_string_literal: true

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

desc "Disposable task to generate some fake CSV data with missing data."
task generate_trainee_test_csv_with_missing_data: :environment do
  CSV.open("tmp/trainees_with_missing_data_5.csv", "wb") do |csv|
    csv << column_names
    5.times do |_row|
      csv << remove_mandatory_fields(csv_row)
    end
  end
end

desc "Disposable task to generate some fake CSV data with invalid data values."
task generate_trainee_test_csv_with_missing_data: :environment do
  CSV.open("tmp/trainees_with_invalid_data_5.csv", "wb") do |csv|
    csv << column_names
    5.times do |_row|
      csv << invalidate_fields(csv_row)
    end
  end
end
