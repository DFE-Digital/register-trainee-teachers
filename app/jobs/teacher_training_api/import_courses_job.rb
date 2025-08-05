# frozen_string_literal: true

module TeacherTrainingApi
  class ImportCoursesJob < ApplicationJob
    queue_as :default
    retry_on TeacherTrainingApi::Client::HttpError

    def perform(request_uri: nil)
      return unless FeatureService.enabled?("import_courses_from_ttapi")

      payload = RetrieveCourses.call(request_uri:)

      payload[:data].each do |course_data|
        TeacherTrainingApi::ImportCourse.call(course_data: course_data, provider_data: payload[:included])
      end

      if payload[:links][:next]
        ImportCoursesJob.perform_later(request_uri: payload[:links][:next])
      else
        CheckCoursesForMissingProvidersJob.perform_later
      end
    end
  end
end
