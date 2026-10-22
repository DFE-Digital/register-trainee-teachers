# frozen_string_literal: true

module SystemAdmin
  module FundingMethodsHelper
    # Whether a year's funding reference data (funding requirements AND the
    # funding schools list) can still be edited. Blocked once the year has gone
    # live or ended (AcademicCycle#funding_locked?), and while it is signed off
    # (Ready for release) or awaiting approval: the whole year's data is approved
    # together and goes live on the start date.
    def funding_year_editable?(cycle)
      return false unless FeatureService.enabled?("funding_management_edit")
      return false if cycle.blank? || cycle.funding_locked?

      # Signed off (or awaiting a decision): locked until reopened from Drafts.
      !(cycle.awaiting_publication_approval? || cycle.published?)
    end

    # Alias kept for funding-requirements callers.
    def can_add_funding?(cycle) = funding_year_editable?(cycle)

    # A year that has gone live but can still have EYTDA funding drafted for it
    # (2026 to 2027): EYTDA grants only.
    def eytda_only_funding_cycle?(cycle)
      FeatureService.enabled?("funding_management_edit") && cycle.present? && cycle.locked_except_eytda?
    end

    # Future years funding can still be added to, newest first.
    def addable_cycles
      AcademicCycle.order(start_date: :desc).select { |cycle| can_add_funding?(cycle) }
    end

    # The choices on the add funding wizard's academic-year step: the addable
    # years, and 2026 to 2027 for EYTDA only.
    def add_funding_cycles
      AcademicCycle.order(start_date: :desc).select { |cycle| can_add_funding?(cycle) || eytda_only_funding_cycle?(cycle) }
    end

    # The wizard's chosen year, when it's open to EYTDA funding only.
    def eytda_only_add_funding_cycle(academic_year)
      cycle = AcademicCycle.for_year(academic_year.to_i) if academic_year.present?
      cycle if eytda_only_funding_cycle?(cycle)
    end

    def eytda_only_message(cycle)
      "For #{cycle.label}, only Early years teacher degree apprenticeship (EYTDA) grants can be added."
    end

    # [start_year, label] options for the wizard's academic-year step.
    def addable_cycle_options
      add_funding_cycles.map do |cycle|
        label = eytda_only_funding_cycle?(cycle) ? "#{cycle.label} (EYTDA only)" : cycle.label
        [cycle.start_year, label]
      end
    end

    def funding_route_name(training_route)
      t("activerecord.attributes.trainee.training_routes.#{training_route}", default: training_route.to_s.humanize)
    end

    def funding_type_label(funding_type)
      funding_type.to_s.humanize
    end

    # [value, label] pairs for the add-funding form selects/checkboxes.
    def funding_type_options
      FundingMethod.funding_types.keys.map { |key| [key, funding_type_label(key)] }
    end

    # The training-route enum key, written properly (e.g. provider_led_postgrad
    # -> "Provider led postgraduate"). Used on the Add funding wizard where the
    # raw route is the vocabulary, not the funding-facing name. Acronyms and the
    # postgrad/undergrad abbreviations are corrected via an explicit map.
    ROUTE_ENUM_DISPLAY_NAMES = {
      "assessment_only" => "Assessment only",
      "early_years_assessment_only" => "Early years assessment only",
      "early_years_postgrad" => "Early years postgraduate",
      "early_years_salaried" => "Early years salaried",
      "early_years_undergrad" => "Early years undergraduate",
      "iqts" => "iQTS",
      "opt_in_undergrad" => "Opt-in undergraduate",
      "provider_led_postgrad" => "Provider led postgraduate",
      "provider_led_undergrad" => "Provider led undergraduate",
      "school_direct_tuition_fee" => "School direct tuition fee",
      "school_direct_salaried" => "School direct salaried",
      "pg_teaching_apprenticeship" => "Postgraduate teaching apprenticeship",
      "hpitt_postgrad" => "HPITT postgraduate",
      "teacher_degree_apprenticeship" => "Teacher degree apprenticeship",
      "early_years_teacher_degree_apprenticeship" => "Early years teacher degree apprenticeship (EYTDA)",
    }.freeze

    def route_enum_name(route)
      ROUTE_ENUM_DISPLAY_NAMES.fetch(route.to_s) do
        route.to_s.humanize.gsub(/\bpostgrad\b/i, "postgraduate").gsub(/\bundergrad\b/i, "undergraduate")
      end
    end

    def training_route_options
      TRAINING_ROUTE_ENUMS.values.map { |route| [route, route_enum_name(route)] }
    end

    # Funding methods offered on the Add funding wizard, keyed by funding type.
    # HESA burslev codes, except early_years_tiered, which stands for Tier 1/2/3
    # (codes 7/8/9) and is expanded into one record per tier on save.
    FUNDING_METHOD_CODES_BY_TYPE = {
      "bursary" => ["D", "B", "C", ::Funding::AmountMatrix::EARLY_YEARS_TIERED],
      "scholarship" => %w[4],
      "grant" => %w[E],
    }.freeze

    EARLY_YEARS_TIERED_LABEL = "Early years tiered bursary"
    TIER_LABELS = ::Funding::AmountMatrix::TIERS.to_h { |_tier, name, code| [code, name] }.freeze

    FUNDING_METHOD_HINTS = {
      ::Funding::AmountMatrix::EARLY_YEARS_TIERED => "Only for the Early years postgraduate route. You’ll enter an amount for each of the 3 tiers.",
    }.freeze

    # [code, label] pairs for the funding-method step, filtered to a funding
    # type; the full list when no type is given.
    def funding_method_options(funding_type = nil)
      codes =
        if funding_type.present?
          FUNDING_METHOD_CODES_BY_TYPE.fetch(funding_type.to_s, [])
        else
          FUNDING_METHOD_CODES_BY_TYPE.values.flatten
        end
      codes.map { |code| [code, funding_method_label(code)] }
    end

    # "27/28" for the 2027 to 2028 academic year.
    def short_academic_year(cycle)
      format("%02d/%02d", cycle.start_year % 100, (cycle.start_year + 1) % 100)
    end

    # "Year 2 (28/29)" for funding set per year of training; nil otherwise.
    def training_year_label(training_year, start_year)
      return if training_year.blank?

      ::Funding::AmountMatrix.year_label(training_year, start_year)
    end

    def funding_method_hint(code)
      FUNDING_METHOD_HINTS[code.to_s]
    end

    # Tier 1/2/3 records read as one set: "Early years tiered bursary: Tier 1".
    def funding_method_label(code)
      return EARLY_YEARS_TIERED_LABEL if ::Funding::AmountMatrix.early_years_tiered?(code)
      return "#{EARLY_YEARS_TIERED_LABEL}: #{TIER_LABELS[code.to_s]}" if TIER_LABELS.key?(code.to_s)

      Hesa::CodeSets::BursaryLevels::VALUES[code.to_s]
    end

    # The funding-method cell for the entries list. Precedence:
    #   1. the stored HESA burslev code (admin-selected on Add funding), then
    #   2. a value derived from the band the same way Trainees::MapFundingToHesa
    #      derives it from a trainee's route (scholarship -> Scholarship,
    #      grant -> Grant, bursary -> Postgraduate/Undergraduate bursary by
    #      route), then
    #   3. the coarse funding-type label as a last resort.
    # Tier 1/2/3 and Veteran only appear when explicitly stored (they cannot be
    # inferred from a band).
    def funding_method_cell(code, funding_type, training_route)
      return funding_method_label(code) if code.present?

      funding_method_label(derived_funding_method_code(funding_type, training_route)) || funding_type_label(funding_type)
    end

    # The burslev code derivable from a band alone (mirrors the route branch of
    # Trainees::MapFundingToHesa). Returns nil when it cannot be determined.
    def derived_funding_method_code(funding_type, training_route)
      levels = Hesa::CodeSets::BursaryLevels
      case funding_type.to_s
      when "scholarship" then levels::SCHOLARSHIP
      when "grant"       then levels::GRANT
      when "bursary"
        UNDERGRAD_ROUTES.key?(training_route) ? levels::UNDERGRADUATE_BURSARY : levels::POSTGRADUATE_BURSARY
      end
    end

    # The choices on the education phase step.
    def education_phase_options
      [%w[primary Primary], %w[secondary Secondary], %w[both Both]]
    end

    # "Not applicable" isn't a choice: early years routes set it automatically
    # (they skip the step), and Check your answers still shows it.
    def education_phase_label(value)
      return "Not applicable" if value.to_s == "not_applicable"

      education_phase_options.find { |v, _| v == value.to_s }&.last
    end

    def yes_no_options
      [%w[yes Yes], %w[no No]]
    end

    def yes_no_label(value)
      value.to_s == "yes" ? "Yes" : "No"
    end

    # Human bucket names for the training-routes step (from TRAINING_ROUTE_TYPES).
    TRAINING_ROUTE_BUCKET_NAMES = {
      postgrad_funded: "Postgraduate (fee funded)",
      postgrad_salaried: "Postgraduate (salaried)",
      undergrad_funded: "Undergraduate (fee funded)",
      other: "Other",
    }.freeze

    # [bucket_name, [[route_value, route_name], ...]] for the grouped, bucketed
    # training-routes checkbox step. Early years routes are lifted out of the
    # postgrad/undergrad/other buckets into their own "Early years" group,
    # inserted just before "Other".
    def training_route_buckets
      early_years = TRAINING_ROUTE_ENUMS.values.select { |route| route.start_with?(EARLY_YEARS_ROUTE_NAME_PREFIX) }

      buckets = []
      TRAINING_ROUTE_TYPES.each do |bucket_key, routes|
        bucket_name = TRAINING_ROUTE_BUCKET_NAMES.fetch(bucket_key, bucket_key.to_s.humanize)
        buckets << ["Early years", early_years] if bucket_name == TRAINING_ROUTE_BUCKET_NAMES[:other]

        non_early_years = routes.reject { |route| route.start_with?(EARLY_YEARS_ROUTE_NAME_PREFIX) }
        buckets << [bucket_name, non_early_years] if non_early_years.any?
      end

      buckets.map { |name, routes| [name, routes.map { |route| [route, route_enum_name(route)] }] }
    end

    # Award type (QTS / EYTS) derived from the selected routes — used to show
    # the derived value alongside the QTS answer on Check your answers.
    def derived_award_types(routes)
      Array(routes).reject(&:blank?).map { |route|
        TRAINING_ROUTE_AWARD_TYPE[route.to_sym]
      }.compact.uniq
    end

    # The amount, or a grey "Bursary not available" tag for a record that says
    # the funding type isn't available (for example for an unrelated degree).
    def funding_amount_display(amount, funding_type:, availability: nil)
      return govuk_tag(text: FundingMethod.not_available_label(funding_type), colour: "grey") if availability.to_s == "not_available"

      format_currency(amount)
    end

    # A list of amount bands for one funding type as green tags, or a grey
    # "Not offered" tag.
    def funding_amounts_cell(amounts)
      return govuk_tag(text: "Not offered", colour: "grey") if amounts.blank?

      safe_join(amounts.map { |amount| govuk_tag(text: format_currency(amount), colour: "green") }, " ")
    end

    def funding_route_tag(training_route)
      govuk_tag(text: funding_route_name(training_route), colour: "blue")
    end

    # Plain route-name link to the route's detailed funding requirement.
    def funding_route_link(training_route, academic_year:)
      govuk_link_to(funding_route_name(training_route), funding_management_funding_method_path(training_route, academic_year:), no_visited_state: true)
    end

    # Route tag that links to the route's detailed funding requirement.
    def funding_route_tag_link(training_route, academic_year:)
      link_to(
        funding_route_tag(training_route),
        funding_management_funding_method_path(training_route, academic_year:),
        class: "govuk-link govuk-link--no-visited-state",
        style: "text-decoration: none;",
      )
    end

    # Subject name that links to the subject's detailed funding requirement.
    # Opens on "all academic years" (the subject page has its own year filter).
    def funding_subject_link(name, subject_id, academic_year: "all")
      govuk_link_to(name, funding_management_subject_path(subject_id, academic_year: "all"), no_visited_state: true)
    end

    FUNDING_TYPE_TAG_COLOURS = { "bursary" => "teal", "scholarship" => "purple", "grant" => "orange" }.freeze

    def funding_type_tag(funding_type)
      govuk_tag(text: funding_type_label(funding_type), colour: FUNDING_TYPE_TAG_COLOURS.fetch(funding_type.to_s, "grey"))
    end

    # Plain-text status label (for dropdown options, which can't hold tag HTML).
    def academic_year_status_label(cycle)
      cycle.ready_for_release? ? "Ready for release" : cycle.status.to_s.humanize
    end

    # Past / Live / Ready for release / Awaiting approval / Draft tag for an academic year.
    # When signed-off funding goes live: the year's start date, or straight away for
    # EYTDA funding in a year that has already started (2026 to 2027).
    def sign_off_goes_live_text(cycle)
      return cycle.start_date.to_fs(:govuk) unless cycle.eytda_only_funding_year? && cycle.start_date <= Time.zone.today

      "As soon as it is approved (#{cycle.label} has already started)"
    end

    # The status on Drafts: 2026 to 2027 is live, but its EYTDA funding is still a draft.
    def draft_status_tag(cycle)
      return academic_year_status_tag(cycle) unless cycle.live? && cycle.eytda_only_funding_year?
      return govuk_tag(text: "Awaiting approval (EYTDA only)", colour: "purple") if cycle.awaiting_publication_approval?

      govuk_tag(text: "Draft (EYTDA only)", colour: "yellow")
    end

    def academic_year_status_tag(cycle)
      case cycle.status
      when :past               then govuk_tag(text: "Past", colour: "grey")
      when :live               then govuk_tag(text: "Live", colour: "green")
      when :published          then govuk_tag(text: "Ready for release", colour: "blue")
      when :awaiting_approval  then govuk_tag(text: "Awaiting approval", colour: "purple")
      else                          govuk_tag(text: "Draft", colour: "yellow")
      end
    end

    def degree_relevance_tag(degree_relevance)
      case degree_relevance.to_s
      when "relevant"  then govuk_tag(text: "Relevant", colour: "light-blue")
      when "unrelated" then govuk_tag(text: "Unrelated", colour: "grey")
      end
    end

    def school_disadvantage_tag(school_disadvantage)
      case school_disadvantage.to_s
      when "disadvantaged"     then govuk_tag(text: "Disadvantaged/special", colour: "magenta")
      when "non_disadvantaged" then govuk_tag(text: "Non disadvantaged", colour: "grey")
      end
    end

    # Increase / Decrease / New / No change vs the previous academic cycle.
    def funding_change_tag(change)
      case change.to_s
      when "increase" then govuk_tag(text: "Increase", colour: "green")
      when "decrease" then govuk_tag(text: "Decrease", colour: "red")
      when "new"      then govuk_tag(text: "New", colour: "light-blue")
      when "not_available" then govuk_tag(text: "Not available", colour: "grey")
      else                 govuk_tag(text: "No change", colour: "grey")
      end
    end
  end
end
