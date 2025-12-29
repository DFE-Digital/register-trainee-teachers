# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ProvidersController < ApplicationController
      def edit
        @providers = Provider.all
        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(trainee, step: :provider)
      end

      def update
        @change_accredited_provider_form = ChangeAccreditedProviderForm.new(
          trainee,
          params: update_params,
          user: current_user,
          step: :provider,
        )

        if @change_accredited_provider_form.stash
          redirect_to(relevant_redirect_path)
        else
          @providers = Provider.all
          render(:edit)
        end
      end

    private

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end

      def update_params
        params
          .expect(system_admin_change_accredited_provider_form: [:accredited_provider_id])
      end

      def relevant_redirect_path
        page_tracker.last_origin_page_path || edit_trainee_accredited_providers_reason_path(trainee_id: params[:trainee_id])
      end
    end
  end
end
