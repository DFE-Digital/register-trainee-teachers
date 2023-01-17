# frozen_string_literal: true

module Hesa
  class ValidateMapping
    include ServicePattern

    HESA_FIELDS_TO_CODESETS_MAP = {
      bursary_level: Hesa::CodeSets::BursaryLevels,
      course_age_range: Hesa::CodeSets::AgeRanges,
      course_subject_one: Hesa::CodeSets::CourseSubjects,
      course_subject_three: Hesa::CodeSets::CourseSubjects,
      course_subject_two: Hesa::CodeSets::CourseSubjects,
      ethnic_background: Hesa::CodeSets::Ethnicities,
      fund_code: Hesa::CodeSets::FundCodes,
      itt_aim: Hesa::CodeSets::IttAims,
      itt_qualification_aim: Hesa::CodeSets::IttQualificationAims,
      mode: Hesa::CodeSets::StudyModes,
      reason_for_leaving: Hesa::CodeSets::ReasonsForLeavingCourse,
      sex: Hesa::CodeSets::Sexes,
      training_initiative: Hesa::CodeSets::TrainingInitiatives,
      training_route: Hesa::CodeSets::TrainingRoutes,
    }.freeze

    HESA_DISABILITIES_TO_CODESETS_MAP = {
      disability1: Hesa::CodeSets::Disabilities,
      disability2: Hesa::CodeSets::Disabilities,
      disability3: Hesa::CodeSets::Disabilities,
      disability4: Hesa::CodeSets::Disabilities,
      disability5: Hesa::CodeSets::Disabilities,
      disability6: Hesa::CodeSets::Disabilities,
      disability7: Hesa::CodeSets::Disabilities,
      disability8: Hesa::CodeSets::Disabilities,
      disability9: Hesa::CodeSets::Disabilities,
    }.freeze

    def initialize(hesa_trainee:, record_source:)
      @hesa_trainee = hesa_trainee
      @record_source = record_source
    end

    def call
      unmapped_fields = []

      HESA_FIELDS_TO_CODESETS_MAP.each do |hesa_field, code_set|
        if hesa_trainee[hesa_field].present? && code_set::MAPPING[hesa_trainee[hesa_field]].blank?
          unmapped_fields << hesa_field
        end
      end

      HESA_DISABILITIES_TO_CODESETS_MAP.each do |hesa_field, code_set|
        if hesa_trainee[hesa_field].present? && code_set::MAPPING[hesa_trainee[hesa_field]].blank?
          unmapped_fields << hesa_field
        end
      end

      Sentry.capture_message(broken_mapping_message(unmapped_fields)) if unmapped_fields.any?
    end

  private

    attr_reader :hesa_trainee, :record_source

    def broken_mapping_message(unmapped_fields)
      "Unmapped fields #{unmapped_fields} on trainee - id: #{hesa_trainee[:trainee_id]} - record source: #{record_source}"
    end
  end
end
