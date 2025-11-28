# frozen_string_literal: true

module ReferenceData
  class Value
    attr_reader :id, :name, :display_name, :hesa_codes, :start_year, :end_year

    def self.from_yaml(attrs)
      new(
        id: attrs[:id],
        name: attrs[:name],
        display_name: attrs[:display_name],
        hesa_codes: attrs[:hesa_codes],
        start_year: attrs[:start_year]&.to_i,
        end_year: attrs[:end_year]&.to_i,
      )
    end

    def initialize(attrs = {})
      @id = attrs[:id]
      @name = attrs[:name]
      @display_name = attrs[:display_name]
      @hesa_codes = attrs[:hesa_codes] || []
      @start_year = attrs[:start_year]
      @end_year = attrs[:end_year]
    end

    def valid_in?(year:)
      return true unless (start_year || end_year) && year

      if start_year && end_year
        (year >= start_year) && (year <= end_year)
      elsif start_year
        year >= start_year
      else
        year <= end_year
      end
    end
  end
end
