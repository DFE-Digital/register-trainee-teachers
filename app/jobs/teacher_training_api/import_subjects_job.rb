# frozen_string_literal: true

module TeacherTrainingApi
  class ImportSubjectsJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("import_courses_from_ttapi")

      RetrieveSubjects.call.each { |subject| ImportSubject.call(subject:) }
    end
  end
end
