# frozen_string_literal: true

module Wizards
  # Step order for the Funding management "Add funding" journey — a GOV.UK
  # multi-page form (one question per page) that ends at Check your answers.
  #
  # Some steps are conditional: they are skipped (never shown, never validated)
  # when the answers so far make them non-applicable. `next_step`/`previous_step`
  # walk only the steps applicable to the current draft.
  class AddFundingWizard
    STEPS = %w[
      academic_year
      funding_type
      funding_method
      training_routes
      financial_incentives
      education_phase
      exception
      subjects
      amount
    ].freeze

    CHECK_ANSWERS = "check-answers"

    # Student finance exception is only relevant to postgraduate bursaries and
    # scholarships, and only for academic years before 2027/28.
    STUDENT_FINANCE_LAST_START_YEAR = 2026

    def self.steps = STEPS

    def self.valid_step?(step)
      STEPS.include?(step)
    end

    def self.first_step = STEPS.first

    # Whether a step applies given the draft answers so far. Non-conditional
    # steps are always applicable.
    def self.applicable_step?(step, draft)
      case step
      when "exception" then student_finance_exception_applicable?(draft)
      # Only a bursary has a type to choose; grants and scholarships have one method.
      when "funding_method" then funding_method_answers((draft || {})["funding_type"]).nil?
      # The Early years tiered bursary sets its own route (Early years postgraduate).
      when "training_routes" then !early_years_tiered?(draft)
      # Early years routes (including the tiered bursary's) answer these themselves:
      # no Financial Incentive split, and no school phase.
      when "financial_incentives", "education_phase" then !early_years_routes?(draft)
      # Early years routes only fund Early years ITT, which the wizard sets itself.
      when "subjects" then !::Funding::EligibleSubjects.automatic?((draft || {})["training_routes"])
      else true
      end
    end

    # The last step shown for these answers (the Back link from Check answers).
    def self.last_applicable_step(draft)
      STEPS.rfind { |step| applicable_step?(step, draft) }
    end

    def self.early_years_routes?(draft)
      ::Funding::EligibleSubjects.early_years?((draft || {})["training_routes"])
    end

    # Answers the wizard sets itself for early years routes.
    def self.early_years_route_answers
      { "financial_incentives" => ::Funding::AmountMatrix::NEITHER, "education_phase" => "not_applicable" }
    end

    # Grants and scholarships have only one funding method (HESA E or 4), which
    # the wizard sets itself. Nil for a bursary, whose type is asked.
    FUNDING_METHOD_BY_TYPE = { "grant" => "E", "scholarship" => "4" }.freeze

    def self.funding_method_answers(funding_type)
      method = FUNDING_METHOD_BY_TYPE[funding_type.to_s]
      { "funding_method" => method } if method
    end

    def self.early_years_tiered?(draft)
      ::Funding::AmountMatrix.early_years_tiered?((draft || {})["funding_method"])
    end

    # Answers the wizard sets itself for the Early years tiered bursary.
    def self.early_years_tiered_answers
      { "financial_incentives" => ::Funding::AmountMatrix::NEITHER, "training_routes" => [TRAINING_ROUTE_ENUMS[:early_years_postgrad]] }
    end

    def self.student_finance_exception_applicable?(draft)
      draft ||= {}
      return false unless %w[bursary scholarship].include?(draft["funding_type"])

      start_year = draft["academic_year"].to_i
      return false unless start_year.positive? && start_year <= STUDENT_FINANCE_LAST_START_YEAR

      routes = Array(draft["training_routes"]).reject(&:blank?)
      routes.any? { |route| postgraduate_route?(route) }
    end

    def self.postgraduate_route?(route)
      !UNDERGRAD_ROUTES.key?(route)
    end

    def initialize(step, editing: false, draft: {})
      @step = step
      @editing = editing
      @draft = draft || {}
    end

    attr_reader :step

    def editing? = @editing

    def applicable_steps
      STEPS.select { |candidate| self.class.applicable_step?(candidate, @draft) }
    end

    # The next screen after this step. When the user reached the step via a
    # Change link on Check your answers, send them back there; otherwise walk to
    # the next applicable step, or to Check your answers after the last one.
    def next_step
      return CHECK_ANSWERS if editing?

      index = STEPS.index(step)
      return CHECK_ANSWERS if index.nil?

      STEPS[(index + 1)..].find { |candidate| self.class.applicable_step?(candidate, @draft) } || CHECK_ANSWERS
    end

    def previous_step
      index = STEPS.index(step)
      return nil if index.nil? || index.zero?

      STEPS[0...index].reverse.find { |candidate| self.class.applicable_step?(candidate, @draft) }
    end

    def position = applicable_steps.index(step)&.+(1)

    def total = applicable_steps.length
  end
end
