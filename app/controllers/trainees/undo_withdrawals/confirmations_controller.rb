# frozen_string_literal: true

module Trainees
  module UndoWithdrawals
    class ConfirmationsController < Trainees::BaseController
      helper_method :undo_withdrawal_form, :trainee, :comment, :ticket, :state

      def show; end

      def update
        undo_withdrawal_form.save!
        redirect_to(trainee_path(trainee), flash: { success: "Withdrawal undone" })
      end

      def destroy
        undo_withdrawal_form.delete!
        redirect_to(trainee_path(trainee))
      end

    private

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
