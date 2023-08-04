# frozen_string_literal: true

module SystemAdmin
  module TraineeUndoAwards
    class DqtChecksController < ApplicationController
      before_action :load_trainee, :authorize_undo_award

      def edit; end

      def update
        if TraineeSafeToUnaward.call(@trainee)
          redirect_to(edit_trainee_undo_awards_reason_path(@trainee))
        else
          render(:check_failed)
        end
      end

    private

      def load_trainee
        @trainee = Trainee.from_param(params[:id])
      end

      def authorize_undo_award
        authorize(@trainee, :undo_award_with_reason?)
      end
    end
  end
end
