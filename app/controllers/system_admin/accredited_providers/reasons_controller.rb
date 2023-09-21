# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ReasonsController < ApplicationController
      # TODO: Verify that auth checks are happening correctly

      before_action :enforce_feature_flag

      def edit
        trainee = Trainee.find(params[:trainee_id])
        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(trainee)

        respond_to do |format|
          format.html
        end
      end

      def update
        trainee = Trainee.find(params[:trainee_id])
        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(
          trainee,
          params: update_params,
          user: current_user,
        )

        if @change_accredited_provider_form.stash
          redirect_to(trainee_accredited_providers_confirmations_path(trainee_id: params[:trainee_id]))
        else
          render(:edit)
        end
      end

    private

      def enforce_feature_flag
        redirect_to(not_found_path) unless FeatureService.enabled?(:change_accredited_provider)
      end

      def update_params
        params
          .require(:system_admin_change_accredited_provider_form)
          .permit(:audit_comment, :zendesk_ticket_url)
      end
    end
  end
end
