# frozen_string_literal: true

HESA_CSV_PATH = Rails.root.join("data/hesa/").freeze

HesaCode = Struct.new(:code, :label)

class HesaCodeChecker
  def initialize
    @missing = []
  end

  def call(file_name)
    puts("Checking HESA #{file_name} against Register reference data...")
    CSV.parse(File.read(HESA_CSV_PATH.join("#{file_name}.csv")), headers: true).each do |row|
      hesa_code = HesaCode.new(row["Code"], row["Label"])
      register_value = yield(hesa_code)
      @missing << hesa_code if register_value.nil?
      puts "Code: #{hesa_code.code} Label: #{hesa_code.label} Register: #{register_value ? register_value : "NOT FOUND"}"
    end

    if @missing.any?
      puts("***************** Missing mappings: *****************")
      @missing.each do |hesa_code|
        puts("Code: #{hesa_code.code} Label: #{hesa_code.label}")
      end
    else
      puts("No missing mappings found")
    end
    puts("\n\n")
  end
end

namespace :reference_data do
  desc "All HESA reference data checks"
  task all: %i[ethnicities sexes countries disabilities itt_aims itt_qualification_aims training_routes degree_subjects]

  desc "HESA ethnicities reference data checks"
  task ethnicities: :environment do
    HesaCodeChecker.new.call("ethnicities") do |hesa_code|
      code_set_key = Hesa::CodeSets::Ethnicities::MAPPING[hesa_code.code]
      code_set = code_set_key ? CodeSets::Ethnicities::MAPPING[code_set_key] : nil
      code_set ? code_set_key : nil
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
      country_name = Hesa::CodeSets::Countries::MAPPING[hesa_code.code]
      CodeSets::Countries::MAPPING.key?(country_name) ? country_name : nil
    end
  end

  desc "HESA disabilities reference data checks"
  task disabilities: :environment do
    HesaCodeChecker.new.call("disabilities") do |hesa_code|
      disability_name = Hesa::CodeSets::Disabilities::MAPPING[hesa_code.code]
      CodeSets::Disabilities::MAPPING.key?(disability_name) ? disability_name : nil
    end
  end

  desc "HESA ITT aims reference data checks"
  task itt_aims: :environment do
    HesaCodeChecker.new.call("itt_aims") do |hesa_code|
      name = Hesa::CodeSets::IttAims::MAPPING[hesa_code.code]
      CodeSets::IttAims::MAPPING.values.include?(name) ? name : nil
    end
  end

  desc "HESA ITT qualification aims reference data checks"
  task itt_qualification_aims: :environment do
    HesaCodeChecker.new.call("itt_qualification_aims") do |hesa_code|
      name = Hesa::CodeSets::IttQualificationAims::MAPPING[hesa_code.code]
      CodeSets::IttQualificationAims::MAPPING.values.include?(name) ? name : nil
    end
  end

  desc "HESA training routes reference data checks"
  task training_routes: :environment do
    HesaCodeChecker.new.call("training_routes") do |hesa_code|
      Hesa::CodeSets::TrainingRoutes::MAPPING[hesa_code.code]
    end
  end

  desc "HESA degree subjects reference data checks"
  task degree_subjects: :environment do
    HesaCodeChecker.new.call("degree_subjects") do |hesa_code|
      name = Hesa::CodeSets::CourseSubjects::MAPPING[hesa_code.code]
      CodeSets::CourseSubjects::MAPPING.key?(name) ? name : nil
    end
  end
end
