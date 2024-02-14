# frozen_string_literal: true

module Api
  module Trainees
    class WithdrawsController < Api::BaseController
      def create
        render(**withdraw_response)
      end

    private

      def withdraw_response
        @withdraw_response ||= Api::Trainees::WithdrawResponse.call(trainee: trainee, params: withdrawal_params)
      end

      def trainee
        @trainee ||= current_provider.trainees.find_by!(slug:)
      end

      def slug
        @slug ||= params[:trainee_id]
      end

      def withdrawal_params
        params.permit(:withdraw_date, :withdraw_reasons_details, :withdraw_reasons_dfe_details, reasons: [])
      end
    end
  end
end
