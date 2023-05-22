# frozen_string_literal: true

module SystemAdmin
  module TraineeDeletions
    class ConfirmationsController < ApplicationController
      before_action :load_trainee, :authorize_delete

      def show
        @delete_trainee_form = DeleteTraineeForm.new(@trainee)
      end

      def update
        @delete_trainee_form = DeleteTraineeForm.new(@trainee, user: current_user)

        if @delete_trainee_form.save!
          redirect_to(trainees_path, flash: { success: "Record deleted" })
        else
          render(:show)
        end
      end

      def destroy
        undo_withdrawal_form.clear_stash
        redirect_to(trainee_admin_path(@trainee))
      end

    private

      def load_trainee
        @trainee = Trainee.from_param(params[:id])
      end

      def authorize_delete
        authorize(@trainee, :destroy_with_reason?)
      end
    end
  end
end
