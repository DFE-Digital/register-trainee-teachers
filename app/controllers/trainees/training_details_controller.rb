# frozen_string_literal: true

module Trainees
  class TrainingDetailsController < BaseController
    def edit
      @training_details_form = TrainingDetailsForm.new(trainee)
    end

    def update
      @training_details_form = TrainingDetailsForm.new(trainee, params: trainee_params, user: current_user)

      if @training_details_form.save
        redirect_to(trainee_training_details_confirm_path(trainee))
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params.expect(training_details_form: [:provider_trainee_id])
    end
  end
end
