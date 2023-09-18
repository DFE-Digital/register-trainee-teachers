# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ProvidersController < ApplicationController
      # TODO: Verify that auth checks are happening correctly

      def edit
        @providers = Provider.all
        @trainee = Trainee.find(params[:trainee_id])

        respond_to do |format|
          format.html
        end
      end

      def update
        # TODO: Save the selection in temporary storage

        redirect_to(edit_trainee_accredited_providers_reason_path(trainee_id: params[:trainee_id]))
        # TODO: Or re-render the edit form
      end
    end
  end
end
