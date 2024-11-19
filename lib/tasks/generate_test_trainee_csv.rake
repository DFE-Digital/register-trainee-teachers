# frozen_string_literal: true

def generate_row_data
  keys = %w[first_names last_name previous_last_name date_of_birth sex email nationality training_route itt_start_date itt_end_date course_subject_one study_mode disability1 disability2 disability3 itt_aim itt_qualification_aim course_year course_age_range fund_code funding_method hesa_id provider_trainee_id pg_apprenticeship_start_date]
  trainee = FactoryBot.build(:trainee, :completed)
  trainee.attributes.slice(*keys).merge(
    pg_apprenticeship_start_date: trainee.itt_start_date,
    fund_code: Hesa::CodeSets::FundCodes::MAPPING.keys.sample,
    funding_method: "4",
    itt_aim: Hesa::CodeSets::IttAims::MAPPING.keys.sample,
    itt_qualification_aim: Hesa::CodeSets::IttQualificationAims::MAPPING.keys.sample,
    course_year: trainee.itt_start_date.year,
    disability1: Hesa::CodeSets::Disabilities::MAPPING.keys.sample,
    disability2: Hesa::CodeSets::Disabilities::MAPPING.keys.sample,
    disability3: Hesa::CodeSets::Disabilities::MAPPING.keys.sample,
    previous_last_name: Faker::Name.last_name,
    nationality: "GB",
  ).with_indifferent_access
end

def csv_row
  row_values = generate_row_data
  column_names.map do |column_name|
    attribute_name = BulkUpdate::AddTrainees::ImportRows::TRAINEE_HEADERS[column_name]
    row_values[attribute_name]
  end
end

def column_names
  BulkUpdate::AddTrainees::ImportRows::TRAINEE_HEADERS.keys
end

desc "Disposable task to generate some fake CSV data."
task generate_trainee_test_csv: :environment do
  CSV.open("tmp/trainees.csv", "wb") do |csv|
    csv << column_names
    5.times do |_row|
      csv << csv_row
    end
  end
end
