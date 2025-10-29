# frozen_string_literal: true

module TrainingRoutesHelper
  include ApplicationHelper

  def enabled_route?(route)
    FeatureService.enabled?("routes.#{route}")
  end

private

  def hint(training_route)
    {
      provider_led_postgrad: t(".hints.provider_led_postgrad"),
      provider_led_undergrad: t(".hints.provider_led_undergrad"),
    }[training_route]
  end
end
