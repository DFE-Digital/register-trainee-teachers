# frozen_string_literal: true

module Trainees
  class MapCourseAgeRangeToHesa
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      ::ReferenceData::COURSE_AGE_RANGES.find(trainee.course_age_range)&.hesa_code
    end

  private

    attr_reader :trainee
  end
end
