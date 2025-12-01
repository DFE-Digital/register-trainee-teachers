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
      @values_by_hesa_code = {}.tap do |hash|
        @values.each do |value|
          value.hesa_codes.each do |hesa_code|
            hash[hesa_code.to_s] = value
          end
        end
      end
    end

    def self.from_yaml(metadata:, data:)
      new(
        name: metadata[:name],
        display_name: metadata[:display_name],
        values: data.map { |value_attrs| ReferenceData::Value.from_yaml(value_attrs.with_indifferent_access) },
      )
    end

    def find(identifier)
      @values_by_id[identifier.to_s] || @values_by_name[identifier.to_s]
    end

    def ids
      @values_by_id.keys
    end

    def names(year: nil)
      valid_values_for(year:).map(&:name)
    end

    def names_with_hesa_codes(year: nil)
      valid_values_for(year:).select { |value| value.hesa_codes.present? }.map(&:name)
    end

    def hesa_codes(year: nil)
      valid_values_for(year:).flat_map(&:hesa_codes)
    end

    def find_by_hesa_code(hesa_code)
      @values_by_hesa_code[hesa_code.to_s]
    end

    def method_missing(method_name, *args)
      if names.include?(method_name.to_s)
        find(method_name)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      names.include?(method_name.to_s) || super
    end

  private

    def valid_values_for(year: nil)
      @values.select { |value| value.valid_in?(year:) }
    end
  end
end
