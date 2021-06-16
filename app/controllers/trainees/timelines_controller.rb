# frozen_string_literal: true

module Trainees
  class TimelinesController < ApplicationController
    before_action :authorize_trainee

    def show
      @timeline_events = trainee.timeline
      render layout: "trainee_record"
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
