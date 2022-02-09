# frozen_string_literal: true

require "rails_helper"

module PlacementDetails
  describe View do
    context "when data has not been provided" do
      let(:trainee) { create(:trainee, :provider_led_postgrad) }

      before do
        render_inline(View.new(trainee: trainee))
      end

      it "tells the user that no data has been entered for placements" do
        expect(rendered_component).to have_text(t("components.confirmation.not_provided"))
      end
    end
  end
end
