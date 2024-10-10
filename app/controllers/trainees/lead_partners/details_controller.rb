# frozen_string_literal: true

module Trainees
  module LeadPartners
    class DetailsController < BaseController
      def edit
        @lead_partner_form = Partners::LeadPartnerForm.new(trainee)
      end

      def update
        @lead_partner_form = Partners::LeadPartnerForm.new(trainee, params: trainee_params, user: current_user)

        if @lead_partner_form.stash_or_save!
          if @lead_partner_form.lead_partner_applicable?
            redirect_to(edit_trainee_lead_partners_path(trainee))
          else
            redirect_to(edit_trainee_employing_schools_details_path(trainee))
          end
        else
          render(:edit)
        end
      end

    private

      def trainee_params
        params.fetch(:partners_lead_partner_form, {})
          .permit(*Partners::LeadPartnerForm::FIELDS,
                  *Partners::LeadPartnerForm::NON_TRAINEE_FIELDS)
      end
    end
  end
end
