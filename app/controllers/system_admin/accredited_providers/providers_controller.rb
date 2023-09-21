# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ProvidersController < ApplicationController
      # TODO: Verify that auth checks are happening correctly

      before_action :enforce_feature_flag

      def edit
        @providers = Provider.all
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
          redirect_to(edit_trainee_accredited_providers_reason_path(trainee_id: params[:trainee_id]))
        else
          @providers = Provider.all
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
          .permit(:accredited_provider_id)
      end
    end
  end
end
