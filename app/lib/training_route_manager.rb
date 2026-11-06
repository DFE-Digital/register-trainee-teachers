# frozen_string_literal: true

class TrainingRouteManager
  # Early years teacher degree apprenticeship course length, in years, by
  # whether the trainee holds a level 5 qualification.
  LEVEL_FIVE_COURSE_YEARS = { true => 2, false => 3 }.freeze

  delegate :training_route, to: :trainee

  def initialize(trainee)
    @trainee = trainee
  end

  def requires_degree?
    !undergrad_route?
  end

  def requires_training_partner?
    TRAINING_PARTNER_ROUTES.any? { |training_route_enums_key| enabled?(training_route_enums_key) }
  end

  def requires_employing_school?
    EMPLOYING_SCHOOL_ROUTES.any? { |training_route_enums_key| enabled?(training_route_enums_key) }
  end

  def requires_assessment_only_employing_school?
    training_route == TRAINING_ROUTE_ENUMS[:assessment_only]
  end

  def requires_itt_start_date?
    enabled?(:pg_teaching_apprenticeship)
  end

  def requires_funding?
    training_route != TRAINING_ROUTE_ENUMS[:iqts]
  end

  def requires_iqts_country?
    training_route == TRAINING_ROUTE_ENUMS[:iqts]
  end

  # Early years teacher degree apprenticeship trainees declare whether they hold
  # a level 5 qualification.
  def requires_level_five_declaration?
    training_route == TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship]
  end

  # The EYTDA course is shorter for trainees who already hold a level 5
  # qualification: 2 years, otherwise (or until it's declared) 3 years.
  def level_five_course_years
    return unless requires_level_five_declaration?

    LEVEL_FIVE_COURSE_YEARS.fetch(trainee.level_five_qualification == true)
  end

  def award_type
    TRAINING_ROUTE_AWARD_TYPE[training_route&.to_sym]
  end

  def early_years_route?
    EARLY_YEARS_TRAINING_ROUTES.keys.include?(training_route.to_s)
  end

  def requires_study_mode?
    [
      TRAINING_ROUTE_ENUMS[:assessment_only],
      TRAINING_ROUTE_ENUMS[:early_years_assessment_only],
    ].exclude?(training_route)
  end

  def requires_placements?
    PLACEMENTS_ROUTES.keys.include?(training_route)
  end

  def minimum_placements
    MINIMUM_PLACEMENTS[training_route]
  end

  def undergrad_route?
    UNDERGRAD_ROUTES.keys.include?(training_route)
  end

private

  attr_reader :trainee

  def enabled?(training_route_enums_key)
    FeatureService.enabled?("routes.#{training_route_enums_key}") && training_route == TRAINING_ROUTE_ENUMS[training_route_enums_key.to_sym]
  end
end
