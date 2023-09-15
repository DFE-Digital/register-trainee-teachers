# frozen_string_literal: true

module SystemAdmin
  class AccreditedProvidersController < ApplicationController
    # TODO: Verify that auth checks are happening correctly

    def edit
      @providers = []
      @trainee = Trainee.find_by_slug(params[:trainee_id])

      respond_to do |format|
        format.html
      end
    end

    def update
    end
  end
end

