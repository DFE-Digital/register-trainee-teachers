# frozen_string_literal: true

module Timeline
  class View < ViewComponent::Base
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
