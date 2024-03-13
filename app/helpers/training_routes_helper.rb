# frozen_string_literal: true

module TrainingRoutesHelper
  include ApplicationHelper

  def training_routes_options(trainee:)
    enabled_routes(trainee:).map do |training_route|
      {
        name: TRAINING_ROUTE_ENUMS[training_route],
        hint: hint(training_route),
        label: t("activerecord.attributes.trainee.training_routes.#{training_route}"),
      }
    end
  end

private

  def enabled_routes(trainee:)
    TRAINING_ROUTE_FEATURE_FLAGS.select do |route|
      FeatureService.enabled?("routes.#{route}") && TrainingRouteAvailability.call(trainee:, route:)
    end
  end

  def hint(training_route)
    {
      provider_led_postgrad: t(".hints.provider_led_postgrad"),
      provider_led_undergrad: t(".hints.provider_led_undergrad"),
    }[training_route]
  end
end
