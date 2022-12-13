# frozen_string_literal: true

module Publishable
  delegate :course_uuid, to: :publish_course_details_form

  def course
    @course ||= trainee.available_courses(training_route).find_by!(uuid: course_uuid)
  end

  def publish_course_details_form
    @publish_course_details_form ||= PublishCourseDetailsForm.new(trainee)
  end
end
