# frozen_string_literal: true

module ReferenceData
  class Type
    attr_reader :name, :display_name, :values

    def initialize(name: nil, display_name: nil, values: nil)
      @name = name
      @display_name = display_name
      @values = values
      @values_by_id = @values.index_by(&:id).transform_keys(&:to_s).with_indifferent_access
      @values_by_name = @values.index_by(&:name).transform_keys(&:to_s).with_indifferent_access
    end

    def self.from_yaml(metadata:, data:)
      new(
        name: metadata[:name],
        display_name: metadata[:display_name],
        values: data.map { |value_attrs| ReferenceData::Value.from_yaml(value_attrs.with_indifferent_access) }
      )
    end

    def find(identifier)
      @values_by_id[identifier.to_s] || @values_by_name[identifier.to_s]
    end
  end
end
