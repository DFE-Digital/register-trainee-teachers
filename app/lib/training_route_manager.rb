# frozen_string_literal: true

class TrainingRouteManager
  def initialize(trainee)
    @trainee = trainee
  end

  def requires_placement_details?
    FeatureService.enabled?("placements") && enabled?(:provider_led_postgrad)
  end

  def requires_degree?
    !undergrad_route?
  end

  def requires_schools?
    %i[school_direct_salaried school_direct_tuition_fee pg_teaching_apprenticeship].any? { |training_route_enums_key| enabled?(training_route_enums_key) }
  end

  def requires_employing_school?
    %i[school_direct_salaried pg_teaching_apprenticeship].any? { |training_route_enums_key| enabled?(training_route_enums_key) }
  end

  def requires_itt_start_date?
    enabled?(:pg_teaching_apprenticeship)
  end

  def award_type
    TRAINING_ROUTE_AWARD_TYPE[training_route&.to_sym]
  end

  def early_years_route?
    EARLY_YEARS_TRAINING_ROUTES.keys.include?(training_route.to_s)
  end

  def itt_route?
    ITT_TRAINING_ROUTES.keys.include?(training_route)
  end

  def requires_study_mode?
    return false unless FeatureService.enabled?("course_study_mode")

    [
      TRAINING_ROUTE_ENUMS[:assessment_only],
      TRAINING_ROUTE_ENUMS[:early_years_assessment_only],
    ].exclude?(training_route)
  end

  def undergrad_route?
    UNDERGRAD_ROUTES.keys.include?(training_route)
  end

private

  attr_reader :trainee

  delegate :training_route, to: :trainee

  def enabled?(training_route_enums_key)
    FeatureService.enabled?("routes.#{training_route_enums_key}") && training_route == TRAINING_ROUTE_ENUMS[training_route_enums_key.to_sym]
  end
end
