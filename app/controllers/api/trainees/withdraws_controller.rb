# frozen_string_literal: true

module Api
  module Trainees
    class WithdrawsController < Api::BaseController
      def create
        if withdraw_allowed?
          if withdraw_trainee
            render(json: { data: TraineeSerializer.new(trainee).as_json }, status: :accepted)
          else
            render_validation_errors(errors: withdrawal_attributes.errors)
          end
        else
          render_transition_error
        end
      end

    private

      def withdraw_trainee
        withdrawal_attributes.assign_attributes(withdrawal_params)
        withdrawal_attributes.save!
      end

      def trainee
        @trainee ||= current_provider.trainees.find_by!(slug:)
      end

      def slug
        @slug ||= params[:trainee_id]
      end

      def withdraw_allowed?
        !trainee.starts_course_in_the_future? && !trainee.itt_not_yet_started? && trainee.awaiting_action? && %w[submitted_for_trn trn_received deferred].any?(trainee.state)
      end

      def withdrawal_params
        params.permit(:withdraw_date, :withdraw_reasons_details, :withdraw_reasons_dfe_details, reasons: [])
      end

      def withdrawal_attributes
        @withdrawal_attributes ||= Api::WithdrawalAttributes.new(trainee:)
      end
    end
  end
end
