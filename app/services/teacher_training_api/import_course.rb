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

      course.update!(name: name, subjects: subjects)
    end

  private

    attr_reader :provider, :attrs

    def subjects
      Subject.where(code: attrs["subject_codes"])
    end

    def name
      attrs["name"]
    end

    def course
      @course ||= provider.courses.find_or_initialize_by(code: attrs["code"])
    end
  end
end
