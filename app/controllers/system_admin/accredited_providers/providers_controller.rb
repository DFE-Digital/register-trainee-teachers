# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ProvidersController < ApplicationController
      # TODO: Verify that auth checks are happening correctly
      # TODO: Enforce feature flag

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
        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(trainee)

        if @change_accredited_provider_form.stash
          redirect_to(edit_trainee_accredited_providers_reason_path(trainee_id: params[:trainee_id]))
        else
          @providers = Provider.all
          render(:edit)
        end
      end
    end
  end
end
