# frozen_string_literal: true

module Trainees
  class CheckDetailsController < ApplicationController
    include Breadcrumbable

    def show
      @trainee = Trainee.from_param(params[:id])
      save_origin_page_for(@trainee)
    end
  end
end
