# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ConfirmationsController < ApplicationController
      before_action :enforce_feature_flag

      def show
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

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end

    private

      def enforce_feature_flag
        redirect_to(not_found_path) unless FeatureService.enabled?(:change_accredited_provider)
      end
    end
  end
end
