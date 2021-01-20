# frozen_string_literal: true

module Trainees
  class CheckDetailsController < ApplicationController
    def show
      @trainee = Trainee.from_param(params[:id])
    end
  end
end
