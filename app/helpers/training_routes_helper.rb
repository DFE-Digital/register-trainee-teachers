# frozen_string_literal: true

module TrainingRoutesHelper
  include ApplicationHelper

  def training_routes_options
    enabled_routes.map do |training_route|
      {
        name: TRAINING_ROUTE_ENUMS[training_route],
        hint: hint(training_route),
        label: t("activerecord.attributes.trainee.training_routes.#{training_route}"),
      }
    end
  end

  def enabled_route?(route)
    FeatureService.enabled?("routes.#{route}")
  end

private

  def enabled_routes
    TRAINING_ROUTE_FEATURE_FLAGS.select do |route|
      FeatureService.enabled?("routes.#{route}")
    end
  end

  def hint(training_route)
    {
      provider_led_postgrad: t(".hints.provider_led_postgrad"),
      provider_led_undergrad: t(".hints.provider_led_undergrad"),
    }[training_route]
  end
end
