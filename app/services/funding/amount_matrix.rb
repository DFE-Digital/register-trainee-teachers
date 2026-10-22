# frozen_string_literal: true

module Funding
  # The set of amount inputs the "Add funding" wizard needs, given the two
  # split questions that can each double the number of amounts captured:
  #
  #   * related degree   — relevant vs unrelated degree
  #   * disadvantaged school — disadvantaged/special vs non-disadvantaged school
  #
  # Either, both, or neither may be active. Each cell names the form attribute
  # that holds its amount, the label to show, and the degree_relevance /
  # school_disadvantage enum values the resulting FundingMethod row is stored
  # with. One cell → one row per training route.
  #
  # The Early years tiered bursary is a third kind of split: one wizard choice
  # that captures three amounts (Tier 1/2/3). Each tier cell carries its HESA
  # burslev code, which is stored as the row's funding_method.
  class AmountMatrix
    Cell = Struct.new(:key, :label, :degree_relevance, :school_disadvantage, :funding_method, :training_year, :name,
                      :availability_key, keyword_init: true) do
      def amount_from(source) = source.public_send(key)

      # How the cell is named in error messages ("Enter the Tier 1 amount"); nil
      # for the plain amount cells, which keep the generic messages.
      def error_name = name

      # The unrelated degree amount can be marked "not available" instead.
      def optional? = availability_key.present?

      # False when the user said this funding type isn't available for the cell.
      def available_in?(source) = !optional? || source.public_send(availability_key).to_s != "no"
    end

    # Wizard-only funding method value; expands to one row per tier on save.
    EARLY_YEARS_TIERED = "early_years_tiered"
    TIERS = [
      [:tier_one, "Tier 1", Hesa::CodeSets::BursaryLevels::TIER_ONE],
      [:tier_two, "Tier 2", Hesa::CodeSets::BursaryLevels::TIER_TWO],
      [:tier_three, "Tier 3", Hesa::CodeSets::BursaryLevels::TIER_THREE],
    ].freeze
    TIER_KEYS = TIERS.map { |tier, _name, _code| :"amount_#{tier}" }.freeze

    def self.early_years_tiered?(funding_method) = funding_method.to_s == EARLY_YEARS_TIERED

    # Routes whose funding is set as one amount per year of training, stored as
    # one row per training_year.
    YEARLY_ROUTES = { TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship] => 3 }.freeze

    def self.yearly?(training_routes) = Array(training_routes).any? { |route| YEARLY_ROUTES.key?(route.to_s) }

    def self.training_years(training_routes)
      Array(training_routes).filter_map { |route| YEARLY_ROUTES[route.to_s] }.max || 0
    end

    # The amount cells for the wizard's answers: one per training year for a
    # yearly route, the three tiers for the Early years tiered bursary, otherwise
    # the Financial Incentive split.
    def self.for(financial_incentive:, funding_method:, training_routes: nil, start_year: nil)
      if yearly?(training_routes)
        year_cells(start_year, training_years(training_routes))
      elsif early_years_tiered?(funding_method)
        tier_cells
      else
        for_incentive(financial_incentive)
      end
    end

    # "Year 2 (28/29)": the year of training and the academic year it falls in,
    # counted on from the cohort's start year (later years may not exist yet).
    def self.year_label(training_year, start_year)
      first = start_year.to_i + training_year.to_i - 1
      "Year #{training_year} (#{format('%02d', first % 100)}/#{format('%02d', (first + 1) % 100)})"
    end

    def self.year_cells(start_year, years = 3)
      (1..years).map do |year|
        Cell.new(key: :"amount_year_#{year}", label: year_label(year, start_year), training_year: year, name: "Year #{year} amount")
      end
    end

    # The error for a cell's submitted amount, or nil when it is valid.
    def self.amount_error(cell, value)
      if value.blank?
        cell.error_name ? "Enter the #{cell.error_name}" : "Enter an amount"
      elsif !/\A\d+\z/.match?(value.to_s)
        "#{cell.error_name || 'Amount'} must be a whole number of pounds"
      end
    end

    def self.tier_cells
      TIERS.map do |tier, name, code|
        Cell.new(key: :"amount_#{tier}", label: "#{name} amount", funding_method: code, name: "#{name} amount")
      end
    end

    DEGREE_LABELS = { relevant: "Relevant degree", unrelated: "Unrelated degree" }.freeze
    DEGREE_FIELD_LABELS = {
      relevant: "Amount for a relevant degree (£)",
      unrelated: "Amount for an unrelated degree (£)",
    }.freeze
    SCHOOL_LABELS = {
      disadvantaged: "Disadvantaged school/special school",
      non_disadvantaged: "Non Disadvantaged school",
    }.freeze

    # The single "Financial Incentive criteria" answer (radio, one at a time).
    DEGREE_RELEVANCY = "degree_relevancy"
    DISADVANTAGED_SPECIAL = "disadvantaged_special"
    NEITHER = "neither"
    INCENTIVE_LABELS = {
      DEGREE_RELEVANCY => "Degree relevancy",
      DISADVANTAGED_SPECIAL => "Disadvantaged or special school",
      NEITHER => "None of these",
    }.freeze

    def self.incentive_label(financial_incentive)
      INCENTIVE_LABELS.fetch(financial_incentive.to_s, "None of these")
    end

    # Amount cells for a single Financial Incentive criterion. Only one axis is
    # ever split (the criterion is mutually exclusive), so this yields one or two
    # cells — never the four-way combination.
    def self.for_incentive(financial_incentive)
      cells(
        related_degree: financial_incentive.to_s == DEGREE_RELEVANCY,
        disadvantaged_school: financial_incentive.to_s == DISADVANTAGED_SPECIAL,
      )
    end

    def self.cells(related_degree:, disadvantaged_school:)
      degrees = related_degree ? %i[relevant unrelated] : [nil]
      schools = disadvantaged_school ? %i[disadvantaged non_disadvantaged] : [nil]

      degrees.flat_map do |degree|
        schools.map { |school| cell(degree, school) }
      end
    end

    def self.cell(degree, school)
      key = key_for(degree, school)
      Cell.new(
        key: key,
        label: label_for(degree, school),
        degree_relevance: degree,
        school_disadvantage: school,
        availability_key: (:"#{key}_available" if degree == :unrelated && school.nil?),
      )
    end

    # Whether the funding type is available for an unrelated degree ("yes"/"no").
    AVAILABILITY_KEYS = %i[amount_unrelated_available].freeze

    def self.funding_type_word(funding_type) = funding_type.presence&.to_s&.humanize&.downcase || "funding"

    def self.availability_question(funding_type)
      "Is there a #{funding_type_word(funding_type)} for trainees with an unrelated degree?"
    end

    def self.availability_error(funding_type)
      "Select whether there is a #{funding_type_word(funding_type)} for trainees with an unrelated degree"
    end

    # The errors for a cell: the availability answer, then the amount when needed.
    def self.cell_errors(cell, source, funding_type)
      if cell.optional?
        answer = source.public_send(cell.availability_key).to_s
        return { cell.availability_key => availability_error(funding_type) } unless %w[yes no].include?(answer)
        return {} if answer == "no"
      end

      message = amount_error(cell, cell.amount_from(source))
      message ? { cell.key => message } : {}
    end

    def self.key_for(degree, school)
      %i[amount].tap do |parts|
        parts << degree if degree
        parts << school if school
      end.join("_").to_sym
    end

    def self.label_for(degree, school)
      if degree && school
        "#{DEGREE_LABELS[degree]} — #{SCHOOL_LABELS[school]}"
      elsif degree
        DEGREE_FIELD_LABELS[degree]
      elsif school
        SCHOOL_LABELS[school]
      else
        "How much is this funding?"
      end
    end
  end
end
