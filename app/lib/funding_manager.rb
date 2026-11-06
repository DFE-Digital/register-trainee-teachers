# frozen_string_literal: true

class FundingManager
  BURSARY_TIER_AMOUNTS = {
    tier_one: 5_000,
    tier_two: 4_000,
    tier_three: 2_000,
  }.with_indifferent_access.freeze

  # Funding eligibility step (behind the funding_eligibility_step flag).
  # Route groupings for the eligibility content. See #eligibility_content_key.
  NON_EARLY_YEARS_NO_FUNDING_ROUTES = TRAINING_ROUTE_ENUMS.values_at(
    :assessment_only,
    :iqts,
    :hpitt_postgrad,
  ).freeze

  EARLY_YEARS_NO_FUNDING_ROUTES = TRAINING_ROUTE_ENUMS.values_at(
    :early_years_assessment_only,
    :early_years_undergrad,
  ).freeze

  GRANT_ROUTES = TRAINING_ROUTE_ENUMS.values_at(
    :school_direct_salaried,
    :pg_teaching_apprenticeship,
  ).freeze

  # Funding is managed, signed off and released in funding management from
  # this academic year. Earlier years keep their funding rules in code.
  FUNDING_MANAGEMENT_START_YEAR = 2027

  # Early years teacher degree apprenticeship (EYTDA) funding is managed a year
  # earlier, from 2026 to 2027.
  EYTDA_ROUTE = TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship]
  EYTDA_FUNDING_MANAGEMENT_START_YEAR = 2026

  def self.funding_management_start_year(training_route)
    training_route.to_s == EYTDA_ROUTE ? EYTDA_FUNDING_MANAGEMENT_START_YEAR : FUNDING_MANAGEMENT_START_YEAR
  end

  # The year whose EYTDA amounts apply to trainees starting in start_year: the
  # latest year from 2026 to 2027 up to start_year that has EYTDA amounts.
  def self.eytda_funding_cycle_for(start_year)
    return if start_year.to_i < EYTDA_FUNDING_MANAGEMENT_START_YEAR

    AcademicCycle.where(id: FundingMethod.where(training_route: EYTDA_ROUTE).select(:academic_cycle_id))
      .select { |cycle| cycle.start_year.between?(EYTDA_FUNDING_MANAGEMENT_START_YEAR, start_year.to_i) }
      .max_by(&:start_year)
  end

  # Teacher degree apprenticeship pilot (2026 to 2027 and earlier): a grant for
  # secondary mathematics with no published amount. From 2027 to 2028 the grant
  # is an ordinary funding management record.
  TEACHER_DEGREE_APPRENTICESHIP_GRANT_SUBJECTS = [AllocationSubjects::MATHEMATICS].freeze

  # Early years graduate employment based funding is stored as one combined
  # grant (16,535) and shown as a training grant paid to the provider plus an
  # employer incentive paid to the employer. Display only; they sum to the grant.
  EARLY_YEARS_SALARIED_TRAINING_GRANT = 9_535
  EARLY_YEARS_SALARIED_EMPLOYER_INCENTIVE = 7_000

  NO_FUNDING_CONTENT_KEYS = %i[no_funding no_funding_early_years no_funding_subject no_funding_degree].freeze

  def initialize(trainee, funding_eligibility: nil)
    @trainee = trainee
    @allocation_subject = trainee.course_allocation_subject
    @academic_cycle = trainee.start_academic_cycle
    @funding_eligibility = funding_eligibility || trainee.funding_eligibility
  end

  # The year whose funding records apply to the trainee. Usually their start
  # year. EYTDA amounts aren't set again each year: those entered for a year
  # (from 2026 to 2027) apply to every later start year until newer ones are
  # added, so it's the latest year up to the trainee's start year that has them.
  def funding_cycle
    return @funding_cycle if defined?(@funding_cycle)

    @funding_cycle = eytda_funding_cycle || academic_cycle
  end

  # The trainee uses EYTDA amounts entered for an earlier year.
  def funding_carried_forward?
    funding_cycle.present? && academic_cycle.present? && funding_cycle != academic_cycle
  end

  def applicable_available_funding
    if can_apply_for_tiered_bursary?
      :grant_and_tiered_bursary
    elsif can_apply_for_grant?
      :grant
    else
      :non_tiered_bursary
    end
  end

  def bursary_amount
    if bursary_tier.present?
      BURSARY_TIER_AMOUNTS[bursary_tier]
    else
      available_bursary_amount
    end
  end

  def scholarship_amount
    available_amount(:scholarship)
  end

  def grant_amount
    available_amount(:grant)
  end

  def can_apply_for_funding_type?
    can_apply_for_bursary? || can_apply_for_scholarship? || can_apply_for_grant?
  end

  def can_apply_for_bursary?
    can_apply_for_tiered_bursary? || (funding_open? && available_bursary_amount.present?)
  end

  def can_apply_for_tiered_bursary?
    funding_open? && trainee.early_years_postgrad?
  end

  def can_apply_for_scholarship?
    funding_open? && scholarship_amount.present?
  end

  def can_apply_for_grant?
    funding_open? && grant_amount.present?
  end

  def eligibility_step?
    FeatureService.enabled?(:funding_eligibility_step)
  end

  # Whether the trainee can be given funding at all. Always true without the
  # eligibility step. With it, the year's funding must be signed off and
  # released, and the trainee must not have been answered "not eligible".
  def funding_open?
    !eligibility_step? || ((funding_signed_off? || draft_amounts_usable?) && eligible_for_funding?)
  end

  # Internal testing only (funding_draft_amounts_in_journey): the journey can use
  # draft amounts for a year that isn't signed off, under the "Amount not signed
  # off" banner. No TRN can be requested with them (Submissions::TrnValidator).
  def draft_amounts_usable?
    FeatureService.enabled?(:funding_draft_amounts_in_journey)
  end

  def using_draft_amounts?
    eligibility_step? && !funding_signed_off? && draft_amounts_usable?
  end

  def eligible_for_funding?
    return true unless eligibility_step?

    # nil and "eligible" are treated the same. Only an explicit "not eligible"
    # answer stops funding, unless the fund code exception applies.
    return true if funding_eligibility != FUNDING_ELIGIBILITIES[:not_eligible]

    FundCodeException.applies_to?(allocation_subject:, academic_cycle:)
  end

  # Funding from 2027 to 2028 comes from funding management: providers can
  # only use it once the year is signed off and its start date has passed.
  def funding_signed_off?
    return true if academic_cycle.nil? || academic_cycle.start_year < self.class.funding_management_start_year(training_route)

    funding_cycle.published? && funding_cycle.start_date <= Time.zone.today
  end

  # Early years graduate employment based shows its grant as a training grant
  # plus an employer incentive, when the stored grant is the combined amount.
  def early_years_salaried_grant?
    eligibility_step? && trainee.early_years_salaried? && can_apply_for_grant? &&
      grant_amount == EARLY_YEARS_SALARIED_TRAINING_GRANT + EARLY_YEARS_SALARIED_EMPLOYER_INCENTIVE
  end

  # Which eligibility content the trainee sees. First match wins:
  #   :not_signed_off, :training_bursary, :training_grant, :training_grant_by_year,
  #   :no_funding, :no_funding_early_years, :no_funding_subject, :grant, :bursary_scholarship
  def eligibility_content_key
    return :not_signed_off unless funding_signed_off? || draft_amounts_usable?
    return :training_bursary if trainee.early_years_postgrad?
    return :training_grant if trainee.early_years_salaried?
    return (funding_for_subject? ? :training_grant_by_year : :no_funding_early_years) if yearly_route?
    return :no_funding if NON_EARLY_YEARS_NO_FUNDING_ROUTES.include?(training_route)
    return :no_funding_early_years if EARLY_YEARS_NO_FUNDING_ROUTES.include?(training_route)
    return teacher_degree_apprenticeship_content_key if training_route == TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship]
    return :no_funding_degree if allocation_subject && academic_cycle && !funding_for_subject? && unavailable_for_degree_types.any?
    return :no_funding_subject if allocation_subject && academic_cycle && !funding_for_subject?

    GRANT_ROUTES.include?(training_route) ? :grant : :bursary_scholarship
  end

  def no_funding?
    NO_FUNDING_CONTENT_KEYS.include?(eligibility_content_key)
  end

  # No question is asked: no funding, or the year's funding isn't signed off yet.
  def eligibility_informational?
    no_funding? || eligibility_content_key == :not_signed_off
  end

  # Funding types funding management marks "not available" for the trainee's
  # unrelated degree, for example a bursary only for a relevant degree.
  def unavailable_for_degree_types
    return [] unless allocation_subject && academic_cycle && degree_relevance.answer == :unrelated

    %w[bursary scholarship grant].select do |funding_type|
      matches = matching_funding_methods(funding_type)
      matches.any? && matches.none?(&:available?)
    end
  end

  # Details the trainee's funding depends on that haven't been entered yet, in
  # the order to ask for them. The funding pages can't be used until they are:
  #   :degree           — a funding record is split by degree relevance
  #   :employing_school — a funding record is split by the employing school's designation
  def funding_prerequisites
    return [] unless eligibility_step? && allocation_subject && academic_cycle

    [
      (:degree if trainee.requires_degree? && !degree_recorded? && split_by?(:degree_relevance)),
      (:employing_school if trainee.requires_employing_school? && !trainee.employing_school_recorded? && split_by?(:school_disadvantage)),
    ].compact
  end

  # Whether the trainee's funding records (route, subject and year) depend on
  # the degree or the employing school, so a change to it needs the funding
  # checking again (Funding::RecheckAfterChange).
  DEPENDS_ON_COLUMNS = { degree: :degree_relevance, employing_school: :school_disadvantage }.freeze

  def funding_depends_on?(detail)
    return false unless allocation_subject && academic_cycle

    split_by?(DEPENDS_ON_COLUMNS.fetch(detail.to_sym))
  end

  # Why the amount applies, when it depends on the degree, for the funding type page:
  # { key: :relevant, degree: "Mathematics" }, { key: :not_relevant, degrees: [...] }, or nil.
  def degree_explanation
    return unless explanations_shown? && split_by?(:degree_relevance)

    case degree_relevance.answer
    when :relevant then { key: :relevant, degree: degree_relevance.relevant_degree_subject }
    when :unrelated then { key: :not_relevant, degrees: degree_relevance.degree_subjects }
    end
  end

  # Why the amount applies, when it depends on the employing school:
  # { key: :listed or :not_listed, school: "Name (URN 123456)" }, or nil.
  def employing_school_explanation
    return unless explanations_shown? && split_by?(:school_disadvantage)

    case school_designation.answer
    when :disadvantaged then { key: :listed, school: school_designation.school_label }
    when :non_disadvantaged then { key: :not_listed, school: school_designation.school_label }
    end
  end

  def unrelated_degree_subject
    degree_relevance.degree_subject if degree_relevance.answer == :unrelated
  end

  # The bursary and scholarship pre-deadline offer exception (languages and physics).
  def offer_exception_subject?
    FundCodeException.applies_to?(allocation_subject:, academic_cycle:)
  end

  def funding_available?
    Rails.cache.fetch("FundingManager.funding_available?/#{training_route}/#{academic_cycle&.id}", expires_in: 1.day) do
      funding_methods = academic_cycle.nil? ? FundingMethod.all : academic_cycle.funding_methods
      funding_methods.includes(:funding_method_subjects)
                    .where.not(funding_method_subjects: { id: nil })
                    .where(training_route:).present?
    end
  end

  def allocation_subject_name
    allocation_subject&.name
  end

  # Routes funded per year of training (EYTDA) have one amount per training year.
  def yearly_route?
    ::Funding::AmountMatrix::YEARLY_ROUTES.key?(training_route.to_s)
  end

  # The funded training year the trainee is in: their year of the course (the
  # HESA course year when it is one, otherwise the years since they started),
  # counted from their first funded year. Nil for routes not funded per training year.
  def training_year
    return unless yearly_route? && academic_cycle

    years = training_years
    course_year = trainee.hesa_trainee_detail&.course_year.to_i
    # A HESA course year after a shortened (level 5) course ends has no grant.
    return if shortened_by_level_five? && course_year > years

    year_of_course = if course_year.between?(1, years)
                       course_year
                     else
                       (AcademicCycle.current&.start_year.to_i - academic_cycle.start_year + 1).clamp(1, years)
                     end
    year_of_course + first_funded_year - 1
  end

  # "Year 2 (26/27)": the funded year, with the academic year the trainee is in it.
  def training_year_label(year = training_year)
    return if year.blank?

    ::Funding::AmountMatrix.year_label(year, academic_cycle.start_year - first_funded_year + 1)
  end

  # The number of training years funded: for EYTDA, 2 with a level 5
  # qualification and 3 without (the Level 5 declaration).
  def training_years
    return unless yearly_route?

    trainee.level_five_course_years || ::Funding::AmountMatrix::YEARLY_ROUTES[training_route.to_s]
  end

  # The course is shorter than the funded years, because of a level 5 qualification.
  def shortened_by_level_five?
    yearly_route? && trainee.level_five_qualification == true &&
      training_years < ::Funding::AmountMatrix::YEARLY_ROUTES[training_route.to_s]
  end

  # A trainee with a level 5 qualification skips Year 1 of the apprenticeship, so
  # their first year is funded as Year 2 and their second as Year 3. Otherwise Year 1.
  def first_funded_year
    return 1 unless shortened_by_level_five?

    ::Funding::AmountMatrix::YEARLY_ROUTES[training_route.to_s] - training_years + 1
  end

  # The funded training years: 1..3, or 2..3 with a level 5 qualification.
  def funded_years
    return unless yearly_route?

    first_funded_year..(first_funded_year + training_years - 1)
  end

  # { 2 => 8_236, 3 => 6_177 } for the trainee's start year, for their funded years.
  def grant_amounts_by_year
    return {} unless yearly_route? && allocation_subject && academic_cycle

    allocation_subject.funding_methods
      .where(training_route: training_route, funding_type: :grant, academic_cycle: funding_cycle)
      .where(training_year: funded_years)
      .order(:training_year)
      .to_h { |funding_method| [funding_method.training_year, funding_method.amount] }
  end

  def funding_guidance_url
    academic_year = academic_cycle.label.parameterize
    key = trainee.early_years_route? ? :early_years_guidance_url : :guidance_url
    I18n.t("views.forms.funding.bursaries.#{key}", academic_year:)
  end

  def funding_guidance_link_text
    "#{academic_cycle.label} (opens a new tab)"
  end

