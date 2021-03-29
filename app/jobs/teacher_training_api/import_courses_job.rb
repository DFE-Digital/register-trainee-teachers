# frozen_string_literal: true

module TeacherTrainingApi
  class ImportCoursesJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("import_courses_from_ttapi")

      RetrieveSubjects.call.each { |s| ImportSubject.call(subject: s) }

      Provider.all.each { |p| ImportProviderCoursesJob.perform_later(p) }
    end
  end
end
