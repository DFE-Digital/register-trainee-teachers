# frozen_string_literal: true

require "govuk/components"

module Placements
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(data_model: mock_trainee))
    end

    def with_one_placement
      render(View.new(data_model: mock_trainee(number_of_placements: 1)))
    end

    def with_two_placement
      render(View.new(data_model: mock_trainee(number_of_placements: 2)))
    end

  private

    def mock_trainee(number_of_placements: 0)
      placements = case number_of_placements
                   when 1 then [Placement.new(name: "placement 1")]
                   when 2 then [Placement.new(name: "placement 1"), Placement.new(name: "placement 2")]
                   else
                     []
                   end

      @mock_trainee ||= Trainee.new(
        id: 1,
        training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
        placements: placements,
      )
    end
  end
end
