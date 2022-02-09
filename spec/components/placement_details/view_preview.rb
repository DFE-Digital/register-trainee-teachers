# frozen_string_literal: true

require "govuk/components"

module PlacementDetails
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(trainee: mock_trainee))
    end

  private

    def mock_trainee
      @mock_trainee ||= Trainee.new(
        id: 1,
        training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
      )
    end
  end
end
