# frozen_string_literal: true

module Api
  module ErrorMessageHelpers
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def hesa_code_inclusion_message(value:, valid_values:)
        if valid_values.count < ApiInclusionValidator::MAX_VALID_VALUES_DISPLAYED
          I18n.t(
            "activemodel.errors.models.api/v20250_rc/trainee_attributes.attributes.inclusion",
            value: value,
            valid_values: valid_values.map { |v| "'#{v}'" }.join(", "),
          )
        else
          I18n.t(
            "activemodel.errors.models.api/v20250_rc/trainee_attributes.attributes.inclusion_with_truncated_list",
            value: value,
            valid_values: valid_values.first(ApiInclusionValidator::MAX_VALID_VALUES_DISPLAYED).map { |v| "'#{v}'" }.join(", "),
          )
        end
      end
    end
  end
end
