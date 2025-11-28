# frozen_string_literal: true

class TrainingRouteManager
  delegate :training_route, to: :trainee

  def initialize(trainee)
    @trainee = trainee
  end

  def requires_degree?
    !undergrad_route?
  end

  def requires_lead_partner?
    LEAD_PARTNER_ROUTES.any? { |training_route_enums_key| enabled?(training_route_enums_key) }
  end

  def requires_employing_school?
    EMPLOYING_SCHOOL_ROUTES.any? { |training_route_enums_key| enabled?(training_route_enums_key) }
  end

  def requires_itt_start_date?
    enabled?(:pg_teaching_apprenticeship)
  end

  def requires_funding?
    training_route != ReferenceData::TRAINING_ROUTES.iqts.name
  end

  def requires_iqts_country?
    training_route == ReferenceData::TRAINING_ROUTES.iqts.name
  end

  def award_type
    TRAINING_ROUTE_AWARD_TYPE[training_route&.to_sym]
  end

  def early_years_route?
    EARLY_YEARS_TRAINING_ROUTES.keys.include?(training_route.to_s)
  end

  def requires_study_mode?
    [
      ReferenceData::TRAINING_ROUTES.assessment_only.name,
      ReferenceData::TRAINING_ROUTES.early_years_assessment_only.name,
    ].exclude?(training_route)
  end

  def requires_placements?
    PLACEMENTS_ROUTES.keys.include?(training_route)
  end

  def undergrad_route?
    UNDERGRAD_ROUTES.keys.include?(training_route)
  end

private

  attr_reader :trainee

  def enabled?(training_route_enums_key)
    FeatureService.enabled?("routes.#{training_route_enums_key}") && training_route == ReferenceData::TRAINING_ROUTES.find(training_route_enums_key.to_sym)&.name
  end
end
