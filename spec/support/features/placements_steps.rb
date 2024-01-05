# frozen_string_literal: true

module Features
  module PlacementsSteps
    def and_the_placements_details_is_complete
      click_on("Placements")
      page.choose("No")
      click_button("Continue")
    end
  end
end
