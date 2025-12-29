# frozen_string_literal: true

module Trainees
  class UndoWithdrawalsController < BaseController
    helper_method :trainee
    before_action :can_undo_withdraw?

    def show; end

    def edit
      @undo_withdrawal_form = UndoWithdrawalForm.new(trainee:, session:)
    end

    def update
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

    def can_undo_withdraw?
      authorize(trainee, :undo_withdraw?)
    end

    def trainee_params
      params
        .expect(undo_withdrawal_form: %i[comment ticket])
    end
  end
end
