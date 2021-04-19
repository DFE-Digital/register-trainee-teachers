# frozen_string_literal: true

module TeacherTrainingApi
  class ImportCoursesSpikeJob < ApplicationJob
    queue_as :default

    def perform(request_uri: nil)
      @data = RetrieveCoursesSpike.call(request_uri: request_uri)

      CoursesSpike.upsert_all(courses_attributes.compact, unique_by: %i[ accredited_body_code code ])

      ImportCoursesSpikeJob.perform_later(request_uri: next_page_url) if has_next_page?
    end

  private

    attr_reader :data

    def courses_attributes
      Parsers::CoursesSpike.to_course_attributes(data: data)
    end

    def next_page_url
      data["links"]["next"]
    end

    def has_next_page?
      next_page_url.present? 
    end
  end
end
