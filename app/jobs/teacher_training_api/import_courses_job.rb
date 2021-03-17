# frozen_string_literal: true

module TeacherTrainingApi
  class ImportCoursesJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("import_courses_from_ttapi")

      Provider.all.each do |provider|
        ImportProviderCoursesJob.perform_later(provider)
      end
    end
  end
end
