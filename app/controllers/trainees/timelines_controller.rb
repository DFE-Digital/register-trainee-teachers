# frozen_string_literal: true

module Trainees
  class TimelinesController < BaseController
    def show
      @timeline_events = trainee.timeline
      render(layout: "trainee_record")
    end
  end
end
