# frozen_string_literal: true

module RouteIndicator
  class ViewPreview < ViewComponent::Preview
    Trainee.training_routes.each_key do |training_route|
      define_method training_route.to_s do
        render(View.new(trainee: Trainee.new(training_route: training_route)))
      end

      define_method "apply_#{training_route}" do
        render(View.new(trainee: Trainee.new(
          training_route: training_route,
          apply_application: ApplyApplication.new(application: { attributes: {} }),
          course_subject_one: "Ancient Hebrew",
          course_uuid: SecureRandom.uuid,
        )))
      end
    end
  end
end
