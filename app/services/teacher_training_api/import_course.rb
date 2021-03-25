# frozen_string_literal: true

module TeacherTrainingApi
  class ImportCourse
    include ServicePattern

    # For full list, see https://api.publish-teacher-training-courses.service.gov.uk/api-reference.html#schema-courseattributes
    IMPORTABLE_STATES = %w[
      empty
      rolled_over
      published
      published_with_unpublished_changes
      withdrawn
    ].freeze

    def initialize(provider:, course:)
      @provider = provider
      @attrs = course["attributes"]
    end

    def call
      return unless IMPORTABLE_STATES.include?(attrs["state"])

      map_courses_to_subjects if course.update!(name: attrs["name"])
    end

  private

    attr_reader :provider, :attrs

    def course
      @course ||= provider.courses.find_or_initialize_by(code: attrs["code"])
    end

    def map_courses_to_subjects
      attrs["subject_codes"].each do |subject_code|
        map_course_to_subject(subject_code)
      end
    end

    def map_course_to_subject(subject_code)
      CourseSubject.create(course: course, subject: get_subject(subject_code))
    end

    def get_subject(subject_code)
      Subject.where(code: subject_code)&.first
    end
  end
end
