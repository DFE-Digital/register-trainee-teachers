# frozen_string_literal: true

module PublishCourseNextPath
  def publish_course_next_path
    if trainee.requires_itt_start_date?
      edit_trainee_course_details_itt_start_date_path(trainee)
    else
      study_mode_or_confirmation_path
    end
  end

  def study_mode_or_confirmation_path
    if requires_study_mode?
      edit_trainee_course_details_study_mode_path(trainee)
    else
      course_confirmation_path
    end
  end

  def course_confirmation_path
    if trainee.apply_application? && trainee.draft?
      trainee_apply_applications_confirm_courses_path(trainee)
    else
      trainee_publish_course_details_confirm_path(trainee)
    end
  end

  def trainee
    @trainee ||= Trainee.from_param(params[:trainee_id])
  end

  def course
    @course ||= trainee.available_courses.find_by_uuid!(course_uuid)
  end

  def publish_course_details_form
    @publish_course_details_form ||= PublishCourseDetailsForm.new(trainee)
  end

  def requires_study_mode?
    return false unless trainee.requires_study_mode?
    return false unless course

    course.study_mode == "full_time_or_part_time"
  end
end
