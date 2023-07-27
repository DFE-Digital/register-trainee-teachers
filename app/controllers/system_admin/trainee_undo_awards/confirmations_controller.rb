# frozen_string_literal: true

module SystemAdmin
  module TraineeUndoAwards
    class ConfirmationsController < ApplicationController
# frozen_string_literal: true

module SystemAdmin
  module TraineeUndoAwards
    class ConfirmationsController < ApplicationController
      before_action :load_trainee, :authorize_undo_award

      def edit
        @trainee_undo_award_form = TraineeUndoAwardForm.new(@trainee, user: current_user)
      end

      def update
        @trainee_undo_award_form = TraineeUndoAwardForm.new(@trainee, user: current_user)

        if @trainee_undo_award_form.save!
          redirect_to(trainees_path, flash: { success: "Record deleted" })
        else
          render(:show)
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
      before_action :load_trainee, :authorize_undo_award

      def edit
        @trainee_undo_award_form = TraineeUndoAwardForm.new(@trainee, user: current_user)
      end

      def update
        @trainee_undo_award_form = TraineeUndoAwardForm.new(@trainee, user: current_user)

        if @trainee_undo_award_form.save!
          redirect_to(trainees_path, flash: { success: "Record deleted" })
        else
          render(:show)
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
