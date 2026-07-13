# frozen_string_literal: true

module HesaCourseStudyModeSync
private

  def sync_hesa_course_study_mode
    return unless trainee.hesa_trainee_detail

    trainee.hesa_trainee_detail.course_study_mode = Trainees::MapStudyModeToHesa.call(trainee:)
  end
end
