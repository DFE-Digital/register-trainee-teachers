# frozen_string_literal: true

module Trainees
  class MapFundingToHesa
    include ServicePattern

    TIER_TO_HESA = {
      "tier_one" => ::Hesa::CodeSets::BursaryLevels::TIER_ONE,
      "tier_two" => ::Hesa::CodeSets::BursaryLevels::TIER_TWO,
      "tier_three" => ::Hesa::CodeSets::BursaryLevels::TIER_THREE,
    }.freeze

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return ::Hesa::CodeSets::BursaryLevels::SCHOLARSHIP if trainee.applying_for_scholarship?
      return TIER_TO_HESA[trainee.bursary_tier] if trainee.bursary_tier.present?
      return ::Hesa::CodeSets::BursaryLevels::GRANT if trainee.applying_for_grant?
      return ::Hesa::CodeSets::BursaryLevels::NONE unless trainee.applying_for_bursary?

      bursary_code_from_route
    end

  private

    attr_reader :trainee

    def bursary_code_from_route
      return ::Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY unless UNDERGRAD_ROUTES.key?(trainee.training_route)

      if veteran_initiative?
        ::Hesa::CodeSets::BursaryLevels::VETERAN_TEACHING_UNDERGRADUATE_BURSARY
      else
        ::Hesa::CodeSets::BursaryLevels::UNDERGRADUATE_BURSARY
      end
    end

    def veteran_initiative?
      trainee.training_initiative == ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary]
    end
  end
end
