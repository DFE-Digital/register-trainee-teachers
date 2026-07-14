# frozen_string_literal: true

module Trainees
  class MapStudyModeToHesa
    include ServicePattern

    STUDY_MODE_TO_HESA = {
      COURSE_STUDY_MODES[:full_time] => "01",
      COURSE_STUDY_MODES[:part_time] => "31",
    }.freeze

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return stored_code if selected_mode_value.nil?
      return stored_code if ::Hesa::CodeSets::StudyModes::MAPPING[stored_code] == selected_mode_value

      STUDY_MODE_TO_HESA[trainee.study_mode]
    end

  private

    attr_reader :trainee

    def stored_code
      trainee.hesa_trainee_detail&.course_study_mode
    end

    def selected_mode_value
      Trainee.study_modes[trainee.study_mode]
    end
  end
end
