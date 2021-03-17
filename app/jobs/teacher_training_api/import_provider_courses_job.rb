# frozen_string_literal: true

module TeacherTrainingApi
  class ImportProviderCoursesJob < ApplicationJob
    queue_as :default

    def perform(provider)
      return unless FeatureService.enabled?("import_courses_from_ttapi")

      RetrieveCourses.call(provider: provider).each do |course|
        ImportCourse.call(provider: provider, course: course)
      end
    end
  end
end
