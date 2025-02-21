# frozen_string_literal: true

module DfEReference
  class DisabilitiesQuery
    # NOTE: See dfe-reference gem - dfe/reference_data/equality_and_diversity/disabilities.rb
    NO_DISABILITY_UUID = "b14e142a-adfe-4646-af5d-8236b6a5b48d"
    PREFER_NOT_TO_SAY_UUID = "d3f0f6de-b9be-4299-ade0-b40eef5d9ef2"
    OTHER_DISABILITY_UUID = "3451285e-972b-464c-9726-84cae27b82ea"

    class << self
      DATA_SET = DfE::ReferenceData::EqualityAndDiversity::DISABILITIES_AND_HEALTH_CONDITIONS

      def find_disability(filters)
        return DATA_SET.one(filters[:id]) if filters[:id].present?

        DATA_SET.some(filters).first if filters.any?
      end

      delegate :all, to: :DATA_SET
    end
  end
end
