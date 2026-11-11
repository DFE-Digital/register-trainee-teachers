# frozen_string_literal: true

require "csv"

module SystemAdmin
  # CSV bulk import for Funding schools management. The form captures one
  # academic year + designation and a CSV of URNs (one per line, or a `urn`
  # column). Each URN is validated with the same rules as the single-add form;
  # valid, non-duplicate URNs are imported and the rest are reported back.
  class FundingSchoolDesignationBulkForm
    include ActiveModel::Model

    def self.model_name = ActiveModel::Name.new(self, nil, "FundingSchoolDesignationBulkForm")

    attr_accessor :academic_year, :designation, :file, :created_by
    attr_reader :added, :skipped

    validate :validate_academic_year
    validate :validate_designation
    validate :validate_file

    def academic_cycle
      return if academic_year.blank?

      AcademicCycle.for_year(academic_year.to_i)
    end

    def designation_label
      return unless FundingSchoolDesignation.designations.key?(designation.to_s)

      FundingSchoolDesignation.new(designation:).designation_label
    end

    # Imports the valid rows. Populates `added` (Schools) and `skipped`
    # ([{ urn:, error: }]), and returns the schools added. Does nothing if the
    # form isn't valid (see `errors`).
    def import!
      return [] unless valid?

      @added = []
      @skipped = []

      ActiveRecord::Base.transaction do
        urns.each do |urn|
          result = ::Funding::ResolveSchoolForDesignation.call(urn:, academic_cycle:)
          if result.ok?
            FundingSchoolDesignation.create!(school: result.school, academic_cycle: academic_cycle, designation: designation, created_by: created_by)
            @added << result.school
          else
            @skipped << { urn: urn, error: result.error }
          end
        end
      end

      @added
    end

    def urns
      @urns ||= parse_urns
    end

  private

    def parse_urns
      return [] if file.blank?

      rows = CSV.parse(file.read.to_s)
      rows.filter_map { |row| row.first&.strip.presence }
        .reject { |cell| cell.casecmp?("urn") } # drop a header cell
        .uniq
    rescue CSV::MalformedCSVError
      []
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
      unless FundingSchoolDesignation.designations.key?(designation.to_s)
        errors.add(:designation, "Select whether the schools are disadvantaged or special")
      end
    end

    def validate_file
      if file.blank?
        errors.add(:file, "Upload a CSV file of URNs")
      elsif urns.empty?
        errors.add(:file, "The CSV did not contain any URNs")
      end
    end
  end
end
