# frozen_string_literal: true

module Trainees
  module TrainingPartners
    class DetailsController < BaseController
      def edit
        @lead_partner_form = Partners::LeadPartnerForm.new(trainee)
      end

      def update
        @lead_partner_form = Partners::LeadPartnerForm.new(trainee, params: trainee_params, user: current_user)

        if @lead_partner_form.stash_or_save!
          if @lead_partner_form.lead_partner_applicable?
            redirect_to(edit_trainee_training_partners_path(trainee))
          else
            redirect_to(step_wizard.next_step)
          end
        else
          render(:edit)
        end
      end

    private

      def trainee_params
        params
          .require(:partners_lead_partner_form)
          .permit(:lead_partner_not_applicable)
      end

      def step_wizard
        @step_wizard ||= Wizards::SchoolsStepWizard.new(trainee:, page_tracker:)
      end
    end
  end
end
