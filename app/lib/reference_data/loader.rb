# frozen_string_literal: true

require "singleton"

module ReferenceData
  class UnknownReferenceDataTypeError < StandardError
  end

  class Loader
    include Singleton

    attr_reader :types

    def find(type_name)
      @types_by_name[type_name]
    end

    def enum_values_for(type_name)
      type = find(type_name)
      raise(UnknownReferenceDataTypeError) unless type

      type.values.each_with_object({}) do |value, enum_hash|
        enum_hash[value.name] = value.id
      end
    end

  private

    def initialize
      load_all
    end

    def load_all
      @types = Rails.root.glob("config/reference_data/*.yml").map do |file_path|
        type_data = YAML.load_file(file_path)
        ReferenceData::Type.from_yaml(
          metadata: type_data["metadata"].with_indifferent_access,
          data: type_data["data"],
        )
      end

      index_types_by_name
    end

    def index_types_by_name
      @types_by_name = @types.index_by(&:name).with_indifferent_access
    end
  end
end
