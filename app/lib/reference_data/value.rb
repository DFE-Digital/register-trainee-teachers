# frozen_string_literal: true

module ReferenceData
  class Value
    attr_reader :id, :name, :display_name, :hesa_codes

    def self.from_yaml(attrs)
      new(
        id: attrs[:id],
        name: attrs[:name],
        display_name: attrs[:display_name],
        hesa_codes: attrs[:hesa_codes],
      )
    end

    def initialize(attrs = {})
      @id = attrs[:id]
      @name = attrs[:name]
      @display_name = attrs[:display_name]
      @hesa_codes = attrs[:hesa_codes] || []
    end
  end
end

