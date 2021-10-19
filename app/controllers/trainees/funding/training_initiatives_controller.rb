# frozen_string_literal: true

module Trainees
  module Funding
    class TrainingInitiativesController < BaseController
      def edit
        @training_initiatives_form = ::Funding::TrainingInitiativesForm.new(trainee)
      end

      def update
        @training_initiatives_form = ::Funding::TrainingInitiativesForm.new(trainee, params: trainee_params, user: current_user)

        if @training_initiatives_form.stash_or_save!
          redirect_to(step_wizard.next_step)
        else
          render(:edit)
        end
      end

    private

      def trainee_params
        return { training_initiative: nil } if params[:funding_training_initiatives_form].blank?

        params.require(:funding_training_initiatives_form).permit(*::Funding::TrainingInitiativesForm::FIELDS)
      end

      def funding_manager
        @funding_manager ||= FundingManager.new(trainee)
      end

      def step_wizard
        @step_wizard ||= Wizards::FundingStepWizard.new(trainee: trainee, page_tracker: page_tracker)
      end
    end
  end
end
