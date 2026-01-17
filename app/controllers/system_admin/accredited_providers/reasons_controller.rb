# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ReasonsController < ApplicationController
      def edit
        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(trainee, step: :reasons)
      end

      def update
        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(
          trainee,
          params: update_params,
          user: current_user,
          step: :reasons,
        )

        if @change_accredited_provider_form.stash
          redirect_to(relevant_redirect_path)
        else
          render(:edit)
        end
      end

    private

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end

      def update_params
        params
          .expect(system_admin_change_accredited_provider_form: %i[audit_comment zendesk_ticket_url])
      end

      def relevant_redirect_path
        page_tracker.last_origin_page_path || trainee_accredited_providers_confirmations_path(trainee_id: params[:trainee_id])
      end
    end
  end
end
