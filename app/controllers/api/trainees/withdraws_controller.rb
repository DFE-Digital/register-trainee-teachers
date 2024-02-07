# frozen_string_literal: true

module Api
  module Trainees
    class WithdrawsController < Api::BaseController
      def create
        if trainee.blank?
          render_not_found(message: "Trainee not found")
        elsif withdraw_allowed?
          if errored_params.any?
            render_parameter_invalid(parameter_keys: errored_params)
          else
            withdraw_trainee

            render(json: { status: "Trainee withdrawal request accepted", trainee: TraineeSerializer.new(trainee).as_json }, status: :accepted)
          end
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

      def withdrawal_params_keys
        %i[withdraw_reasons_details withdraw_date]
      end

      def withdrawal_params
        params.permit(*withdrawal_params_keys)
      end

      def errored_params
        withdrawal_params.to_h.filter_map { |key, value| key if value.blank? }
      end
    end
  end
end
