# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ConfirmationsController < ApplicationController
      # TODO: Verify that auth checks are happening correctly
      # TODO: Enforce feature flag

      def show
        trainee = Trainee.find(params[:trainee_id])
        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(trainee)

        respond_to do |format|
          format.html
        end
      end

      def update
        trainee = Trainee.find(params[:trainee_id])
        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(trainee)

        if @change_accredited_provider_form.save!
          redirect_to(trainee_path(trainee.slug), flash: { success: "Accredited provider changed" })
        else
          render(:edit)
        end
      end
    end
  end
end
