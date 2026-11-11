# frozen_string_literal: true

module SystemAdmin
  # Validates a single step of the "Add funding" wizard. One instance is built
  # per page from the draft + the submitted answer; only the current step's
  # rule runs, so GOV.UK inline errors and the error summary work natively.
  class AddFundingStepForm
    include ActiveModel::Model

    YEARLY_ROUTE_ALONE_MESSAGE = "Add Early years teacher degree apprenticeship funding on its own"

    attr_accessor :step, :academic_year, :funding_type, :funding_method,
                  :education_phase, :student_finance_exception,
                  :financial_incentives, :training_routes,
                  :amount, :amount_relevant, :amount_unrelated, :amount_unrelated_available,
                  :amount_disadvantaged, :amount_non_disadvantaged,
                  :amount_tier_one, :amount_tier_two, :amount_tier_three,
                  :amount_year_1, :amount_year_2, :amount_year_3, :amount_year_4
    attr_writer :allocation_subject_ids

    validate :validate_current_step

    def related_degree? = financial_incentives.to_s == ::Funding::AmountMatrix::DEGREE_RELEVANCY
    def disadvantaged_school? = financial_incentives.to_s == ::Funding::AmountMatrix::DISADVANTAGED_SPECIAL

    # The draft keeps subject ids as text; the subject checkboxes compare them with
    # each subject's integer id, so cast them or the saved choices show unticked.
    def allocation_subject_ids = Array(@allocation_subject_ids).compact_blank.map(&:to_i)

    def selected_routes = Array(training_routes).compact_blank
    def selected_subject_ids = Array(allocation_subject_ids).compact_blank

    # The chosen year, when it has gone live and only EYTDA funding can be added (2026 to 2027).
    def eytda_only_cycle
      cycle = AcademicCycle.for_year(academic_year.to_i) if academic_year.present?
      cycle if cycle&.locked_except_eytda?
    end

    def self.eytda_only_message(cycle)
      "For #{cycle.label}, only Early years teacher degree apprenticeship (EYTDA) grants can be added"
    end

  private

    def validate_current_step
      method = "validate_#{step}"
      send(method) if respond_to?(method, true)
    end

    def validate_academic_year
      cycle = AcademicCycle.for_year(academic_year.to_i) if academic_year.present?

      if academic_year.blank?
        errors.add(:academic_year, "Select an academic year")
      elsif cycle.nil?
        errors.add(:academic_year, "Select a valid academic year")
      elsif cycle.funding_locked? && !cycle.locked_except_eytda?
        errors.add(:academic_year, "You cannot add funding to a year that is live or has ended")
      end
    end

    def validate_funding_type
      if funding_type.blank?
        errors.add(:funding_type, "Select a funding type")
      elsif FundingMethod.funding_types.keys.exclude?(funding_type)
        errors.add(:funding_type, "Select a valid funding type")
      elsif eytda_only_cycle && funding_type != "grant"
        errors.add(:funding_type, self.class.eytda_only_message(eytda_only_cycle))
      end
    end

    def validate_funding_method
      errors.add(:funding_method, "Select a bursary type") if funding_method.blank?
    end

    def validate_education_phase
      errors.add(:education_phase, "Select an education phase") if education_phase.blank?
    end

    def validate_exception
      errors.add(:student_finance_exception, "Select yes or no") if student_finance_exception.blank?
    end

    def validate_training_routes
      if selected_routes.empty?
        errors.add(:training_routes, "Select at least one training route")
      elsif mixed_award_types?
        errors.add(:training_routes, "Select routes that lead to the same award — QTS and EYTS funding must be added separately")
      elsif yearly_route_with_others?
        errors.add(:training_routes, YEARLY_ROUTE_ALONE_MESSAGE)
      elsif eytda_only_cycle && selected_routes != [FundingManager::EYTDA_ROUTE]
        errors.add(:training_routes, self.class.eytda_only_message(eytda_only_cycle))
      end
    end

    # A route funded per training year has its own amounts, so it is added alone.
    def yearly_route_with_others?
      ::Funding::AmountMatrix.yearly?(selected_routes) && selected_routes.size > 1
    end

    # QTS and EYTS funding are always separate records, so all selected routes
    # must share one award type. (Also enforced on FundingMethodForm at save.)
    def mixed_award_types?
      selected_routes.map { |route| TRAINING_ROUTE_AWARD_TYPE[route.to_sym] }.compact.uniq.size > 1
    end

    def validate_financial_incentives
      valid = [::Funding::AmountMatrix::DEGREE_RELEVANCY,
               ::Funding::AmountMatrix::DISADVANTAGED_SPECIAL,
               ::Funding::AmountMatrix::NEITHER]
      errors.add(:financial_incentives, "Select which Financial Incentive criteria apply") unless valid.include?(financial_incentives.to_s)
    end

    def validate_amount
      ::Funding::AmountMatrix.for(
        financial_incentive: financial_incentives, funding_method: funding_method,
        training_routes: selected_routes, start_year: academic_year
      ).each do |cell|
        ::Funding::AmountMatrix.cell_errors(cell, self, funding_type).each { |key, message| errors.add(key, message) }
      end
    end

    def validate_subjects
      if selected_subject_ids.empty?
        errors.add(:allocation_subject_ids, "Select at least one eligible subject")
      elsif (message = ::Funding::EligibleSubjects.error_for(selected_routes, selected_subject_ids))
        errors.add(:allocation_subject_ids, message)
      end
    end
  end
end
