# frozen_string_literal: true

module Api
  module V20250
    class EnhancedErrorsSerializer
      EXCLUDED_ATTRIBUTES = %i[
        personal_details
        contact_details
        diversity
        degrees
        course_details
        schools
        placements
        funding
        iqts_country
      ].freeze

      attr_reader :errors

      def initialize(errors)
        @errors = errors
      end

      def as_hash
        return errors if enhanced?

        errors.inject({}) do |hash, error|
          error_array = error.split
          attribute   = error_array.first
          message     = error_array[1..-1].join(" ")

          if hash[attribute]
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
    end
  end
end
