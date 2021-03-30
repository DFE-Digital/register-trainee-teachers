# frozen_string_literal: true

require "govuk/components"

module Trainees
  module Timeline
    class ViewPreview < ViewComponent::Preview
      def created
        render Trainees::Timeline::View.new(events: [mock_event])
      end

    private

      def mock_event
        OpenStruct.new(
          title: "Record created",
          username: "Person A",
          date: Time.zone.now,
        )
      end
    end
  end
end
