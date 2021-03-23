# frozen_string_literal: true

class TrainingRouteManager
  def initialize(trainee)
    @trainee = trainee
  end

  def requires_placement_details?
    feature_enabled?(:routes_provider_led_postgrad) && provider_led_postgrad?
  end

private

  def provider_led_postgrad?
    training_route == TRAINING_ROUTE_ENUMS[:provider_led_postgrad].to_sym
  end

  def assessment_only?
    training_route == TRAINING_ROUTE_ENUMS[:assessment_only].to_sym
  end

  def training_route
    @trainee.training_route.to_sym
  end

  def feature_enabled?(feature_name)
    FeatureService.enabled?(feature_name)
  end
end
