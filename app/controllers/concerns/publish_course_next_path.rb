# frozen_string_literal: true

# Enforces HTTP Basic Auth
module PublishCourseNextPath
  def publish_course_next_path
    if trainee.requires_itt_start_date?
      edit_trainee_course_details_itt_start_date_path(trainee)
    else
      course_confirmation_path
    end
  end

  def course_confirmation_path
    if trainee.apply_application?
      trainee_apply_applications_confirm_courses_path(trainee)
    else
      edit_trainee_confirm_publish_course_path(@trainee)
    end
  end
end
