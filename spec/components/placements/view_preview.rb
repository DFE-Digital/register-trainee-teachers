# frozen_string_literal: true

require "govuk/components"

module Placements
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(data_model: mock_trainee))
    end

    def with_one_placement
      render(View.new(data_model: PlacementsForm.new(mock_trainee(number_of_placements: 1))))
    end

    def with_two_placement
      render(View.new(data_model: PlacementsForm.new(mock_trainee(number_of_placements: 2))))
    end

  private

    def mock_trainee(number_of_placements: 0)
      placements = (1..number_of_placements).map { |number| Placement.new(name: "placement #{number}") }

      @mock_trainee ||= Trainee.new(
        id: 1,
        training_route: ReferenceData::TRAINING_ROUTES.provider_led_postgrad.name,
        placements: placements,
      )
    end
  end
end
