# frozen_string_literal: true

class TrainingRouteManager
  # Early years teacher degree apprenticeship course length, in years, by
  # whether the trainee enters at Year 2 with a Level 5 Early Years Lead
  # Practitioner qualification. Sets the funded years.
  LEVEL_FIVE_COURSE_YEARS = { true => 2, false => 3 }.freeze
  # The usual course length in months, which sets the expected end date and
  # when a course counts as longer than usual: 2 years for Year 2 entry,
  # otherwise the standard 3 years (33 months).
  LEVEL_FIVE_COURSE_MONTHS = { true => 24, false => 33 }.freeze

  # "2 years" or "33 months": a usual course length, as the pages write it.
  def self.course_length_text(months)
    (months % 12).zero? ? "#{months / 12} #{'year'.pluralize(months / 12)}" : "#{months} #{'month'.pluralize(months)}"
  end

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

  # The usual EYTDA course length in months: 24 for Year 2 entry, otherwise (or
  # until it's declared) 33.
  def level_five_course_months
    return unless requires_level_five_declaration?

    LEVEL_FIVE_COURSE_MONTHS.fetch(trainee.level_five_qualification == true)
  end

  # Early years teacher degree apprentices work in an employing setting, which may
  # be a nursery without a URN, so it can be searched for or typed in.
  def requires_employing_setting?
    enabled?(:early_years_teacher_degree_apprenticeship)
  end

  # Early years teacher degree apprentices aren't asked about ITT training initiatives.
  def requires_training_initiative?
    training_route != TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship]
  end

  def award_type
    TRAINING_ROUTE_AWARD_TYPE[training_route&.to_sym]
  end

  def early_years_route?
    EARLY_YEARS_TRAINING_ROUTES.keys.include?(training_route.to_s)
  end

  # The early years teacher degree apprenticeship is full time only, so there's no choice to make.
  def requires_study_mode?
    [
      TRAINING_ROUTE_ENUMS[:assessment_only],
      TRAINING_ROUTE_ENUMS[:early_years_assessment_only],
      TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship],
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
