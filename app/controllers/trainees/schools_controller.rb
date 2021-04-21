# frozen_string_literal: true

module Trainees
  class SchoolsController < ApplicationController
    def edit
      trainee
    end

    def update
      if params[:update]
        # Perform the update with the provided school
      else
        # Redirect to the no-JS results list with the text input query string
        # rendering the results via our search service.
      end
    end

    def search; end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end
  end
end
