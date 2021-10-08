# frozen_string_literal: true

module Trainees
  module Funding
    class TrainingInitiativesController < ApplicationController
      before_action :authorize_trainee

      def edit
        @training_initiatives_form = ::Funding::TrainingInitiativesForm.new(trainee)
      end

      def update
        @training_initiatives_form = ::Funding::TrainingInitiativesForm.new(trainee, params: trainee_params, user: current_user)

        if @training_initiatives_form.stash_or_save!
          if funding_manager.can_apply_for_funding_type?
            redirect_to(edit_trainee_funding_bursary_path(trainee))
          else
            trainee.update!(applying_for_bursary: false)
            redirect_to(trainee_funding_confirm_path(trainee))
          end
        else
          render(:edit)
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def trainee_params
        return { training_initiative: nil } if params[:funding_training_initiatives_form].blank?

        params.require(:funding_training_initiatives_form).permit(*::Funding::TrainingInitiativesForm::FIELDS)
      end

      def authorize_trainee
        authorize(trainee)
      end

      def funding_manager
        @funding_manager ||= FundingManager.new(trainee)
      end
    end
  end
end
