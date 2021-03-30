# frozen_string_literal: true

module Trainees
  module Timeline
    class View < GovukComponent::Base
      attr_reader :events

      def initialize(events:)
        @events = events
      end
    end
  end
end
