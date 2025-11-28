# frozen_string_literal: true

require "govuk/components"

module PlacementDetails
  class ViewPreview < ViewComponent::Preview
    [0, 1, 2, 5].each do |number_of_placements|
      [true, false] .each do |editable|
        method_name = number_of_placements.zero? ? "default" : "with_#{number_of_placements}_placements"
        method_name += editable ? "_editable" : "_non_editable"
        define_method method_name do
          render(View.new(data_model: mock_trainee(number_of_placements:), editable: editable))
        end
      end
    end

  private

    def mock_trainee(number_of_placements: 0)
      placements = (1..number_of_placements).map do |number|
        Placement.new(name: "placement #{number}", urn: "100000#{number}", address: "Placment #{number} road",
                      postcode: "TW1#{number} 1AT")
      end

      @mock_trainee ||= Trainee.new(
        id: 1,
        training_route: ReferenceData::TRAINING_ROUTES.provider_led_postgrad.name,
        placements: placements,
      )
    end
  end
end
