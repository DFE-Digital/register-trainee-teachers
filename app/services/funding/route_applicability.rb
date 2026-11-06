# frozen_string_literal: true

module Funding
  # Given the answers captured earlier in the Add funding wizard (funding type,
  # funding method, QTS requirement), decides which training routes are
  # applicable — so the Training routes step can grey out the rest, with a
  # reason. Composes existing facts: award type per route
  # (TRAINING_ROUTE_AWARD_TYPE), undergrad/postgrad (UNDERGRAD_ROUTES), and a
  # policy map of which routes carry each funding type.
  #
  # The funding-type map is the source of truth for route eligibility by type
  # (see the route-applicability proposal, decision D-3). Adjust it here if the
  # policy changes.
  class RouteApplicability
    FUNDING_TYPE_ROUTES = {
      "bursary" => %w[
        provider_led_postgrad provider_led_undergrad opt_in_undergrad
        early_years_postgrad school_direct_tuition_fee hpitt_postgrad
      ],
      "scholarship" => %w[provider_led_postgrad school_direct_tuition_fee hpitt_postgrad],
      "grant" => %w[
        school_direct_salaried pg_teaching_apprenticeship teacher_degree_apprenticeship
        early_years_postgrad early_years_salaried early_years_teacher_degree_apprenticeship
      ],
    }.freeze

    UNDERGRAD_METHODS = %w[B C].freeze          # Undergraduate / Veteran bursary
    POSTGRAD_BURSARY_METHOD = "D"               # Postgraduate bursary
    TIER_METHODS = %w[7 8 9].freeze             # Tier 1/2/3 (early years graduate entry)

    def initialize(funding_type: nil, funding_method: nil, qts_requirement: nil)
      @funding_type = funding_type.presence
      @funding_method = funding_method.presence
      @qts = qts_requirement.presence
    end

    # A greying reason for the route, or nil when the route is applicable.
    def reason(route)
      type_reason(route) || qts_reason(route) || method_reason(route)
    end

    def applicable?(route)
      reason(route).nil?
    end

    def any_applicable?
      TRAINING_ROUTE_ENUMS.values.any? { |route| applicable?(route) }
    end

    # Keep only the routes that are applicable (server-side guard for submits).
    def filter(routes)
      Array(routes).select { |route| applicable?(route) }
    end

  private

    def tier_method?
      TIER_METHODS.include?(@funding_method) || AmountMatrix.early_years_tiered?(@funding_method)
    end

    def funded_route?(route)
      FUNDING_TYPE_ROUTES.values.flatten.include?(route)
    end

    def type_reason(route)
      return if @funding_type.blank?
      return if FUNDING_TYPE_ROUTES.fetch(@funding_type, []).include?(route)

      funded_route?(route) ? "Not available for #{@funding_type} funding" : "No funding for this route"
    end

    def qts_reason(route)
      return if @qts.blank?

      award = TRAINING_ROUTE_AWARD_TYPE[route.to_sym]
      return if award.nil?

      if @qts == "yes" && award == EYTS_AWARD_TYPE
        "Leads to EYTS, not QTS"
      elsif @qts == "no" && award == QTS_AWARD_TYPE
        "This route leads to QTS"
      end
    end

    def method_reason(route)
      return if @funding_method.blank?

      undergrad = UNDERGRAD_ROUTES.key?(route)

      if UNDERGRAD_METHODS.include?(@funding_method) && !undergrad
        "Only for undergraduate routes"
      elsif @funding_method == POSTGRAD_BURSARY_METHOD && undergrad
        "Only for postgraduate routes"
      elsif tier_method? && route != TRAINING_ROUTE_ENUMS[:early_years_postgrad]
        "Only for early years graduate entry"
      end
    end
  end
end
