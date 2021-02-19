# frozen_string_literal: true

class TrainingRouteManager
  def initialize(trainee)
    @trainee = trainee
  end

  def requires_training_details?
    feature_enabled?(:training_details) && assessment_only?
  end

  def requires_start_date?
    feature_enabled?(:training_details) && false
  end

private

  def provider_led?
    training_route == :provider_led
  end

  def assessment_only?
    training_route == :assessment_only
  end

  def training_route
    @trainee.record_type.to_sym
  end

  def feature_enabled?(feature_name)
    FeatureService.enabled?(feature_name)
  end
end
