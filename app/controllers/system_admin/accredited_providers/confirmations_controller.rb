# frozen_string_literal: true

module SystemAdmin
  module AccreditedProviders
    class ConfirmationsController < ApplicationController
      # TODO: Verify that auth checks are happening correctly

      def edit
        @trainee = Trainee.find(params[:trainee_id])

        respond_to do |format|
          format.html
        end
      end

      def update
        # TODO: Commit the choices that are in temporary storage

        redirect_to(trainees_path(@trainee.slug))
        # TODO: Or re-render the page 
      end
    end
  end
end
