# frozen_string_literal: true

require "govuk/components"

module PlacementDetails
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(trainee: mock_trainee, system_admin: mock_system_admin))
    end

  private

    def mock_trainee
      @mock_trainee ||= Trainee.new(
        id: 1,
        training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
      )
    end

    def mock_system_admin
      @system_admin ||= User.new(first_name: "Luke", last_name: "Skywalker", system_admin: true)
    end
  end
end
