# frozen_string_literal: true

module FundingSchoolDesignations
  class ImportFromCsv
    include ServicePattern

    attr_reader :upload, :academic_cycle, :unmatched_urns, :invalid_designations, :conflicting_urns

    def initialize(upload_id:, academic_cycle:)
      @upload = Upload.find(upload_id)
      @academic_cycle = academic_cycle
      @unmatched_urns = []
      @invalid_designations = []
      @conflicting_urns = []
    end

    def call
      rows = CSV.parse(upload.file.download, headers: true, header_converters: :symbol)

      rows.each do |row|
        designation = row[:designation]&.strip&.downcase

        unless FundingSchoolDesignation.designations.key?(designation)
          invalid_designations << row[:designation]
          next
        end

        school = School.find_by(urn: row[:urn]&.strip)

        if school.nil?
          unmatched_urns << row[:urn]
          next
        end

        funding_school_designation = FundingSchoolDesignation.find_or_create_by(academic_cycle:, school:, designation:)

        conflicting_urns << row[:urn] unless funding_school_designation.persisted?
      end

      self
    end
  end
end
