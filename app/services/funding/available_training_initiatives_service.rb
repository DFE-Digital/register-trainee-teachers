# frozen_string_literal: true

module Funding
  class AvailableTrainingInitiativesService
    include ServicePattern

    attr_accessor :academic_cycle

    def initialize(academic_cycle:)
      self.academic_cycle = academic_cycle
    end

    def call
      return [] if academic_cycle.blank?

      constant_name = "TRAINING_INITIATIVES_#{year}_TO_#{year + 1}"
      return Object.const_get(constant_name) if Object.const_defined?(constant_name)

      []
    end

  private

    def year
      academic_cycle&.start_year
    end
  end
end
