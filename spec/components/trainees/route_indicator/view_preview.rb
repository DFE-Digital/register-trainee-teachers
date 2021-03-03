# frozen_string_literal: true

module RouteIndicator
  class ViewPreview < ViewComponent::Preview
    Trainee.training_routes.keys.each do |training_route|
      define_method training_route.to_s do
        render(Trainees::RouteIndicator::View.new(trainee: Trainee.new(training_route: training_route)))
      end
    end
  end
end