private

  attr_reader :trainee, :funding_eligibility, :academic_cycle, :allocation_subject

  delegate :training_route, :course_subject_one, :bursary_tier, to: :trainee

  def funding_for_subject?
    available_amount(:bursary).present? ||
      available_amount(:scholarship).present? ||
      available_amount(:grant).present?
  end

  def explanations_shown?
    eligibility_step? && allocation_subject && academic_cycle && !trainee.early_years_route? && !yearly_route?
  end

  # Whether any of the trainee's funding records (route, subject and year) depend on a detail.
  def split_by?(column)
    @split_by ||= {}
    return @split_by[column] if @split_by.key?(column)

    @split_by[column] = allocation_subject.funding_methods.where(training_route: training_route, academic_cycle: funding_cycle).where.not(column => nil).exists?
  end

  # At least one degree with a subject, as that decides its relevance.
  def degree_recorded?
    trainee.degrees.any? { |degree| degree.subject.present? || degree.subject_uuid.present? }
  end

  def teacher_degree_apprenticeship_content_key
    return :grant if funding_for_subject? || teacher_degree_apprenticeship_pilot_grant?
    return :no_funding_subject if allocation_subject

    :no_funding
  end

  def teacher_degree_apprenticeship_pilot_grant?
    academic_cycle.present? && academic_cycle.start_year < FUNDING_MANAGEMENT_START_YEAR &&
      TEACHER_DEGREE_APPRENTICESHIP_GRANT_SUBJECTS.include?(allocation_subject_name)
  end

  def available_bursary_amount
    available_amount(:bursary)
  end

  def available_amount(funding_type)
    return unless allocation_subject && academic_cycle

    @available_amounts ||= {}
    return @available_amounts[funding_type] if @available_amounts.key?(funding_type)

    # Records that fit the trainee's degree and employing school; "not available"
    # ones give no amount. While either isn't known, the highest available amount ("up to").
    @available_amounts[funding_type] = matching_funding_methods(funding_type).select(&:available?).filter_map(&:amount).max
  end

  def matching_funding_methods(funding_type)
    @matching_funding_methods ||= {}
    @matching_funding_methods[funding_type.to_s] ||= allocation_subject.funding_methods
      .where(training_year: (training_year if funding_type.to_s == "grant"))
      .where(training_route: training_route, funding_type: funding_type, academic_cycle: funding_cycle)
      .to_a
      .select { |funding_method| degree_relevance.matches?(funding_method) && school_designation.matches?(funding_method) }
  end

  def eytda_funding_cycle
    return unless training_route.to_s == EYTDA_ROUTE && academic_cycle

    self.class.eytda_funding_cycle_for(academic_cycle.start_year)
  end

  def degree_relevance
    @degree_relevance ||= ::Funding::DegreeRelevance.new(trainee, academic_cycle:, allocation_subject:)
  end

  def school_designation
    @school_designation ||= ::Funding::SchoolDesignation.new(trainee, academic_cycle:)
  end
end
