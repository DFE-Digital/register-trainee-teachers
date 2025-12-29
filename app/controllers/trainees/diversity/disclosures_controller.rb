# frozen_string_literal: true

module Trainees
  module Diversity
    class DisclosuresController < BaseController
      before_action :validate_form_completeness

      def edit
        @disclosure_form = Diversities::DisclosureForm.new(trainee)
      end

      def update
        @disclosure_form = Diversities::DisclosureForm.new(trainee, params: disclosure_params, user: current_user)

        if @disclosure_form.stash_or_save!
          redirect_to(step_wizard.next_step)
        else
          render(:edit)
        end
      end

    private

      def disclosure_params
        return { diversity_disclosure: nil } if params[:diversities_disclosure_form].blank?

        params.expect(diversities_disclosure_form: Diversities::DisclosureForm::FIELDS)
      end

      def step_wizard
        @step_wizard ||= Wizards::DiversitiesStepWizard.new(trainee:, page_tracker:)
      end

      def validate_form_completeness
        return unless trainee.diversity_disclosed?
        return if user_came_from_backlink?

        redirect_to(step_wizard.start_point) if step_wizard.start_point.present?
      end
    end
  end
end
