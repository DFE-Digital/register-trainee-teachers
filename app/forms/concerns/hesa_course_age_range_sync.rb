# frozen_string_literal: true

module HesaCourseAgeRangeSync
private

  def sync_hesa_course_age_range
    return unless trainee.hesa_trainee_detail

    trainee.hesa_trainee_detail.course_age_range = Trainees::MapCourseAgeRangeToHesa.call(trainee:)
  end
end
