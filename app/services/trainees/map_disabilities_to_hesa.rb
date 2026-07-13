# frozen_string_literal: true

module Trainees
  class MapDisabilitiesToHesa
    include ServicePattern

    NO_KNOWN_IMPAIRMENT = "95"
    PREFER_NOT_TO_SAY = "98"
    NOT_AVAILABLE = "99"

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      codes.each_with_index.to_h { |code, index| ["disability#{index + 1}", code] }
    end

  private

    attr_reader :trainee

    def codes
      case trainee.disability_disclosure
      when Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
        disability_codes
      when Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability]
        [NO_KNOWN_IMPAIRMENT]
      when Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided]
        [not_provided_code]
      else
        []
      end
    end

    def disability_codes
      trainee.disabilities.map { |disability| code_for(disability.name) }.compact
    end

    def code_for(name)
      canonical = ::ReferenceData::DISABILITIES.find(name)&.hesa_codes&.first
      return if canonical.nil?

      existing_code_for(name) || canonical
    end

    def existing_code_for(name)
      existing_codes.find { |code| ::ReferenceData::DISABILITIES.find_by_hesa_code(code)&.id == name }
    end

    def not_provided_code
      existing_codes.include?(NOT_AVAILABLE) ? NOT_AVAILABLE : PREFER_NOT_TO_SAY
    end

    def existing_codes
      @existing_codes ||= trainee.hesa_trainee_detail&.hesa_disabilities&.values || []
    end
  end
end
