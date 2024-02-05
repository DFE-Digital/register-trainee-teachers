# frozen_string_literal: true

module Api
  module Trainees
    class WithdrawsController < Api::BaseController
      def create
        if trainee.blank?
          render(json: { error: "Trainee not found" }, status: :not_found)
        else
          trainee.update(withdrawal_params) if withdraw_allowed?
          render(json: { status: "Trainee withdrawal request accepted", trainee: trainee }, status: :accepted)
        end
      end

    private

      def trainee
        @trainee ||= current_provider&.trainees&.find_by(slug:)
      end

      def slug
        @slug ||= params[:trainee_id]
      end

      def withdraw_allowed?
        !trainee.starts_course_in_the_future? && !trainee.itt_not_yet_started? && trainee.awaiting_action?
      end

      def withdrawal_params
        params.permit(:withdraw_reasons_details, :withdraw_date)
      end
    end
  end
end
