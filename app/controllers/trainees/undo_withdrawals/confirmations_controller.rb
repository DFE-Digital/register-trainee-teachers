# frozen_string_literal: true

module Trainees
  module UndoWithdrawals
    class ConfirmationsController < Trainees::BaseController
      helper_method :undo_withdrawal_form, :trainee, :comment, :ticket, :state
      before_action :can_undo_withdraw?

      def show; end

      def update
        if undo_withdrawal_form.save
          Trs::UpdateProfessionalStatusJob.perform_later(trainee)
          redirect_to(trainee_path(trainee), flash: { success: "Withdrawal undone" })
        else
          redirect_failed
        end
      rescue StandardError => e
        Sentry.capture_exception(e)
        redirect_failed
      end

      def destroy
        undo_withdrawal_form.delete!
        redirect_to(trainee_path(trainee))
      end

    private

      def can_undo_withdraw?
        authorize(trainee, :undo_withdraw?)
      end

      def redirect_failed
        redirect_to(trainee_path(trainee), flash: { warning: "Unable to undo the trainee Withdrawal. Please contact support." })
      end

      def comment
        undo_withdrawal_form.comment
      end

      def ticket
        undo_withdrawal_form.ticket
      end

      def state
        undo_withdrawal_form.previous_state
      end

      def undo_withdrawal_form
        @undo_withdrawal_form ||= UndoWithdrawalForm.new(trainee:, session:)
      end
    end
  end
end
