# frozen_string_literal: true

module SystemAdmin
  # Creates funding reference data from the Funding management "Add funding"
  # wizard. A multi-select of training routes creates one FundingMethod per
  # route, each with a FundingMethodSubject per selected allocation subject.
  #
  # Persisted columns: academic_cycle, funding_type, training_route, amount,
  # subjects (join) and degree_relevance. When a related degree is required the
  # form writes TWO rows per route — degree_relevance :relevant and :unrelated —
  # with their respective amounts.
  #
  # Captured-but-not-stored (no column on funding_methods; validated per-step in
  # the wizard, shown on Check your answers): funding_method (HESA burslev),
  # qts_requirement (derived from route award type), education_phase and
  # student_finance_exception (a code-level FundCodeException). See the
  # implementation proposal §6.
  class FundingMethodForm
    include ActiveModel::Model

    attr_accessor :academic_year, :funding_type, :funding_method,
                  :education_phase, :student_finance_exception, :financial_incentives,
                  :training_routes, :amount, :amount_relevant,
                  :amount_unrelated, :amount_unrelated_available, :amount_disadvantaged, :amount_non_disadvantaged,
                  :amount_tier_one, :amount_tier_two, :amount_tier_three,
                  :amount_year_1, :amount_year_2, :amount_year_3, :amount_year_4,
                  :allocation_subject_ids
    attr_reader :created_funding_methods

    validates :academic_year, :funding_type, presence: true
    validates :funding_type, inclusion: { in: FundingMethod.funding_types.keys }
    validate :academic_year_is_valid
    validate :academic_year_not_locked
    validate :at_least_one_route
    validate :single_award_type
    validate :yearly_route_alone
    validate :at_least_one_subject
    validate :amounts_are_valid
    validate :no_duplicate_combinations

    def related_degree? = financial_incentives.to_s == ::Funding::AmountMatrix::DEGREE_RELEVANCY
    def disadvantaged_school? = financial_incentives.to_s == ::Funding::AmountMatrix::DISADVANTAGED_SPECIAL

    def amount_cells
      ::Funding::AmountMatrix.for(
        financial_incentive: financial_incentives, funding_method: funding_method,
        training_routes: selected_routes, start_year: academic_year
      )
    end

    def academic_cycle
      return if academic_year.blank?

      AcademicCycle.for_year(academic_year.to_i)
    end

    def selected_routes
      Array(training_routes).reject(&:blank?)
    end

    def selected_subjects
      AllocationSubject.where(id: Array(allocation_subject_ids).reject(&:blank?))
    end

    def save!
      return false unless valid?

      FundingMethod.transaction do
        @created_funding_methods = selected_routes.flat_map do |training_route|
          amount_cells.map { |cell| build_row(training_route, cell) }
        end
      end
    end

  private

    # A tier cell stores its own HESA code (7/8/9); otherwise the chosen method.
    # The wizard-only early_years_tiered value is never stored.
    def stored_funding_method(cell)
      cell.funding_method || funding_method.presence
    end

    def build_row(training_route, cell)
      funding_method_record = FundingMethod.create!(
        training_route: training_route,
        funding_type: funding_type,
        amount: (cell.amount_from(self).to_i if cell.available_in?(self)),
        availability: (cell.available_in?(self) ? :available : :not_available),
        academic_cycle: academic_cycle,
        degree_relevance: cell.degree_relevance,
        school_disadvantage: cell.school_disadvantage,
        funding_method: stored_funding_method(cell),
        training_year: cell.training_year,
      )
      selected_subjects.each do |subject|
        funding_method_record.funding_method_subjects.create!(allocation_subject: subject)
      end
      funding_method_record
    end

    def academic_year_is_valid
      errors.add(:academic_year, "Select a valid academic year") if academic_year.present? && academic_cycle.nil?
    end

    def academic_year_not_locked
      return if academic_cycle.nil? || !academic_cycle.funding_locked?

      if academic_cycle.locked_except_eytda?
        return if funding_type.to_s == "grant" && selected_routes == [FundingManager::EYTDA_ROUTE]

        errors.add(:academic_year, AddFundingStepForm.eytda_only_message(academic_cycle))
      else
        errors.add(:academic_year, "You cannot add funding to a year that is live or has ended")
      end
    end

    def at_least_one_route
      errors.add(:training_routes, "Select at least one training route") if selected_routes.empty?
    end

    # QTS and EYTS funding are never set up together — each award type is a
    # separate funding record. Reject a selection that mixes the two.
    def single_award_type
      awards = selected_routes.map { |route| TRAINING_ROUTE_AWARD_TYPE[route.to_sym] }.compact.uniq
      return if awards.size <= 1

      errors.add(:training_routes, "Select routes that lead to the same award — QTS and EYTS funding must be added separately")
    end

    # A route funded per training year has its own amounts, so it is added alone.
    def yearly_route_alone
      return unless ::Funding::AmountMatrix.yearly?(selected_routes) && selected_routes.size > 1

      errors.add(:training_routes, AddFundingStepForm::YEARLY_ROUTE_ALONE_MESSAGE)
    end

    def at_least_one_subject
      if selected_subjects.empty?
        errors.add(:allocation_subject_ids, "Select at least one eligible subject")
      elsif (message = ::Funding::EligibleSubjects.error_for(selected_routes, selected_subjects.ids))
        errors.add(:allocation_subject_ids, message)
      end
    end

    def amounts_are_valid
      amount_cells.each do |cell|
        ::Funding::AmountMatrix.cell_errors(cell, self, funding_type).each { |key, message| errors.add(key, message) }
      end
    end

    # A funding record is a duplicate when the same combination already exists
    # for the year — funding type, funding method, training route, degree
    # relevance, employing-school designation, training year and subject —
    # regardless of the amount. Prevents two records for the same combination
    # with different money.
    def no_duplicate_combinations
      return if academic_cycle.nil? || funding_type.blank? || selected_routes.empty? || selected_subjects.empty?

      selected_routes.each do |route|
        amount_cells.each do |cell|
          selected_subjects.each do |subject|
            next unless existing_combination?(route, cell, subject)

            errors.add(:base, "Funding already exists for #{combination_label(route, cell, subject)} — regardless of amount. Edit the existing record instead.")
          end
        end
      end
    end

    def existing_combination?(route, cell, subject)
      FundingMethod
        .where(academic_cycle:, funding_type:, training_route: route,
               degree_relevance: cell.degree_relevance, school_disadvantage: cell.school_disadvantage,
               training_year: cell.training_year,
               funding_method: stored_funding_method(cell))
        .joins(:funding_method_subjects)
        .exists?(funding_method_subjects: { allocation_subject_id: subject.id })
    end

    def combination_label(route, cell, subject)
      parts = [route.to_s.humanize, subject.name]
      parts << "relevant degree" if cell.degree_relevance == :relevant
      parts << "unrelated degree" if cell.degree_relevance == :unrelated
      parts << "disadvantaged/special school" if cell.school_disadvantage == :disadvantaged
      parts << "non-disadvantaged school" if cell.school_disadvantage == :non_disadvantaged
      parts << cell.label.delete_suffix(" amount") if cell.funding_method
      parts << "Year #{cell.training_year}" if cell.training_year
      parts.join(" — ")
    end
  end
end
