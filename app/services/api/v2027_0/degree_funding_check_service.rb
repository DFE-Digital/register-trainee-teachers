# frozen_string_literal: true

module Api
  module V20270
    class DegreeFundingCheckService
      def initialize(trainee:, degrees:, version:)
        @trainee = trainee
        @degrees = degrees
        @version = version
      end

      def errors
        trainee_attributes = trainee_attributes_klass.from_trainee(trainee, {}, degrees: degrees_to_check)
        hesa_trainee_detail_attributes = trainee_attributes.hesa_trainee_detail_attributes
        return [] if hesa_trainee_detail_attributes.blank?

        result = hesa_trainee_detail_attributes.class::Rules::FundingMethod.call(hesa_trainee_detail_attributes)
        return [] if result.valid?

        hesa_trainee_detail_attributes.errors.add(:funding_method, result.error_type, **result.error_details)
        hesa_trainee_detail_attributes.errors.errors
      end

    private

      attr_reader :trainee, :degrees, :version

      def degrees_to_check
        degrees.empty? ? [::Degree.new] : degrees
      end

      def trainee_attributes_klass
        Api::GetVersionedItem.for_attributes(model: :trainee, version: version)
      end
    end
  end
end
