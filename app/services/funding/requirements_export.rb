# frozen_string_literal: true

require "csv"

module Funding
  # The Funding requirements list as a CSV: every entry matching the page's
  # year and filters (not only the current page), in the same order and with
  # the same wording as the table. EYTDA amounts carried forward from an
  # earlier year are included and marked as such.
  class RequirementsExport
    HEADERS = [
      "Entry ID",
      "Academic year",
      "Status",
      "Funding method",
      "Funding type",
      "Training route",
      "Subject",
      "Degree relevance",
      "School",
      "Training year",
      "Amount",
      "Available",
      "Source",
    ].freeze

    # labels: an object with the SystemAdmin::FundingMethodsHelper label methods
    # (the controller's view helpers).
    def initialize(entries:, labels:, academic_cycle: nil, carried_forward_entries: [], carried_forward_source: nil)
      @entries = entries
      @labels = labels
      @academic_cycle = academic_cycle
      @carried_forward_entries = Array(carried_forward_entries)
      @carried_forward_source = carried_forward_source
    end

    def to_csv
      CSV.generate do |csv|
        csv << HEADERS
        entries.each { |row| csv << values_for(row, source: "This year") }
        carried_forward_entries.each { |row| csv << values_for(row, source: "Carried forward from #{carried_forward_source.label}") }
      end
    end

    def filename
      year = academic_cycle ? academic_cycle.label.parameterize : "all-academic-years"
      status = academic_cycle&.pre_release? ? "draft-" : ""

      "#{status}funding-requirements-#{year}-#{Time.zone.today.iso8601}.csv"
    end

  private

    attr_reader :entries, :labels, :academic_cycle, :carried_forward_entries, :carried_forward_source

    def values_for(row, source:)
      not_available = row[:availability].to_s == "not_available"

      [
        row[:entry_id],
        row[:academic_year],
        status_for(row[:academic_year_start]),
        labels.funding_method_cell(row[:funding_method], row[:funding_type], row[:training_route]),
        labels.funding_type_label(row[:funding_type]),
        labels.route_enum_name(row[:training_route]),
        row[:subject],
        labels.degree_relevance_label(row[:degree_relevance]),
        labels.school_disadvantage_label(row[:school_disadvantage]),
        labels.training_year_label(row[:training_year], row[:academic_year_start]),
        not_available ? nil : row[:amount],
        not_available ? "No" : "Yes",
        source,
      ].map { |value| CsvValueSanitiser.new(value).sanitise }
    end

    def status_for(start_year)
      cycle = cycles_by_start_year[start_year]
      cycle && labels.academic_year_status_label(cycle)
    end

    def cycles_by_start_year
      @cycles_by_start_year ||= begin
        years = (entries + carried_forward_entries).map { |row| row[:academic_year_start] }.uniq
        AcademicCycle.all.select { |cycle| years.include?(cycle.start_year) }.index_by(&:start_year)
      end
    end
  end
end
