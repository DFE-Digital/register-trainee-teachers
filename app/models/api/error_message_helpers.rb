# frozen_string_literal: true

module Api
  module ErrorMessageHelpers
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def hesa_code_inclusion_message(value:, valid_values:)
        I18n.t(
          "activemodel.errors.models.api/v20250_rc/trainee_attributes.attributes.inclusion",
          value: value,
          valid_values: valid_values.map { |v| "'#{v}'" }.join(", "),
        )
      end
    end
  end
end
