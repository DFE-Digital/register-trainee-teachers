# frozen_string_literal: true

module PublishCoursesHelper
  def apply_course_summary(course)
    "#{course.name} (#{course.code})".strip
  end

  def apply_course_and_route_summary(course)
    t(".summary_with_route", summary: apply_course_summary(course), route: t("activerecord.attributes.trainee.training_routes.#{course.route}"))
  end

  def courses_fieldset_text
    t("views.forms.publish_course_details.route_message", route: route_title(training_route))
  end
end
