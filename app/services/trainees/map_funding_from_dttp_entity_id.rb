# frozen_string_literal: true

module Trainees
  class MapFundingFromDttpEntityId
    include ServicePattern
    include HasDttpMapping

    def initialize(funding_entity_id:)
      @funding_entity_id = funding_entity_id
    end

    def call
      funding_attributes.compact
    end

  private

    attr_reader :funding_entity_id

    def funding_attributes
      return {} if funding_entity_id.blank?

      if funding_entity_id == Dttp::CodeSets::BursaryDetails::NO_BURSARY_AWARDED
        return {
          applying_for_grant: false,
          applying_for_bursary: false,
          applying_for_scholarship: false,
        }
      end

      if applying_for_new_tier?
        return {
          applying_for_grant: false,
          applying_for_bursary: true,
          applying_for_scholarship: false,
          bursary_tier: tier_for_funding,
        }
      end

      {
        applying_for_grant: applying_for_grant?,
        applying_for_scholarship: applying_for_scholarship?,
        applying_for_bursary: applying_for_bursary?,
      }
    end

    def applying_for_bursary?
      Dttp::CodeSets::BursaryDetails::BURSARIES.include?(funding_entity_id)
    end

    def applying_for_grant?
      Dttp::CodeSets::BursaryDetails::GRANTS.include?(funding_entity_id)
    end

    def applying_for_new_tier?
      Dttp::CodeSets::BursaryDetails::NEW_TIERS.include?(funding_entity_id)
    end

    def applying_for_scholarship?
      funding_entity_id == Dttp::CodeSets::BursaryDetails::SCHOLARSHIP
    end

    def tier_for_funding
      find_by_entity_id(funding_entity_id, Dttp::CodeSets::BursaryDetails::MAPPING)
    end
  end
end
