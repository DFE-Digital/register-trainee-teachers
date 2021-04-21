# frozen_string_literal: true

module Trainees
  class SchoolsController < ApplicationController
    def edit
      trainee
    end

    def update; end

    def search; end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end
  end
end
