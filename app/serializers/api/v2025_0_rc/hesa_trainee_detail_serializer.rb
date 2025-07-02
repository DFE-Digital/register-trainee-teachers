# frozen_string_literal: true

module Api
  module V20250Rc
    class HesaTraineeDetailSerializer
      EXCLUDED_ATTRIBUTES = %w[
        id
        trainee_id
        fund_code
      ].freeze

      def initialize(trainee_details)
        @trainee_details = trainee_details
      end

      def as_hash
        @trainee_details&.attributes&.except(*EXCLUDED_ATTRIBUTES)
      end
    end
  end
end
