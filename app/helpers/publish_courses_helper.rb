# frozen_string_literal: true

module PublishCoursesHelper
  def course_summary_text_for(trainee, course)
    summary_with_route = t(".summary_with_route", summary: course.summary, route: t("activerecord.attributes.trainee.training_routes.#{course.route}"))
    trainee.apply_application? ? summary_with_route : course.summary
  end
end
