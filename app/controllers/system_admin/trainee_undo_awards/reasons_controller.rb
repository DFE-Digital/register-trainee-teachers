# frozen_string_literal: true

module SystemAdmin
  module TraineeUndoAwards
    class ReasonsController < ApplicationController
      before_action :load_trainee, :authorize_undo_award

      def edit; end

      def update
        # TODO: Implement `UndoTraineeAwardForm`

        # @undo_award_trainee_form = UndoTraineeAwardForm.new(
        #   @trainee,
        #   params: undo_award_params,
        #   user: current_user,
        # )

        # if @undo_award_trainee_form.stash
        #   redirect_to(edit_trainee_undo_awards_confirmation_path(@trainee))
        # else
        #   render(:edit)
        # end
      end

    private

      def load_trainee
        @trainee = Trainee.from_param(params[:id])
      end

      def undo_award_params
        params.require(:system_admin_undo_award_trainee_form).permit(:reason, :additional_reason, :ticket)
      end

      def authorize_undo_award
        authorize(@trainee, :undo_award_with_reason?)
      end
    end
  end
end
