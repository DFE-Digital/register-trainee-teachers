# frozen_string_literal: true

module Api
  module V20250
    class HesaTraineeDetailSerializer
      EXCLUDED_ATTRIBUTES = %w[
        id
        course_study_mode
        hesa_disabilities
        trainee_id
      ].freeze

      FUND_CODE_FROM_ELIGIBILITY = {
        "eligible" => Hesa::CodeSets::FundCodes::ELIGIBLE,
        "not_eligible" => Hesa::CodeSets::FundCodes::NOT_ELIGIBLE,
      }.freeze

      def initialize(trainee_details)
        @trainee_details = trainee_details
      end

      def as_hash
        attrs = @trainee_details&.attributes&.except(*EXCLUDED_ATTRIBUTES) || {}
        attrs.merge("fund_code" => fund_code_from_trainee)
      end

    private

      def fund_code_from_trainee
        FUND_CODE_FROM_ELIGIBILITY[@trainee_details&.trainee&.funding_eligibility]
      end
    end
  end
end
