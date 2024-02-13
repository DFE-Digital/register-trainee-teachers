# frozen_string_literal: true

module Api
  module Trainees
    class WithdrawResponse
      include ServicePattern
      include Api::ErrorResponse

      def initialize(trainee:, params:)
        @trainee = trainee
        @params = params
      end

      def call
        if withdraw_allowed?
          if withdraw_trainee
            { json: { data: TraineeSerializer.new(trainee).as_json }, status: :ok }
          else
            validation_errors_response(errors: withdrawal_attributes.errors)
          end
        else
          transition_error_response
        end
      end

    private

      attr_reader :trainee, :params

      def withdraw_allowed?
        !trainee.starts_course_in_the_future? && !trainee.itt_not_yet_started? && trainee.awaiting_action? && %w[submitted_for_trn trn_received deferred].any?(trainee.state)
      end

      def withdrawal_attributes
        @withdrawal_attributes ||= Api::WithdrawalAttributes.new(trainee:)
      end

      def withdraw_trainee
        withdrawal_attributes.assign_attributes(params)
        withdrawal_attributes.save!
      end
    end
  end
end
