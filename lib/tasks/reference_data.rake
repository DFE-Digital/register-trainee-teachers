# frozen_string_literal: true

# Data is from the HESA ITT collection for 2024/25, downloaded from https://www.hesa.ac.uk/collection/c24053/
HESA_CSV_PATH = Rails.root.join("data/hesa/").freeze

HesaCode = Struct.new(:code, :label)

class HesaCodeChecker
  def initialize
    @missing = []
  end

  def call(file_name)
    puts("## #{file_name.humanize}")
    puts("Checking HESA codes against Register reference data...")

    puts("| HESA Code | HESA Label | Register Value |")
    puts("| --------- | ---------- | -------------- |")

    CSV.parse(File.read(HESA_CSV_PATH.join("#{file_name}.csv")), headers: true).each do |row|
      hesa_code = HesaCode.new(row["Code"], row["Label"])
      register_value = yield(hesa_code)
      @missing << hesa_code if register_value.nil?
      puts("| #{hesa_code.code} | #{hesa_code.label} | #{register_value || 'NOT FOUND'} |")
    end

    if @missing.any?
      puts("### Missing mappings 🚨")

      puts("| HESA Code | HESA Label |")
      puts("| --------- | ---------- |")

      @missing.each do |hesa_code|
        puts("| #{hesa_code.code} | #{hesa_code.label} |")
      end
    else
      puts("\n")
      puts("*All HESA codes are mapped!* 🎉")
    end
    puts("\n\n")
  end
end

namespace :reference_data do
  desc "All HESA reference data checks"
  task all: %i[
    ethnicities
    sexes
    countries
    disabilities
    itt_aims
    itt_qualification_aims
    training_routes
    course_subjects
    study_modes
    age_ranges
    fund_codes
    funding_methods
    training_initiatives
    degree_types
    degree_subjects
    degree_grades
    degree_institutions
    degree_countries
  ]

  desc "HESA ethnicities reference data checks"
  task ethnicities: :environment do
    HesaCodeChecker.new.call("ethnicities") do |hesa_code|
      Hesa::CodeSets::Ethnicities::MAPPING[hesa_code.code]
    end
  end

  desc "HESA sexes reference data checks"
  task sexes: :environment do
    HesaCodeChecker.new.call("sexes") do |hesa_code|
      Hesa::CodeSets::Sexes::MAPPING[hesa_code.code]
    end
  end

  desc "HESA countries reference data checks"
  task countries: :environment do
    HesaCodeChecker.new.call("countries") do |hesa_code|
      Hesa::CodeSets::Countries::MAPPING[hesa_code.code]
    end
  end

  desc "HESA disabilities reference data checks"
  task disabilities: :environment do
    HesaCodeChecker.new.call("disabilities") do |hesa_code|
      Hesa::CodeSets::Disabilities::MAPPING[hesa_code.code]
    end
  end

  desc "HESA ITT aims reference data checks"
  task itt_aims: :environment do
    HesaCodeChecker.new.call("itt_aims") do |hesa_code|
      Hesa::CodeSets::IttAims::MAPPING[hesa_code.code]
    end
  end

  desc "HESA ITT qualification aims reference data checks"
  task itt_qualification_aims: :environment do
    HesaCodeChecker.new.call("itt_qualification_aims") do |hesa_code|
      Hesa::CodeSets::IttQualificationAims::MAPPING[hesa_code.code]
    end
  end

  desc "HESA training routes reference data checks"
  task training_routes: :environment do
    HesaCodeChecker.new.call("training_routes") do |hesa_code|
      Hesa::CodeSets::TrainingRoutes::MAPPING[hesa_code.code]
    end
  end

  desc "HESA training routes reference data checks"
  task training_routes: :environment do
    HesaCodeChecker.new.call("training_routes") do |hesa_code|
      Hesa::CodeSets::TrainingRoutes::MAPPING[hesa_code.code]
    end
  end

  desc "HESA course subjects reference data checks"
  task course_subjects: :environment do
    HesaCodeChecker.new.call("course_subjects") do |hesa_code|
      Hesa::CodeSets::CourseSubjects::MAPPING[hesa_code.code]
    end
  end

  desc "HESA study modes reference data checks"
  task study_modes: :environment do
    HesaCodeChecker.new.call("study_modes") do |hesa_code|
      Hesa::CodeSets::StudyModes::MAPPING[hesa_code.code]
    end
  end

  desc "HESA course age ranges reference data checks"
  task age_ranges: :environment do
    HesaCodeChecker.new.call("age_ranges") do |hesa_code|
      range = Hesa::CodeSets::AgeRanges::MAPPING[hesa_code.code]
      range ? "#{range[0]} - #{range[1]}" : nil
    end
  end

  desc "HESA fund code reference data checks"
  task fund_codes: :environment do
    HesaCodeChecker.new.call("fund_codes") do |hesa_code|
      Hesa::CodeSets::FundCodes::MAPPING[hesa_code.code]
    end
  end

  desc "HESA funding methods reference data checks"
  task funding_methods: :environment do
    HesaCodeChecker.new.call("funding_methods") do |hesa_code|
      entity_id = Hesa::CodeSets::BursaryLevels::MAPPING[hesa_code.code]
      CodeSets::BursaryDetails::MAPPING.find { |_, value| value[:entity_id] == entity_id }&.first
    end
  end

  desc "HESA training initiatives reference data checks"
  task training_initiatives: :environment do
    HesaCodeChecker.new.call("training_initiatives") do |hesa_code|
      Hesa::CodeSets::TrainingInitiatives::MAPPING[hesa_code.code]
    end
  end

  desc "HESA degree types reference data checks"
  task degree_types: :environment do
    HesaCodeChecker.new.call("degree_types") do |hesa_code|
      degree_type = DfEReference::DegreesQuery.find_type(hesa_code: hesa_code.code)
      degree_type&.name
    end
  end

  desc "HESA degree subjects reference data checks"
  task degree_subjects: :environment do
    HesaCodeChecker.new.call("degree_subjects") do |hesa_code|
      degree_subject = DfEReference::DegreesQuery.find_subject(hecos_code: hesa_code.code)
      degree_subject&.name
    end
  end

  desc "HESA degree grades reference data checks"
  task degree_grades: :environment do
    HesaCodeChecker.new.call("degree_grades") do |hesa_code|
      grade = DfEReference::DegreesQuery.find_grade(hesa_code: hesa_code.code)
      grade&.name
    end
  end

  desc "HESA degree institutions reference data checks"
  task degree_institutions: :environment do
    HesaCodeChecker.new.call("degree_institutions") do |hesa_code|
      institution = DfEReference::DegreesQuery.find_institution(hesa_code: hesa_code.code)
      institution&.name
    end
  end

  desc "HESA degree institutions reference data checks"
  task degree_countries: :environment do
    HesaCodeChecker.new.call("degree_countries") do |hesa_code|
      Hesa::CodeSets::Countries::MAPPING[hesa_code.code]
    end
  end
end
