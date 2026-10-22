# frozen_string_literal: true

module Funding
  # Copies every FundingMethod (and its eligible subjects) from a source
  # academic cycle into a target cycle as new draft rows. The target gets fresh
  # per-cycle IFR reference numbers (assigned on create). Amounts are copied
  # as-is; the funding team adjusts from there. Deprecated subjects are skipped
  # so the new draft is clean.
  class RollOverFunding
    def self.call(source:, target:)
      new(source:, target:).call
    end

    def initialize(source:, target:)
      @source = source
      @target = target
    end

    def call
      created = 0
      ActiveRecord::Base.transaction do
        # EYTDA amounts carry forward to later start years by themselves
        # (FundingManager#funding_cycle), so they aren't copied.
        @source.funding_methods.where.not(training_route: FundingManager::EYTDA_ROUTE)
          .includes(:allocation_subjects).find_each do |method|
          new_method = @target.funding_methods.create!(
            training_route: method.training_route,
            funding_type: method.funding_type,
            amount: method.amount,
            availability: method.availability,
            degree_relevance: method.degree_relevance,
            school_disadvantage: method.school_disadvantage,
            funding_method: method.funding_method,
            training_year: method.training_year,
          )

          method.allocation_subjects.select { |subject| subject.deprecated_on.nil? }.each do |subject|
            new_method.funding_method_subjects.create!(allocation_subject: subject)
          end

          created += 1
        end
      end
      created
    end
  end
end
