# frozen_string_literal: true

module CancelLink
  class View < ApplicationComponent
    include TraineeHelper

    attr_reader :draft

    def initialize(trainee)
      @trainee = trainee
    end

    def render?
      !@trainee.draft?
    end

    def path
      page_tracker = PageTracker.new(trainee_slug: trainee.slug, session: session, request: request)
      # If you've arrived directly onto a page with no history, then there will
      # be no origin pages. view_trainee provides a sensible default.
      page_tracker.last_non_confirm_origin_page_path || view_trainee(trainee)
    end

  private

    attr_reader :trainee
  end
end
