# frozen_string_literal: true

module ReferenceData
  class Type
    attr_reader :name, :display_name, :values

    def initialize(name: nil, display_name: nil, values: nil)
      @name = name
      @display_name = display_name
      @values = values
    end

    def self.from_yaml(metadata:, data:)
      new(
        name: metadata[:name],
        display_name: metadata[:display_name],
        values: data.map { |value_attrs| ReferenceData::Value.from_yaml(value_attrs.with_indifferent_access) }
      )
    end
  end
end
