# frozen_string_literal: true

module Timeline
  class View < ApplicationComponent
    include TimelineHelper

    attr_reader :events

    def initialize(events:)
      @events = events
    end

    def actor_for(event)
      "#{event.username}," if event.username.present?
    end
  end
end
