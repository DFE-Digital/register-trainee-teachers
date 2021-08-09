# frozen_string_literal: true

module Trainees
  module Diversity
    class DisclosuresController < ApplicationController
      before_action :authorize_trainee, :validate_form_completeness

      def edit
        @disclosure_form = Diversities::DisclosureForm.new(trainee)
      end

      def update
        @disclosure_form = Diversities::DisclosureForm.new(trainee, params: disclosure_params, user: current_user)

        save_strategy = trainee.draft? ? :save! : :stash

        if @disclosure_form.public_send(save_strategy)
          redirect_to step_wizard.next_step
        else
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def disclosure_params
        return { diversity_disclosure: nil } if params[:diversities_disclosure_form].blank?

        params.require(:diversities_disclosure_form).permit(*Diversities::DisclosureForm::FIELDS)
      end

      def authorize_trainee
        authorize(trainee)
      end

      def step_wizard
        @step_wizard ||= Wizards::DiversitiesStepWizard.new(trainee: trainee, page_tracker: page_tracker)
      end

      def validate_form_completeness
        return unless trainee.diversity_disclosed?
        return if user_came_from_backlink?

        redirect_to step_wizard.start_point if step_wizard.start_point.present?
      end
    end
  end
end
