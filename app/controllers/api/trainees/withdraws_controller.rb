# frozen_string_literal: true

module Api
  module Trainees
    class WithdrawsController < Api::BaseController
      def create
        if trainee.blank?
          render_not_found(message: "Trainee not found")
        else
          render_transition_error
        end
      end

    private

      def withdraw_trainee
        trainee.update(withdrawal_params)
        trainee.withdraw!
        ::Trainees::Withdraw.call(trainee:)
      end

      def trainee
        @trainee ||= current_provider&.trainees&.find_by(slug:)
      end

      def slug
        @slug ||= params[:trainee_id]
      end

      def withdraw_allowed?
        !trainee.starts_course_in_the_future? && !trainee.itt_not_yet_started? && trainee.awaiting_action? && %w[submitted_for_trn trn_received deferred].any?(trainee.state)
      end

      def withdrawal_params
        params.permit(:withdraw_reasons_details, :withdraw_date)
      end
    end
  end
end
