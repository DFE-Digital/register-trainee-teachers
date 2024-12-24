# frozen_string_literal: true

module BulkUpdate
  class SampleTraineeDataGenerator
    include ServicePattern

    attr_accessor :file_name, :count, :with_invalid_records, :with_incomplete_records

    def initialize(
        file_name:,
        count:,
        with_invalid_records: false,
        with_incomplete_records: false
    )
      self.file_name = file_name
      self.count = count
      self.with_invalid_records = with_invalid_records
      self.with_incomplete_records = with_incomplete_records
    end

    def call
      CSV.open(file_name, "wb") do |csv|
        csv << column_labels
        count.times do |_row|
          csv << adjust_row(csv_row)
        end
      end
    end

  private

    def generate_row_data
      keys = %w[first_names last_name previous_last_name date_of_birth sex email nationality training_route itt_start_date itt_end_date course_subject_one study_mode disability1 disability2 disability3 itt_aim itt_qualification_aim course_year course_age_range fund_code funding_method hesa_id provider_trainee_id pg_apprenticeship_start_date]
      trainee = FactoryBot.build(:trainee, :completed, :with_hesa_trainee_detail)
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
        training_route: "11",
        study_mode: Hesa::CodeSets::StudyModes::MAPPING.keys.sample,
        course_subject_one: Hesa::CodeSets::CourseSubjects::MAPPING.keys.sample,
        sex: Hesa::CodeSets::Sexes::MAPPING.keys.sample,
        course_age_range: Hesa::CodeSets::AgeRanges::MAPPING.keys.sample,
      ).with_indifferent_access
    end

    def csv_row
      row_values = generate_row_data
      column_labels.map do |column_label|
        attribute_name = BulkUpdate::AddTrainees::ImportRows::TRAINEE_HEADERS[column_label]
        row_values[attribute_name]
      end
    end

    def column_labels
      @column_labels ||= BulkUpdate::AddTrainees::ImportRows::TRAINEE_HEADERS.keys
    end

    def column_ids
      @column_ids ||= BulkUpdate::AddTrainees::ImportRows::TRAINEE_HEADERS.values
    end

    def adjust_row(row)
      if with_invalid_records
        invalidate_fields(row)
      elsif with_incomplete_records
        remove_mandatory_fields(row)
      else
        row
      end
    end

    def remove_mandatory_fields(row)
      # TODO: Randomise this
      row.tap do |r|
        r[column_ids.index("date_of_birth")] = nil
      end
    end

    def invalidate_fields(row)
      # TODO: Randomise this
      row.tap do |r|
        r[column_ids.index("training_route")] = "12"
      end
    end
  end
end

