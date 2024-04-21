# frozen_string_literal: true

module HesaTraineeDetailSerializer
  class V01
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
