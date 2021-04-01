# frozen_string_literal: true

module Trainees
  class TimelinesController < ApplicationController
    before_action :authorize_trainee

    def show
      authorize trainee
      @timeline_events = events.flatten.compact.sort_by(&:date).reverse
      render layout: "trainee_record"
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def events
      audits.map { |audit| Trainees::CreateTimelineEvents.call(audit: audit) }
    end

    def audits
      trainee.own_and_associated_audits
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
