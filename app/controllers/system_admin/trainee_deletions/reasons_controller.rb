# frozen_string_literal: true

module SystemAdmin
  module TraineeDeletions
    class ReasonsController < ApplicationController
      before_action :load_trainee, :authorize_delete

      def edit
        @delete_trainee_form = DeleteTraineeForm.new(@trainee)
      end

      def update
        @delete_trainee_form = DeleteTraineeForm.new(@trainee, params: delete_params, user: current_user)

        if @delete_trainee_form.stash
          redirect_to(trainee_deletions_confirmation_path(@trainee))
        else
          render(:edit)
        end
      end

    private

      def load_trainee
        @trainee = Trainee.from_param(params[:id])
      end

      def delete_params
        params.expect(system_admin_delete_trainee_form: %i[delete_reason additional_delete_reason ticket])
      end

      def authorize_delete
        authorize(@trainee, :destroy_with_reason?)
      end
    end
  end
end
