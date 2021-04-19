# frozen_string_literal: true

module TeacherTrainingApi
  class ImportCoursesSpikeJob < ApplicationJob
    queue_as :default

    def perform
      CoursesSpike.upsert_all(RetrieveCoursesSpike.call)
    end
  end
end
