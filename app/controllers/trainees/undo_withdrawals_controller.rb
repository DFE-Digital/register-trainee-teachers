# frozen_string_literal: true

module Trainees
  class UndoWithdrawalsController < BaseController
    helper_method :trainee

    def show; end

    def edit
      @undo_withdrawal_form = UndoWithdrawalForm.new(trainee:, session:)
    end

    def update
      authorize(trainee, :undo_withdraw?)

      @undo_withdrawal_form = UndoWithdrawalForm.new(
        trainee: trainee,
        comment: trainee_params[:comment],
        ticket: trainee_params[:ticket],
        session: session,
      )

      if @undo_withdrawal_form.valid?
        redirect_to(trainee_undo_withdrawal_confirmation_path(trainee))
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params
        .require(:undo_withdrawal_form)
        .permit(:comment, :ticket)
    end
  end
end
