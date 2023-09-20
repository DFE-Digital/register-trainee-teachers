# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ReasonsController < ApplicationController
      # TODO: Verify that auth checks are happening correctly
      # TODO: Enforce feature flag

      def edit
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
          redirect_to(trainee_accredited_providers_confirmations_path(trainee_id: params[:trainee_id]))
        else
          render(:edit)
        end
      end
    end
  end
end
