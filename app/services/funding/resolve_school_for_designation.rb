# frozen_string_literal: true

module Funding
  # Resolves a URN to a School for a funding-school designation and applies the
  # rules: valid 6-digit URN, not an administrative code, the school must exist
  # in Register, must be open, and must not already be designated for the year.
  # Shared by the single-add form and the CSV bulk import so both behave the same.
  class ResolveSchoolForDesignation
    URN_REGEX = /\A[0-9]{6}\z/

    Result = Struct.new(:school, :error, keyword_init: true) do
      def ok? = error.nil?
    end

    def self.call(urn:, academic_cycle:, ignore_duplicate: false)
      urn = urn.to_s.strip

      return Result.new(error: "Enter a valid 6-digit URN") unless urn.match?(URN_REGEX)
      if School::NOT_APPLICABLE_SCHOOL_URNS.include?(urn)
        return Result.new(error: "URN #{urn} is an administrative code and cannot be added")
      end

      school = School.find_by(urn:)
      if school.nil?
        return Result.new(error: "No school with URN #{urn} was found. Schools must already exist in Register.")
      end
      if school.close_date.present?
        return Result.new(school:, error: "#{school.name} (URN #{urn}) is closed and cannot be added.")
      end

      if !ignore_duplicate && academic_cycle && FundingSchoolDesignation.exists?(school:, academic_cycle:)
        return Result.new(school:, error: "#{school.name} is already on the list for #{academic_cycle.label}.")
      end

      Result.new(school:)
    end
  end
end
