# frozen_string_literal: true

module SystemAdmin
  # Single-add form for Funding schools management: resolve a URN to a School,
  # apply the designation rules, and (after confirmation) create the designation.
  class FundingSchoolDesignationForm
    include ActiveModel::Model

    def self.model_name = ActiveModel::Name.new(self, nil, "FundingSchoolDesignationForm")

    attr_accessor :academic_year, :designation, :urn, :created_by
    attr_reader :school

    validate :validate_academic_year
    validate :validate_designation
    validate :validate_urn

    def academic_cycle
      return if academic_year.blank?

      AcademicCycle.for_year(academic_year.to_i)
    end

    def designation_label
      FundingSchoolDesignation.new(designation: presence_designation).designation_label if presence_designation
    end

    def save!
      return false unless valid?

      FundingSchoolDesignation.create!(
        school: @school, academic_cycle: academic_cycle, designation: designation, created_by: created_by,
      )
    end

  private

    def presence_designation
      designation.presence if FundingSchoolDesignation.designations.key?(designation.to_s)
    end

    def validate_academic_year
      cycle = academic_cycle

      if academic_year.blank?
        errors.add(:academic_year, "Select an academic year")
      elsif cycle.nil?
        errors.add(:academic_year, "Select a valid academic year")
      elsif cycle.funding_locked?
        errors.add(:academic_year, "You cannot add schools to a year that is live or has ended")
      end
    end

    def validate_designation
      errors.add(:designation, "Select whether the school is disadvantaged or special") unless presence_designation
    end

    def validate_urn
      result = ::Funding::ResolveSchoolForDesignation.call(urn:, academic_cycle:)
      @school = result.school
      errors.add(:urn, result.error) unless result.ok?
    end
  end
end
