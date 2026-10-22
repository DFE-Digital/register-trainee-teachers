# frozen_string_literal: true

require "csv"

module Funding
  # A fresh, self-contained report over the funding reference amounts for a
  # cycle - separate from the payment-schedule exports in app/services/exports.
  # One row per funding band (route x funding type x amount) with its subjects.
  class ReferenceReport
    COLUMNS = %w[academic_year training_route funding_type training_year amount availability subjects].freeze

    def initialize(academic_cycle)
      @academic_cycle = academic_cycle
    end

    attr_reader :academic_cycle

    def title
      "Funding requirements - #{academic_cycle.label}"
    end

    def rows
      @rows ||= academic_cycle.funding_methods.includes(:allocation_subjects)
        .order(:training_route, :funding_type, :training_year, amount: :desc)
        .map do |method|
          {
            academic_year: academic_cycle.label,
            training_route: method.training_route,
            funding_type: method.funding_type,
            training_year: method.training_year,
            amount: method.amount,
            availability: method.availability,
            subjects: method.allocation_subjects.map(&:name).sort.join("; "),
          }
        end
    end

    # funding_type -> rows, in FUNDING_TYPES order (bursary, scholarship, grant).
    def rows_by_funding_type
      rows.group_by { |row| row[:funding_type] }
        .sort_by { |type, _| FUNDING_TYPES.keys.index(type) || FUNDING_TYPES.size }
        .to_h
    end

    def to_csv
      CSV.generate do |csv|
        csv << COLUMNS
        rows.each { |row| csv << COLUMNS.map { |col| row[col.to_sym] } }
      end
    end

    def to_h
      { title:, academic_year: academic_cycle.label, columns: COLUMNS, rows: }
    end

    def filename(format)
      "funding-requirements-#{academic_cycle.label.parameterize}.#{format}"
    end
  end
end
