# frozen_string_literal: true

module Trainees
  class TimelinesController < BaseController
    def show
      @timeline_events = Trainees::CreateTimeline.call(trainee:, current_user:)
      render("trainees/show")
    end
  end
end
