# frozen_string_literal: true

module Trainees
  class MapFundingToHesaBursaryLevel
    include ServicePattern

    BURSARY_TIER_TO_HESA_CODE = {
      BURSARY_TIER_ENUMS[:tier_one] => ::Hesa::CodeSets::BursaryLevels::TIER_ONE,
      BURSARY_TIER_ENUMS[:tier_two] => ::Hesa::CodeSets::BursaryLevels::TIER_TWO,
      BURSARY_TIER_ENUMS[:tier_three] => ::Hesa::CodeSets::BursaryLevels::TIER_THREE,
    }.freeze

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return if funding_not_set?

      return ::Hesa::CodeSets::BursaryLevels::SCHOLARSHIP if trainee.applying_for_scholarship?

      if trainee.applying_for_bursary?
        return BURSARY_TIER_TO_HESA_CODE[trainee.bursary_tier] if trainee.bursary_tier.present?
        return ::Hesa::CodeSets::BursaryLevels::VETERAN_TEACHING_UNDERGRADUATE_BURSARY if veteran_bursary?
        return ::Hesa::CodeSets::BursaryLevels::UNDERGRADUATE_BURSARY if trainee.undergrad_route?

        return ::Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY
      end

      return ::Hesa::CodeSets::BursaryLevels::GRANT if trainee.applying_for_grant?

      ::Hesa::CodeSets::BursaryLevels::NONE
    end

  private

    attr_reader :trainee

    def funding_not_set?
      trainee.applying_for_bursary.nil? &&
        trainee.applying_for_grant.nil? &&
        trainee.applying_for_scholarship.nil?
    end

    def veteran_bursary?
      trainee.training_initiative == ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary]
    end
  end
end
