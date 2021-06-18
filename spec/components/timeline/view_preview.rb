# frozen_string_literal: true

require "govuk/components"

module Timeline
  class ViewPreview < ViewComponent::Preview
    def created
      render View.new(events: [mock_event])
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
