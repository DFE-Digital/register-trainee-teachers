# frozen_string_literal: true

module Trainees
  class TraineeIdsController < BaseController
    def edit
      @trainee_id_form = TraineeIdForm.new(trainee)
    end

    def update
      @trainee_id_form = TraineeIdForm.new(trainee, params: trainee_params, user: current_user)

      if @trainee_id_form.stash_or_save!
        redirect_to(trainee_trainee_id_confirm_path(trainee))
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params.require(:trainee_id_form).permit(:trainee_id)
    end
  end
end
