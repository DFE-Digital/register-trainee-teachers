# frozen_string_literal: true

module Api
  module V20260
    class EnhancedErrorsSerializer
      EXCLUDED_ATTRIBUTES = %i[
        contact_details
        diversity
        degrees
        course_details
        schools
        placements
        funding
        iqts_country
      ].freeze

      NESTED_ATTRIBUTE_NAMES = {
        "placements_attributes" => Api::V20260::PlacementAttributes::ATTRIBUTES.map(&:to_s),
        "degrees_attributes" => Api::V20260::DegreeAttributes::ATTRIBUTES.map(&:to_s),
      }.freeze

      attr_reader :errors

      def initialize(errors)
        @errors = errors
      end

      def as_hash
        return errors if enhanced?

        errors.inject({}) do |hash, error|
          error_array = error.split
          attribute   = error_array.first
          message     = error_array[1..].join(" ")

          if nested_parent?(attribute)
            child_attr = error_array[1]
            child_attributes = NESTED_ATTRIBUTE_NAMES[attribute]

            if child_attr && child_attributes&.include?(child_attr)
              child_message = error_array[2..].join(" ")
              hash[attribute] ||= {}
              hash[attribute][child_attr] ||= []
              hash[attribute][child_attr] << child_message
            else
              hash[attribute] ||= []
              hash[attribute] << message
            end
          elsif (parent = find_nested_parent(attribute))
            hash[parent] ||= {}
            hash[parent][attribute] ||= []
            hash[parent][attribute] << message
          elsif hash[attribute]
            hash[attribute] += [message]
          else
            hash[attribute] = [message]
          end

          hash
        end
      end

    private

      def enhanced?
        errors.is_a?(Hash) && (errors.keys & EXCLUDED_ATTRIBUTES)
      end

      def nested_parent?(attribute)
        NESTED_ATTRIBUTE_NAMES.key?(attribute)
      end

      def find_nested_parent(attribute)
        NESTED_ATTRIBUTE_NAMES.detect { |_, attributes| attributes.include?(attribute) }&.first
      end
    end
  end
end
