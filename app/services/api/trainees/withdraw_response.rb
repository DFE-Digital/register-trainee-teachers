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
          if save!
            { json: { data: TraineeSerializer.new(trainee).as_hash }, status: :ok }
          else
            validation_errors_response(errors: withdrawal_attributes.errors)
          end
        else
          transition_error_response
        end
      end

      delegate :withdraw!, :update!, :starts_course_in_the_future?, :itt_not_yet_started?, :awaiting_action?, :state, to: :trainee
      delegate :assign_attributes, :valid?, :attributes_to_save, to: :withdrawal_attributes

    private

      attr_reader :trainee, :params

      def withdraw_allowed?
        !starts_course_in_the_future? && !itt_not_yet_started? && awaiting_action? && %w[submitted_for_trn trn_received deferred].any?(state)
      end

      def withdrawal_attributes
        @withdrawal_attributes ||= Api::WithdrawalAttributes.new(trainee:)
      end

      def save!
        assign_attributes(params)

        if valid?
          update!(attributes_to_save)
          withdraw!
          ::Trainees::Withdraw.call(trainee:)
          true
        else
          false
        end
      end
    end
  end
end
