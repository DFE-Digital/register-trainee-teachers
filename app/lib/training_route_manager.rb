# frozen_string_literal: true

class TrainingRouteManager
  def initialize(trainee)
    @trainee = trainee
  end

  def requires_placement_details?
    feature_enabled?("routes.provider_led_postgrad") && provider_led_postgrad?
  end

  def requires_schools?
    %w[routes.school_direct_salaried routes.school_direct_tuition_fee].any? { |flag| feature_enabled?(flag) } && schools_direct?
  end

  def requires_employing_school?
    feature_enabled?("routes.school_direct_salaried") && schools_direct_salaried?
  end

  def award_type
    TRAINING_ROUTE_AWARD_TYPE[training_route&.to_sym]
  end

  def early_years_route?
    @trainee.training_route.to_s.starts_with?("early_years")
  end

private

  attr_reader :trainee

  def provider_led_postgrad?
    training_route == TRAINING_ROUTE_ENUMS[:provider_led_postgrad]
  end

  def assessment_only?
    training_route == TRAINING_ROUTE_ENUMS[:assessment_only]
  end

  def schools_direct?
    TRAINING_ROUTE_ENUMS.values_at(:school_direct_tuition_fee, :school_direct_salaried).include? training_route
  end

  def schools_direct_salaried?
    training_route == TRAINING_ROUTE_ENUMS[:school_direct_salaried]
  end

  def training_route
    @trainee.training_route
  end

  def feature_enabled?(feature_name)
    FeatureService.enabled?(feature_name)
  end
end
