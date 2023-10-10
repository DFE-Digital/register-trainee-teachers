# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ConfirmationsController < ApplicationController
      def show
        page_tracker.save_as_origin!

        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(trainee)
      end

      def update
        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(trainee)

        if @change_accredited_provider_form.save!
          redirect_to(trainee_path(trainee.slug), flash: { success: "Accredited provider changed" })
        else
          render(:show)
        end
      end

    private

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end
    end
  end
end
