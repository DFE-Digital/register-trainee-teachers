# frozen_string_literal: true

def generate_row_data
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  {
    first_names: first_name,
    last_name: last_name,
    previous_last_name: Faker::Name.last_name,
    date_of_birth: Faker::Date.between(from: '1960-01-01', to: '2002-12-31').iso8601,
    sex: Hesa::CodeSets::Sexes::MAPPING.keys.sample,
    email: "#{first_name.downcase}.#{last_name.downcase}@example.com",
    nationality: "GB",
    training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]],
    itt_start_date: "2023-01-01",
    itt_end_date: "2023-10-01",
    course_subject_one: Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::BIOLOGY],
    study_mode: Hesa::CodeSets::StudyModes::MAPPING.invert[TRAINEE_STUDY_MODE_ENUMS["full_time"]],
    disability1: Hesa::CodeSets::Disabilities::MAPPING.keys.sample,
    disability2: Hesa::CodeSets::Disabilities::MAPPING.keys.sample,
    disability3: Hesa::CodeSets::Disabilities::MAPPING.keys.sample,
    # degrees_attributes: [
    #   {
    #     grade: "02",
    #     subject: "100485",
    #     institution: "0117",
    #     uk_degree: "083",
    #     graduation_year: "2003",
    #   },
    # ],
    # placements_attributes: [
    #   {
    #     name: "Placement",
    #     urn: Faker::Number.number(digits: 6),
    #   },
    # ],
    itt_aim: Hesa::CodeSets::IttAims::MAPPING.keys.sample,
    itt_qualification_aim: Hesa::CodeSets::IttQualificationAims::MAPPING.keys.sample,
    course_year: "2023",
    course_age_range: Hesa::CodeSets::AgeRanges::MAPPING.keys.sample,
    fund_code: Hesa::CodeSets::FundCodes::MAPPING.keys.sample,
    funding_method: "4",
    hesa_id: Faker::Number.number(digits: 17),
    provider_trainee_id: Faker::Number.number(digits: 10),
    pg_apprenticeship_start_date: "2024-03-11",
  }.with_indifferent_access
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
task :generate_csv => :environment do
  CSV.open("tmp/trainees.csv", "wb") do |csv|
    csv << column_names
    5.times do |row|
      csv << csv_row
    end
  end
end
