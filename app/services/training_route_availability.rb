# frozen_string_literal: true

class TrainingRouteAvailability
  include ServicePattern

  NEW_ROUTES_START_YEAR = 2024

  def initialize(trainee:, route:)
    @trainee = trainee
    @route = route
  end

  def call
    if true
      NEW_TRAINING_ROUTES.include?(route.to_s)
    else
      OLD_TRAINING_ROUTES.include?(route.to_s)
    end
  end

private

  attr_reader :trainee, :route
end
