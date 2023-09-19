# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ReasonsController < ApplicationController
      # TODO: Verify that auth checks are happening correctly

      def edit
        @trainee = Trainee.find(params[:trainee_id])

        respond_to do |format|
          format.html
        end
      end

      def update
        # TODO: Save the selection in temporary storage

        redirect_to(trainee_accredited_providers_confirmations_path(trainee_id: params[:trainee_id]))
        # TODO: Or re-render the edit form
      end
    end
  end
end
